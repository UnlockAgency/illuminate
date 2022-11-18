//
//  Route.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation

public protocol Route {
    associatedtype ValueType
    
    var value: ValueType { get }
    static func handle(url: URL) -> Self?
}

public extension Route {
    static func getPath(from url: URL) -> String? {
        if let scheme = url.scheme, let host = url.host {
            if !scheme.hasPrefix("http") {
                return "/\(host)\(url.relativePath)"
            }
        }
        return url.relativePath
    }
}
