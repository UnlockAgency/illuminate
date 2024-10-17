//
//  File.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import SwiftUI
import Introspect

extension View {
    public func compatibleCall(_ function: SwiftUICompatibilityFunction<Self>) -> some View {
        return AnyView(function.call(in: self))
    }
}

@MainActor
public struct SwiftUICompatibilityFunction<V: View> {
    
    @ViewBuilder
    let closure: (V) -> any View
    
    public init(@ViewBuilder closure: @escaping (V) -> any View) {
        self.closure = closure
    }
    
    @ViewBuilder
    func call(in view: V) -> any View {
        closure(view)
    }
}

extension SwiftUICompatibilityFunction {
    public static func scrollDisabled(_ disabled: Bool) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 16.0, *) {
                return view.scrollDisabled(disabled)
            }
            
            return view.introspectScrollView {
                $0.isScrollEnabled = !disabled
            }
        }
    }
    
    public static func returnKeyType(_ returnKeyType: UIReturnKeyType) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 15.0, *) {
                return view.submitLabel(returnKeyType.submitLabel)
            }
            return view.introspectTextField {
                $0.returnKeyType = returnKeyType
            }
        }
    }
    
    public static func listRowSeparator(_ visibility: Visibility) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 15.0, *) {
                return view.listRowSeparator(visibility.value)
            }
            
            return view
        }
    }
    
    public static func scrollContentBackground(_ visibility: Visibility) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 16.0, *) {
                return view.scrollContentBackground(visibility.value)
            }
            
            return view
        }
    }
    
    public static func tint(_ color: Color?) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 16.0, *) {
                view.tint(color)
            } else {
                view.introspect(selector: TargetViewSelector.siblingContaining) { (targetView: UIView) in
                    targetView.tintColor = color?.uiColor()
                }
            }
        }
    }
}

// Overrides iOS 15.0 Visibility Enum
public enum Visibility: CaseIterable {
    case automatic
    case visible
    case hidden
    
    @available(iOS 15.0, *)
    var value: SwiftUI.Visibility {
        switch self {
        case .automatic: return .automatic
        case .visible: return .visible
        case .hidden: return .hidden
        }
    }
}

@available(iOS 15.0, *)
private extension UIReturnKeyType {
    var submitLabel: SubmitLabel {
        switch self {
        case .done: return .done
        case .continue: return .continue
        case .go: return .go
        case .join: return .join
        case .next: return .next
        case .search: return .search
        case .send: return .send
        default: return .return
        }
    }
}
