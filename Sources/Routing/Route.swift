//
//  Route.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation

protocol RouteType {
    static func handle(url: URL) -> RouteType?
}

extension RouteType {
    static func getPath(from url: URL) -> String? {
        if let scheme = url.scheme, let host = url.host {
            if scheme.contains("http") || scheme == Bundle.main.bundleIdentifier {
                return "/\(host)\(url.relativePath)"
            }
        }
        return url.relativePath
    }
}

protocol Route: RouteType {
    associatedtype ValueType
    
    var value: ValueType { get }
}
