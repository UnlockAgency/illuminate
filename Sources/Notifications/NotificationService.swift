//
//  NotificationService.swift
//  Plein
//
//  Created by Bas van Kuijck on 19/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import Combine
import UserNotifications
import Logging

public typealias FCMToken = String
public typealias APNSDeviceToken = String

public protocol NotificationService: AnyObject {
    var deviceToken: APNSDeviceToken? { get }
    var fcmToken: FCMToken? { get }
    var logger: Logger? { get set }
    
    var registerDeviceHandler: ((FCMToken) async throws -> Void)? { get set }
    
    func setDeviceToken(_ deviceToken: Data?, error: Error?)
    func unregister() -> AnyPublisher<FCMToken?, NotificationError>
    
    func requestRemoteRegistration()
    
    func subscribe(to topics: [any NotificationTopicType]) -> AnyPublisher<Void, NotificationError>
    func unsubscribe(to topics: [any NotificationTopicType]) -> AnyPublisher<Void, NotificationError>
    func subscribe(to topic: any NotificationTopicType) -> AnyPublisher<Void, NotificationError>
    func unsubscribe(to topic: any NotificationTopicType) -> AnyPublisher<Void, NotificationError>
    func isSubscribed(topic: any NotificationTopicType) -> Bool
}
