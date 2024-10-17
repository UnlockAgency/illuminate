//
//  PermissionManager.swift
//
//  Created by Bas van Kuijck on 19/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
@preconcurrency import Combine
import UserNotifications
import CoreLocation
import Logging
import IlluminateFoundation

enum NotificationError: Error {
    case notGranted
}

final public class PermissionManager: NSObject, PermissionService, @unchecked Sendable {
    nonisolated(unsafe) public var logger: Logger?
    fileprivate var requestLocationPromises: [Future<PermissionStatus, Never>.Promise] = []
    
    lazy private var aLocationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    public override init() {
        super.init()
    }
    
    /// Requests permission for a specific type, it stores the request in UserDefaults and then it returns a publisher that emits the status of the permission request.
    /// - Parameter type: The type of permission to request.
    /// - Returns: A publisher that emits the status of the permission request.
    
    @MainActor
    public func requestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        // Store the permission request in UserDefaults
        UserDefaults.standard.set(true, forKey: userDefaultsKey(for: type))
        // Get the current permission status
        return getPermission(for: type)
            // Perform the following actions on the main thread
            .subscribe(on: DispatchQueue.main)
            .flatMap { [weak self] permission -> AnyPublisher<PermissionStatus, Never> in
                guard let strongSelf = self, permission == .pending else {
                    // If the permission is not pending, return it immediately
                    return Just(permission).eraseToAnyPublisher()
                }
                // Otherwise, make the request for permission
                return strongSelf.makeRequestPermission(for: type)
            }.eraseToAnyPublisher()
    }
    
    @MainActor
    private func makeRequestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        logger?.debug("Requesting permission for '\(type)' ...", metadata: [ "service": "permissions" ])
        let publisher: AnyPublisher<PermissionStatus, Never>
        
        switch type {
        case .audio, .video:
            publisher = Future<PermissionStatus, Never> { promise in
                AVCaptureDevice.requestAccess(for: type == .video ? .video : .audio) { granted in
                    promise(.success(granted ? .granted : .declined))
                }
            }.eraseToAnyPublisher()
        case .location:
            publisher = Future<PermissionStatus, Never> { [weak self] promise in
                self?.requestLocationPromises.append(promise)
                self?.aLocationManager.requestWhenInUseAuthorization()
            }.eraseToAnyPublisher()
            
        case .notifications:
            publisher = registerNotifications()
                .map { PermissionStatus.granted }
                .catch { _ in
                    return Just(PermissionStatus.declined).eraseToAnyPublisher()
                }.eraseToAnyPublisher()
        }
        
        return publisher.map { [weak self] status in
            self?.logger?.info("Permission request for '\(type)' result: \(status)", metadata: [ "service": "permissions" ])
            return status
        }.eraseToAnyPublisher()
    }
    
    public func hasRequestedPermission(for type: PermissionType) -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey(for: type))
    }
    
    private func userDefaultsKey(for type: PermissionType) -> String {
        return "has_requested_permission-\(type.rawValue)"
    }
    
    /// Returns the current permission status for a specific type.
    /// - Parameter type: The type of permission to check.
    /// - Returns: A publisher that emits the current permission status.
    public func getPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        switch type {
        case .video, .audio:
            let permissionStatus: PermissionStatus
            switch AVCaptureDevice.authorizationStatus(for: type == .video ? .video : .audio) {
            case .authorized:
                permissionStatus = .granted
            case .notDetermined:
                permissionStatus = .pending
            default:
                permissionStatus = .declined
            }
            return Just(permissionStatus).eraseToAnyPublisher()
        case .location:
            let permissionStatus: PermissionStatus
            // Check the authorization status of the location manager
            switch locationManagerAuthorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                permissionStatus = .granted
            case .notDetermined:
                permissionStatus = .pending
            default:
                permissionStatus = .declined
            }
            return Just(permissionStatus).eraseToAnyPublisher()
            
        case .notifications:
            // Request the notification settings and return a Future with the result
            return Future<PermissionStatus, Never> { promise in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized, .provisional:
                        promise(.success(.granted))
                    case .notDetermined:
                        promise(.success(.pending))
                        return
                    default:
                        promise(.success(.declined))
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
    }
    
    @MainActor
    private func registerNotifications() -> AnyPublisher<Void, Error> {
        logger?.debug("Request remote nofications authorization", metadata: [ "service": "permissions" ])
        UIApplication.shared.registerForRemoteNotifications()
        return withAsyncThrowingPublisher { [logger] in
                let options = UNAuthorizationOptions([ .alert, .badge, .sound ])
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
                if !granted {
                    throw NotificationError.notGranted
                }
                logger?.info("Remote nofications authorization granted '\(granted)'", metadata: [ "service": "permissions" ])
            }
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension PermissionManager: CLLocationManagerDelegate {
    fileprivate var locationManagerAuthorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        logger?.trace("Location manager did change authorization -> \(status)", metadata: [ "service": "permissions" ])
        switch locationManagerAuthorizationStatus {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            requestLocationPromises.forEach { $0(.success(.granted)) }
        case .notDetermined:
            return
        default:
            requestLocationPromises.forEach { $0(.success(.declined)) }
        }
        requestLocationPromises.removeAll()
    }
}
