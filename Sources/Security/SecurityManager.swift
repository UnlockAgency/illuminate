//
//  SecurityManager.swift
//  
//
//  Created by Thomas Roovers on 03/10/2022.
//

import Combine
import LocalAuthentication

#if canImport(UIKit)
import UIKit
#endif

public class SecurityManager {
    private static var hasSuccessfullyUnlockedInSession = false
    
    fileprivate lazy var context = LAContext()
    fileprivate lazy var defaultKeychainQuery: [String: Any] = {
        guard let itemName = provider.biometricSecurityKeychainItemName else {
            return [:]
        }
        
        return [
            // Type and key of the Keychain item
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemName as Any
        ]
    }()
    
    fileprivate lazy var keychainQuery: [String: Any] = {
        // Use the default query, but return data and limit the result to one item
        var query = defaultKeychainQuery
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        return query
    }()
    
    fileprivate lazy var deleteKeychainItemQuery: [String: Any] = defaultKeychainQuery
    
    private var cancellables = Set<AnyCancellable>()
    private var reCancellable: AnyCancellable?
    private var provider: SecurityProvider
    
    public weak var authenticationDelegate: SecurityAuthenticationDelegate?
    
    required public init(provider: SecurityProvider) {
        self.provider = provider
        
        setup()
    }
    
    private func setup() {
        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                SecurityManager.hasSuccessfullyUnlockedInSession = false
            }
            .store(in: &cancellables)
    }
    
    private func restartTimer() {
        reCancellable?.cancel()
        
        guard let lifetime = provider.sessionLifetime else {
            return
        }
        
        // Set a timer that will invalidate security session
        // Meaning that after the timer has finished, the user will need to reauthenticate through a pincode or biometric verification
        reCancellable = Timer.publish(
            every: Double(lifetime),
            on: .main,
            in: .common
        )
            .autoconnect()
            .prefix(1)
            .sink { [weak self] _ in
                log("Security lockscreen timeout fired, user needs to revalidate lockscreen pincode / biometrics")
                
                self?.reCancellable?.cancel()
                self?.reCancellable = nil
                SecurityManager.hasSuccessfullyUnlockedInSession = false
            }
    }
    
    public func reset() {
        provider.setSecurityType(nil)
        provider.didSetPinCode(nil)
    }
    
    public func present(in viewController: UIViewController) -> AnyPublisher<Bool, Never> {
        return present(once: false, in: viewController)
    }
    
    /// Present the security screen
    /// - Parameters:
    ///   - onceInSession: `Bool` If true, the user only has to authorize once during app session lifetime
    ///   - viewController: `UIViewController`
    /// - Returns: `AnyPublisher<Bool, Never>`
    public func present(once onceInSession: Bool, in viewController: UIViewController) -> AnyPublisher<Bool, Never> {
        if onceInSession && SecurityManager.hasSuccessfullyUnlockedInSession {
            log("User already unlocked during session, skipping authentication code verification")
            return Just(true).eraseToAnyPublisher()
        }
        
        switch provider.securityType() {
        case .biometric:
            return presentBiometricAuthentication()
                .map { result in
                    let success = result == .successful
                    SecurityManager.hasSuccessfullyUnlockedInSession = success
                    return success
                }
                .eraseToAnyPublisher()

        case .code:
            return presentSecurityCodeView(in: viewController)
        default:
            return Just(false).eraseToAnyPublisher()
        }
    }
    
    private func presentSecurityCodeView(in viewController: UIViewController) -> AnyPublisher<Bool, Never> {
        guard let authenticationDelegate else {
            log("Not presenting authentication code verification, no `authenticationDelegate` set")
            return Just(false).eraseToAnyPublisher()
        }
        
        return authenticationDelegate.presentSecurityCodeView(in: viewController)
            .filter { $0 != .pending }
            .prefix(1)
            .flatMap { [weak self] result in
                Future<Bool?, Never> { promise in
                    authenticationDelegate.dismissSecurityCodeView(withResult: result)

                    switch result {
                    case .successful:
                        self?.restartTimer()
                        SecurityManager.hasSuccessfullyUnlockedInSession = true
                        promise(.success(true))
                    case .failed:
                        promise(.success(false))
                    default:
                        promise(.success(nil))
                    }
                }
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func presentBiometricAuthentication() -> AnyPublisher<AuthenticationResult, Never> {
        guard let userIdentifier = provider.userIdentifier, provider.biometricSecurityKeychainItemName != nil else {
            log("No `userIdentifier` or `biometricSecurityKeychainItemName` configured in provider")
            return Just(AuthenticationResult.failed).eraseToAnyPublisher()
        }
        
        // Retrieve an item from the keychain which is biometrically secured
        var searchQuery = keychainQuery
        
        searchQuery[kSecUseOperationPrompt as String] = provider.biometricAuthenticationMessage ?? "Secure your app with biometric authentication"
        
        var item: AnyObject?
        let queryStatus = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        if queryStatus == errSecSuccess,
           let data = item as? Data,
           let stringValue = String(data: data, encoding: .utf8),
           stringValue == userIdentifier {
            
            return Just(AuthenticationResult.successful).eraseToAnyPublisher()
        }
        
        log("No results or corrupt Keychain item found, queryStatus: \(queryStatus)")
        
        if queryStatus == kLAErrorUserFallback {
            return Just(AuthenticationResult.fallback).eraseToAnyPublisher()
        }
        
        if queryStatus == errSecUserCanceled {
            return Just(AuthenticationResult.cancelled).eraseToAnyPublisher()
        }
        
        return Just(AuthenticationResult.failed).eraseToAnyPublisher()
    }
    
    public func enableBiometricSecurity() {
        // Delete an existing keychain record if present
        disableBiometricSecurity()
        
        guard
            let userIdentifier = provider.userIdentifier,
            let keychainItemName = provider.biometricSecurityKeychainItemName
        else {
            log("Impossible to create Keychain item, `userIdentifier` is missing or `biometricSecurityKeychainItemName` has not been configured")
            return
        }
        
        // Create the new keychain item
        let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlocked, .userPresence, nil)
        
        let saveQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainItemName as Any,
            kSecAttrAccessControl as String: access as Any,
            kSecValueData as String: userIdentifier.data(using: .utf8) as Any
        ]

        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            log("Error creating Keychain item: \(status)")
            return
        }
        
        log("Stored Keychain item for biometric security")
    }
        
    public func disableBiometricSecurity() {
        // Disabling is equivalent to deleting the secured item in Keychain
        let status = SecItemDelete(deleteKeychainItemQuery as CFDictionary)
        
        log("Disabled biometric security with result status: \(status)")
    }
}

extension SecurityManager {
    public var isBiometricAuthenticationAvailable: Bool {
#if targetEnvironment(simulator)
        return false
#else
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
#endif
    }
}
