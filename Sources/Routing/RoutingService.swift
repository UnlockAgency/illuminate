//
//  RoutingService.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import UserNotifications
import Combine

public protocol RoutingService: AnyObject {
    func handle(_ routable: Routable) -> Bool
    func handle(url: URL) -> Bool
#if canImport(UIKit)
    func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
#endif
    func handleNotification(response: UNNotificationResponse)
    
    @available(*, message: "Use `valuePublisher(for:)` instead")
    func publisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never>
    
    
    /// Listen for route events
    ///
    /// **Example**
    /// ```
    /// routingService.valuePublisher(for: OAuthAuthenticatedRoute.self)
    ///     .sink { (value: OAuthAuthenticatedValue) in
    ///        // ... received value when 'xximo://oauth/authenticated' is openend
    ///     }.store(in: &cancellables)
    /// ```
    func valuePublisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never>
    
    /// Listen for route events
    ///
    /// **Example**
    /// ```
    /// routingService.routePublisher(for: OAuthAuthenticatedRoute.self)
    ///     .sink { (value: OAuthAuthenticatedRoute) in
    ///        // ... 
    ///     }.store(in: &cancellables)
    /// ```
    func routePublisher<T: Route>(for type: T.Type) -> AnyPublisher<T, Never>
}
