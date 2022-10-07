//
//  Emptyable.swift
//  
//
//  Created by Thomas Roovers on 07/10/2022.
//

import Foundation

public protocol Emptyable {
    var isEmpty: Bool { get }
}

extension String: Emptyable { }
extension Array: Emptyable { }
extension Dictionary: Emptyable { }

extension Emptyable {
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}
