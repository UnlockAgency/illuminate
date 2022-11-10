//
//  Binding+extension.swift
//
//  Created by Bas van Kuijck on 27/10/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding {
    public func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
