//
//  Binding+extension.swift
//
//  Created by Bas van Kuijck on 27/10/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding {
    @MainActor
    public func onChange(_ handler: @escaping @Sendable (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
