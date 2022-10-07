//
//  Optional.swift
//  
//
//  Created by Thomas Roovers on 07/10/2022.
//

import Foundation

extension Optional {
    public func optionalDescription(_ nilValue: String = "(nil)") -> String {
        guard let obj = self else {
            return nilValue
        }
        return "\(obj)"
    }
}
