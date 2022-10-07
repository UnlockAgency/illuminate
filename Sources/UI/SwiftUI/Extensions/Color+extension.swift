//
//  Color.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import SwiftUI

extension Color {
    static var theme: Theme {
        return Theme(
            primary: Color.blue,
            text: Color.Theme.Text(
                primary: Color.black
            )
        )
    }
}

extension Color {
    struct Theme {
        var primary: Color

        var text: Text
    }
}

extension Color.Theme {
    struct Text {
        var primary: Color
    }
}
