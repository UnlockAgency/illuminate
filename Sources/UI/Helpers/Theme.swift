//
//  File.swift
//  
//
//  Created by Thomas Roovers on 07/10/2022.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public struct Theme {

    public static var `default` = Theme(
        colors: Theme.Colors(
            primary: UIColor.blue,
            secondary: UIColor.yellow
        ),
        text: Theme.Text(
            primary: UIColor.black
        )
    )

    public var colors: Colors
    public var text: Text
    
    public init(colors: Colors, text: Theme.Text) {
        self.colors = colors
        self.text = text
    }
    
    public static func setDefault(_ theme: Theme) {
        Theme.default = theme
    }
}

extension Theme {
    public struct Colors {
        public var primary: UIColor
        public var secondary: UIColor
        
        public init(primary: UIColor, secondary: UIColor) {
            self.primary = primary
            self.secondary = secondary
        }
    }
}

extension Theme {
    public struct Text {
        public var primary: UIColor
        
        public init(primary: UIColor) {
            self.primary = primary
        }
    }
}
