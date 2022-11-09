//
//  Dictionary+extensions.swift
//  Plein
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public extension Dictionary {
    func map<T: Hashable, U>(_ handler: (Key, Value) -> (T, U)) -> [T: U] {
        var dictionary: [T: U] = [:]
        for keyValue in self {
            let result = handler(keyValue.0, keyValue.1)
            dictionary[result.0] = result.1
        }
        return dictionary
    }
    
    func toJSONString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
}
