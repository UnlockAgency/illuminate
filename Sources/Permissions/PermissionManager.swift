//
//  PermissionManager.swift
//  Plein
//
//  Created by Bas van Kuijck on 19/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import UIKit
import Combine
import UserNotifications
import CoreLocation
import Logging

enum NotificationError: Error {
    case notGranted
}

final public class PermissionManager: NSObject, PermissionService {
    public var logger: Logger?
    fileprivate var requestLocationPromises: [Future<PermissionStatus, Never>.Promise] = []
    
    lazy private var aLocationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    public override init() {
        super.init()
    }
    
    public func requestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        UserDefaults.standard.set(true, forKey: userDefaultsKey(for: type))
        return getPermission(for: type)
            .subscribe(on: DispatchQueue.main)
            .flatMap { [weak self] permission -> AnyPublisher<PermissionStatus, Never> in
                guard let strongSelf = self, permission == .pending else {
                    return Just(permission).eraseToAnyPublisher()
                }
                return strongSelf.makeRequestPermission(for: type)
            }.eraseToAnyPublisher()
    }
    
    private func makeRequestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        logger?.debug("Requesting permission for '\(type)' ...", metadata: [ "service": "permissions" ])
        let publisher: AnyPublisher<PermissionStatus, Never>
        
        switch type {
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
    
    public func getPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never> {
        switch type {
        case .location:
            let permissionStatus: PermissionStatus
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
            return Future<PermissionStatus, Never> { promise in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    Task { @MainActor in
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
            }.eraseToAnyPublisher()
        }
    }
    
    private func registerNotifications() -> AnyPublisher<Void, Error> {
        logger?.debug("Request remote nofications authorization", metadata: [ "service": "permissions" ])
        UIApplication.shared.registerForRemoteNotifications()
        return withAsyncThrowingPublisher { [weak self] in
                let options = UNAuthorizationOptions([ .alert, .badge, .sound ])
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
                if !granted {
                    throw NotificationError.notGranted
                }
                self?.logger?.info("Remote nofications authorization granted '\(granted)'", metadata: [ "service": "permissions" ])
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
