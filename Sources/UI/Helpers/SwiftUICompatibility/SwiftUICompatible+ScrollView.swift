//
//  SwiftUICompatible+ScrollView.swift
//
//
//  Created by Bas van Kuijck on 23/04/2024.
//

import Foundation
import Introspect
import SwiftUI

public enum CompatibleScrollDismissesKeyboardMode: Int {
    case automatic
    case interactively
    case immediately
    case never
    
    @available(iOS 16.0, *)
    var value: ScrollDismissesKeyboardMode {
        switch self {
        case .automatic: return .automatic
        case .interactively: return .interactively
        case .immediately: return .immediately
        case .never: return .never
        }
    }
    
    var preIOS16Value: UIScrollView.KeyboardDismissMode {
        switch self {
        case .automatic: return .interactive
        case .interactively: return .interactive
        case .immediately: return .onDrag
        case .never: return .none
        }
    }
}

extension SwiftUICompatibilityFunction {
    public static func scrollPosition(id: Binding<(some Hashable)?>) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 17.0, *) {
                view.scrollPosition(id: id)
            } else {
                view
            }
        }
    }
    
    public static func scrollDismissesKeyboard(_ value: CompatibleScrollDismissesKeyboardMode) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 16.0, *) {
                view.scrollDismissesKeyboard(value.value)
            } else {
                view.introspectScrollView { scrollView in
                    scrollView.keyboardDismissMode = value.preIOS16Value
                }
            }
        }
    }
}
