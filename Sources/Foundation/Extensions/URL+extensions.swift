//
//  URL+extensions.swift
//
//  Created by Bas van Kuijck on 29/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

extension URL {
    public mutating func appendQueryParameter(key: String, value: String) {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return
        }
        
        var queryItems = (components.queryItems ?? []).filter { $0.name != key }
        queryItems.append(URLQueryItem(name: key, value: value))
        
        components.queryItems = queryItems
        if let newURL = components.url {
            self = newURL
        }
    }
    
    public func appendingQueryParameter(key: String, value: String) -> URL {
        var url = self
        url.appendQueryParameter(key: key, value: value)
        return url
    }
}
