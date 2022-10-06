//
//  SecurityProvider.swift
//  
//
//  Created by Thomas Roovers on 03/10/2022.
//

import UIKit
import Combine

public protocol SecurityProvider {
    
    /// The message which is shown once the biometric authentication is being triggered
    var biometricAuthenticationMessage: String? { get }
    
    /// The name of the item in Keychain
    var biometricSecurityKeychainItemName: String? { get }
    
    /// The identifier which is used to query for the secure Keychain item
    var userIdentifier: String? { get }
    
    /// The lifetime of a session in seconds.
    /// When expired, the user is being presented the authentication view again.
    var sessionLifetime: Int? { get }
    
    /// The configured type of security of the app, biometric/code/none
    /// - Returns: `SecurityType?`
    func securityType() -> SecurityType?
    
    /// Change the security type for the app
    /// - Parameter securityType: `SecurityType?`
    func setSecurityType(_ securityType: SecurityType?)
    
    /// The user did change the pin code
    /// - Parameter code: `String?`
    func didSetPinCode(_ code: String?)
    
    /// Get the configured pin code of the user
    /// - Returns: `String?`
    func getPinCode() -> String?
}

public protocol SecurityAuthenticationDelegate: AnyObject {
    /// Present the security code authentication view
    /// - Parameter viewController: `UIViewController`
    /// - Returns: `AnyPublisher<AuthenticationResult, Never>`
    func presentSecurityCodeView(in viewController: UIViewController) -> AnyPublisher<AuthenticationResult, Never>
    
    /// The user has either cancelled or entered a code
    /// - Parameter result: `AuthenticationResult`
    func dismissSecurityCodeView(withResult result: AuthenticationResult)
}
