//
//  View+hiding.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Hides or shows a View depending on the `hidden` parameter
    ///
    /// - Parameters:
    ///   - hidden: `Bool` (Same as `.hidden()`)
    ///   - remove: `Bool` (default: true). This wil not render the view on screen. Setting `remove` to `false` will result in an empty spot
    ///
    /// - Returns: `some View`
    @ViewBuilder public func hide(_ hidden: Bool, remove: Bool = true) -> some View {
        if !hidden {
            self
        } else if !remove {
            self.hidden()
        }
    }
}
