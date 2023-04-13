//
//  Route.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Foundation

public protocol Route: Routable {
    associatedtype ValueType
    
    var value: ValueType { get }
    static func handle(url: URL) -> Self?
}

public extension Route {
    /// Gets the path from a given url
    ///
    /// ```
    /// https://www.unlockagency.nl/some/path           => /some/path
    /// https://www.unlockagency.nl/some/path?foo=bar   => /some/path 
    /// unlockagency://some/path                        => /some/path
    /// ```
    ///
    /// - Parameters:
    ///   - `url`: URL
    ///
    /// - Returns: `String?`
    static func getPath(from url: URL) -> String? {
        if let scheme = url.scheme, let host = url.host {
            if !scheme.hasPrefix("http") {
                return "/\(host)\(url.relativePath)"
            }
        }
        return url.relativePath
    }
}
