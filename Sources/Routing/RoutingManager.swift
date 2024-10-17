//
//  RoutingManager.swift
//  Illuminate
//
//  Created by Bas van Kuijck on 19/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import Combine

open class RoutingManager: RoutingService, @unchecked Sendable {
    
    private var allRouteTypes: [any Route.Type] = []
    
    private let subject = PassthroughSubject<any Route, Never>()
    
    public init() {
        
    }
    
    public func registerRoutes(_ routeTypes: [any Route.Type]) {
        allRouteTypes.append(contentsOf: routeTypes)
    }
    
    public func registerRoutes(_ routeTypes: any Route.Type...) {
        allRouteTypes.append(contentsOf: routeTypes)
    }
    
    public func unregisterRoutes(_ routeTypes: [any Route.Type]) {
        allRouteTypes.removeAll { routeType in
            return routeTypes.contains { "\($0)" == "\(routeType)" }
        }
    }
    
    public func unregisterRoutes(_ routeTypes: any Route.Type...) {        
        allRouteTypes.removeAll { routeType in
            return routeTypes.contains { "\($0)" == "\(routeType)" }
        }
    }
    
    public func valuePublisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never> {
        return subject
            .share()
            .compactMap { ($0 as? T)?.value }
            .eraseToAnyPublisher()
    }
    
    @available(*, message: "Use `valuePublisher(for:)` instead")
    public func publisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never> {
        return valuePublisher(for: type)
    }
    
    public func routePublisher<T: Route>(for type: T.Type) -> AnyPublisher<T, Never> {
        return subject
            .share()
            .compactMap { ($0 as? T) }
            .eraseToAnyPublisher()
    }
    
#if canImport(UIKit)
    open func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }
        
        if let url = launchOptions[.url] as? URL {
            _ = handle(url)
        }
    }
    
    open func handleNotification(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        if let data = userInfo["data"] as? [String: Any],
           let urlString = data["url"] as? String,
           let url = URL(string: urlString) {
            _ = handle(url)
            
        } else if let urlString = userInfo["url"] as? String,
                  let url = URL(string: urlString) {
            _ = handle(url)
            
        } else if let custom = userInfo["custom"] as? [String: Any],
                  let customA = custom["a"] as? [String: Any],
                  let urlString = customA["url"] as? String,
                  let url = URL(string: urlString) {
            _ = handle(url)
        }
    }
#endif
    
    public func handle(url: URL, dryRun: Bool) -> (any Route)? {
        for routeType in allRouteTypes {
            if let route = routeType.handle(url: url) {
                if !dryRun {
                    Task { @MainActor [weak self] in
                        self?.subject.send(route)
                    }
                }
                return route
            }
        }
        return nil
    }
    
    open func handle(_ routable: Routable, dryRun: Bool) -> (any Route)? {
        if let url = routable as? URL {
            return handle(url: url, dryRun: dryRun)
            
        } else if let route = routable as? any Route {
            if !dryRun {
                subject.send(route)
            }
            return route
        }
        return nil
    }
}
