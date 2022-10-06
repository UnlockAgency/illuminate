//
//  File.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import Foundation

protocol Sizeable: RawRepresentable {
    static var extraSmall: Self { get }
    static var small: Self { get }
    static var regular: Self { get }
    static var large: Self { get }
    static var extraLarge: Self { get }
    
    var padding: CGFloat { get }
}

public enum DefaultSize: String, Sizeable {
    case extraSmall
    case small
    case regular
    case large
    case extraLarge
    
    var padding: CGFloat {
        switch self {
        case .extraSmall: return 4
        case .small: return 8
        case .regular: return 16
        case .large: return 22
        case .extraLarge: return 26
        }
    }
}

struct Dimensions<S: Sizeable> {
    
    static func padding(_ size: S) -> CGFloat {
        return size.padding
    }
}
