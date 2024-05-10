//
//  SwiftUICompatibilityFunction+TextField.swift
//
//
//  Created by Bas van Kuijck on 25/04/2024.
//

import Foundation
import SwiftUI

extension SwiftUICompatibilityFunction {
    public static func onSubmit(_ handler: @escaping () -> Void) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 15.0, *) {
                return view.onSubmit(handler)
            }
            return view
        }
    }
}
