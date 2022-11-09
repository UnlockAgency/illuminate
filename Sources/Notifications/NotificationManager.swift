//
//  NotificationManager.swift
//  Plein
//
//  Created by Bas van Kuijck on 19/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import FirebaseMessaging
import Combine
import IlluminateRouting
import Logging
import IlluminateSupport
import IlluminateInjection
import IlluminateFoundation

public class NotificationManager: NSObject, NotificationService {
    @LazyInjected fileprivate var routingService: RoutingService
    
    public var logger: Logger?
    public var registerDeviceHandler: ((FCMToken) async throws -> Void)?
    
    @UserDefault(key: "subscribed-topics2") private var subscribedTopics: [String] = []
    
    @UserDefault(key: "fcm-token") public private(set) var fcmToken: FCMToken?
    @UserDefault(key: "did-register-remote-fcm-token") private var didRegisterRemoteFcmToken: String?
    @UserDefault(key: "deviceToken") public private(set) var deviceToken: APNSDeviceToken? {
        didSet {
            setDeviceTokenDebug()
        }
    }
    
    private var isRemoteRegistering = false
    
    required public override init() {
        super.init()
        Messaging.messaging().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestRemoteRegistration), name: UIApplication.didBecomeActiveNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.requestRemoteRegistration()
        }
        
        setDeviceTokenDebug()
    }
    
    // MARK: - Registration
    // --------------------------------------------------------
    
    private func setDeviceTokenDebug() {
        DebugPanel.instance.add(key: "APNS-token", value: deviceToken)
    }
    
    public func unregister() -> AnyPublisher<FCMToken?, NotificationError> {
        logger?.info("Unregistering for remote notifications", metadata: [ "service": "notifications" ])
        defer {
            UIApplication.shared.unregisterForRemoteNotifications()
            didRegisterRemoteFcmToken = nil
            deviceToken = nil
        }
        
        return Just(fcmToken).setFailureType(to: NotificationError.self).eraseToAnyPublisher()
    }
    
    public func setDeviceToken(_ deviceToken: Data?, error: Error?) {
        self.deviceToken = nil
        if let data = deviceToken {
            let type: MessagingAPNSTokenType
#if DEBUG
            type = .sandbox
#else
            type = .prod
#endif
            Messaging.messaging().setAPNSToken(data, type: type)
            let deviceTokenString = data.reduce("", { $0 + String(format: "%02X", $1) })
            logger?.info("Set DeviceToken '\(deviceTokenString)'", metadata: [ "service": "notifications" ])
            self.deviceToken = deviceTokenString
        } else if let error = error {
            logger?.error("Set DeviceToken '(nil)': \(error)", metadata: [ "service": "notifications" ])
        }
    }
    
    @objc
    public func requestRemoteRegistration() {
        guard let fcmToken = fcmToken,
              !isRemoteRegistering
        else {
            return
        }
        
        guard didRegisterRemoteFcmToken != fcmToken, let registerDeviceHandler else {
            return
        }
        
        isRemoteRegistering = true
        Task { @MainActor in
            do {
                logger?.debug("Registering device with remote, fcmToken '\(fcmToken)'", metadata: [ "service": "notifications" ])
                try await registerDeviceHandler(fcmToken)
                didRegisterRemoteFcmToken = fcmToken
                logger?.info("Succesfully registered device with remote", metadata: [ "service": "notifications" ])
            } catch {
                logger?.error("Error registering device: \(error)", metadata: [ "service": "notifications" ])
            }
            isRemoteRegistering = false
        }
    }
    
    // MARK: - Topics
    // --------------------------------------------------------
    public func isSubscribed(topic: any NotificationTopicType) -> Bool {
        return subscribedTopics.contains { $0 == topic.name }
    }
    
    public func subscribe(to topics: [any NotificationTopicType]) -> AnyPublisher<Void, NotificationError> {
        return Publishers.MergeMany(topics.map { self.subscribe(to: $0) })
            .eraseToAnyPublisher()
    }
    
    public func unsubscribe(to topics: [any NotificationTopicType]) -> AnyPublisher<Void, NotificationError> {
        return Publishers.MergeMany(topics.map { self.unsubscribe(to: $0) })
            .eraseToAnyPublisher()
    }
    
    public func subscribe(to topic: any NotificationTopicType) -> AnyPublisher<Void, NotificationError> {
        logger?.debug("Subscribing to topic '\(topic)' ...", metadata: [ "service": "notifications" ])
        return Future<Void, NotificationError> { [weak self]  promise in
            Messaging.messaging().subscribe(toTopic: topic.name) {error in
                if let error {
                    self?.logger?.error("Failed subscribing to topic '\(topic.name)': \(error)", metadata: [ "service": "notifications" ])
                    promise(.failure(NotificationError(error: error)))
                } else {
                    self?.logger?.info("Subscribed to topic '\(topic.name)'", metadata: [ "service": "notifications" ])
                    if self?.isSubscribed(topic: topic) == false {
                        self?.subscribedTopics.append(topic.name)
                    }
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func unsubscribe(to topic: any NotificationTopicType) -> AnyPublisher<Void, NotificationError> {
        logger?.debug("Unsubscribing from topic '\(topic)' ...", metadata: [ "service": "notifications" ])
        return Future<Void, NotificationError> { [weak self]  promise in
            Messaging.messaging().unsubscribe(fromTopic: topic.name) { error in
                if let error {
                    self?.logger?.error("Failed unsubscribing from topic '\(topic.name)': \(error)", metadata: [ "service": "notifications" ])
                    promise(.failure(NotificationError(error: error)))
                } else {
                    self?.logger?.info("Unsubscribed from topic '\(topic.name)'", metadata: [ "service": "notifications" ])
                    self?.subscribedTopics.removeAll { $0 == topic.name }
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension NotificationManager: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        logger?.info("Did receive (new) FCM-token: '\(fcmToken.optionalDescription())'", metadata: [ "service": "notifications" ])
        
        if self.fcmToken != fcmToken {
            DebugPanel.instance.add(key: "fcm-token", value: fcmToken)
            self.fcmToken = fcmToken
            requestRemoteRegistration()
        }
    }
}
