//
//  Route.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation

public protocol RouteType: Routable {
    static func handle(url: URL) -> RouteType?
}

public extension RouteType {
    static func getPath(from url: URL) -> String? {
        if let scheme = url.scheme, let host = url.host {
            if !scheme.hasPrefix("http") {
                return "/\(host)\(url.relativePath)"
            }
        }
        return url.relativePath
    }
}

public protocol Route: RouteType {
    associatedtype ValueType
    
    var value: ValueType { get }
}
