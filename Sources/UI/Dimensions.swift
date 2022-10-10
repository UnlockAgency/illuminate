//
//  Size.swift
//  
//
//  Created by Thomas Roovers on 07/10/2022.
//

import Foundation

public protocol Sizeable: RawRepresentable {
    static var extraSmall: Self { get }
    static var small: Self { get }
    static var regular: Self { get }
    static var large: Self { get }
    static var extraLarge: Self { get }
    
    var padding: CGFloat { get }
    var spacing: CGFloat { get }
}

public enum DefaultSize: String, Sizeable {
    case extraSmall
    case small
    case regular
    case large
    case extraLarge
    
    public var padding: CGFloat {
        switch self {
        case .extraSmall: return 4
        case .small: return 8
        case .regular: return 16
        case .large: return 22
        case .extraLarge: return 26
        }
    }
    
    public var spacing: CGFloat {
        switch self {
        case .extraSmall: return 4
        case .small: return 8
        case .regular: return 12
        case .large: return 16
        case .extraLarge: return 20
        }
    }
}

public struct Dimensions<S: Sizeable> {
        
    public init() {
    }
    
    public enum Content {
        public static func padding(_ size: S) -> CGFloat {
            return size.padding
        }
        
        public static func spacing(_ size: S) -> CGFloat {
            return size.spacing
        }
    }
}
