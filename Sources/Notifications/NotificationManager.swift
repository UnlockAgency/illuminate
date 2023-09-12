//
//  NotificationManager.swift
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
    
    private var cancellables = Set<AnyCancellable>()
    
    public var logger: Logger?
    public var registerDeviceHandler: ((FCMToken) async throws -> Void)?
    
    @UserDefault(key: "subscribed-topics2") private var subscribedTopics: [String] = []
    
    @UserDefault(key: "fcm-token") public private(set) var fcmToken: FCMToken? {
        didSet {
            setDeviceTokenDebug()
        }
    }
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
        
        if Messaging.messaging().apnsToken == nil, let deviceTokenData = deviceToken?.hexadecimal {
            setDeviceToken(deviceTokenData, error: nil)
        }
        
        Messaging.messaging().token { [weak self] token, error in
            if error == nil {
                self?.fcmToken = token
                DebugPanel.instance.add(key: "fcm-token", value: token)
            }
        }
    }
    
    // MARK: - Registration
    // --------------------------------------------------------
    
    private func setDeviceTokenDebug() {
        DebugPanel.instance.add(key: "fcm-token", value: fcmToken)
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
    
    public func setDeviceToken(_ deviceTokenData: Data?, error: Error?) {
        if let deviceTokenData {
            let type: MessagingAPNSTokenType
#if DEBUG
            type = .sandbox
#else
            type = .prod
#endif
            Messaging.messaging().setAPNSToken(deviceTokenData, type: type)
            let deviceTokenString = deviceTokenData.reduce("", { $0 + String(format: "%02X", $1) })
            logger?.info("Set DeviceToken '\(deviceTokenString)'", metadata: [ "service": "notifications" ])
            deviceToken = deviceTokenString
        } else if let error = error {
            logger?.error("Set DeviceToken '(nil)': \(error)", metadata: [ "service": "notifications" ])
            deviceToken = nil
        }
    }
    
    @objc
    public func requestRemoteRegistration() {
        guard let fcmToken = fcmToken,
              !isRemoteRegistering
        else {
            return
        }
        
        guard didRegisterRemoteFcmToken != fcmToken else {
            return
        }
        
        isRemoteRegistering = true
        Task { @MainActor in
            do {
                try await registerDeviceHandler?(fcmToken)
                didRegisterRemoteFcmToken = fcmToken
                logger?.debug("Registered device with remote, fcmToken '\(fcmToken)'", metadata: [ "service": "notifications" ])
            } catch {
                if (error as? NotificationError)?.code != NotificationError.postpone.code {
                    logger?.error("Error registering device: \(error)", metadata: [ "service": "notifications" ])
                }
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
    
    /// Subscribes to a given topic and returns a publisher with the result of the subscription.
    /// - Parameter topic: The topic to subscribe to.
    /// - Returns: A publisher that emits a `Void` on success or a `NotificationError` on failure.
    public func subscribe(to topic: any NotificationTopicType) -> AnyPublisher<Void, NotificationError> {
        // Logs that we are subscribing to the topic
        logger?.debug("Subscribing to topic '\(topic)' ...", metadata: [ "service": "notifications" ])
        return Future<Void, NotificationError> { [weak self] promise in
            // Perform the actual subscription
            Messaging.messaging().subscribe(toTopic: topic.name) { error in
                if let error {
                    // Logs if the subscription failed
                    self?.logger?.error("Failed subscribing to topic '\(topic.name)': \(error)", metadata: [ "service": "notifications" ])
                    promise(.failure(NotificationError(error: error)))
                } else {
                    // Logs if the subscription was successful
                    self?.logger?.info("Subscribed to topic '\(topic.name)'", metadata: [ "service": "notifications" ])
                    // Keep track of the topic we subscribed to
                    if self?.isSubscribed(topic: topic) == false {
                        self?.subscribedTopics.append(topic.name)
                    }
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Unsubscribes from a given topic and returns a publisher with the result of the unsubscription.
    /// - Parameter topic: The topic to unsubscribe from.
    /// - Returns: A publisher that emits a `Void` on success or a `NotificationError` on failure.
    public func unsubscribe(to topic: any NotificationTopicType) -> AnyPublisher<Void, NotificationError> {
        // Logs that we are unsubscribing from the topic
        logger?.debug("Unsubscribing from topic '\(topic)' ...", metadata: [ "service": "notifications" ])
        return Future<Void, NotificationError> { [weak self] promise in
            // Perform the actual unsubscription
            Messaging.messaging().unsubscribe(fromTopic: topic.name) { error in
                if let error {
                    // Logs if the unsubscription failed
                    self?.logger?.error("Failed unsubscribing from topic '\(topic.name)': \(error)", metadata: [ "service": "notifications" ])
                    promise(.failure(NotificationError(error: error)))
                } else {
                    // Logs if the unsubscription was successful
                    self?.logger?.info("Unsubscribed from topic '\(topic.name)'", metadata: [ "service": "notifications" ])
                    // Remove the topic from the list of subscribed topics
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
            self.fcmToken = fcmToken
            requestRemoteRegistration()
        }
    }
}
