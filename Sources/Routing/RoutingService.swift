//
//  RoutingService.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation
import UIKit
import UserNotifications
import Combine

protocol RoutingService: AnyObject {
    func handle(url: URL) -> Bool
    func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func handleNotification(response: UNNotificationResponse)
    
    /// Listen for route events
    ///
    /// **Example**
    /// ```
    /// routingService.publisher(for: OAuthAuthenticatedRoute.self)
    ///     .sink { (value: OAuthAuthenticatedValue) in
    ///        // ... received value when 'xximo://oauth/authenticated' is openend
    ///     }.store(in: &cancellables)
    /// ```
    func publisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never>
}
