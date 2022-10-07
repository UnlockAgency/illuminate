//
//  Color.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import SwiftUI

extension Color {
    static var theme: Theme {
        return Theme.default
    }
    
    enum Branding {
        public static var primary: Color {
            return Color(theme.colors.primary)
        }
        
        public static var secondary: Color {
            return Color(theme.colors.secondary)
        }
    }
    
    enum Text {
        public static var primary: Color {
            return Color(theme.text.primary)
        }
    }
}
