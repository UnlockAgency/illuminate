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

open class RoutingManager: RoutingService {
    
    private var allRouteTypes: [RouteType.Type] = []
    
    public func registerRoutes(_ routeTypes: [RouteType.Type]) {
        allRouteTypes.append(contentsOf: routeTypes)
    }
    
    private let subject = PassthroughSubject<RouteType, Never>()
    
    public func publisher<T: Route>(for type: T.Type) -> AnyPublisher<T.ValueType, Never> {
        return subject
            .share()
            .compactMap { ($0 as? T)?.value }
            .eraseToAnyPublisher()
    }
    
#if canImport(UIKit)
    open func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }
        
        if let url = launchOptions[.url] as? URL {
            handle(url: url)
        }
    }
#endif
    
    @discardableResult
    open func handle(url: URL) -> Bool {
        for routeType in allRouteTypes {
            if let route = routeType.handle(url: url) {
                DispatchQueue.main.async {
                    self.subject.send(route)
                }
                return true
            }
        }
        return false
    }
    
    open func handleNotification(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        if let data = userInfo["data"] as? [String: Any],
           let urlString = data["url"] as? String,
           let url = URL(string: urlString) {
            _ = handle(url: url)
            
        } else if let urlString = userInfo["url"] as? String,
                  let url = URL(string: urlString) {
            _ = handle(url: url)
        }
    }
}
