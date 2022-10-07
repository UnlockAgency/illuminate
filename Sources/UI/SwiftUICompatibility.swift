//
//  File.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import SwiftUI
import Introspect

extension View {
    public func compatibleCall(_ function: SwiftUICompatibility<Self>.Function) -> some View {
        return SwiftUICompatibility.call(function, withView: self)
    }
}

struct SwiftUICompatibility<Content: View> {
    
    public enum Function {
        case listRowSeparator(_ visibility: Visibility)
        case scrollContentBackground(_ visibility: Visibility)
        case scrollDisabled(_ disabled: Bool)
    }
    
    @available(*, unavailable, message: "SwiftUICompatibility is not supposed to be used as an instance")
    init() {
        fatalError("SwiftUICompatibility is not supposed to be used as an instance")
    }
    
    @ViewBuilder
    fileprivate static func call(_ function: Function, withView view: Content) -> some View {
        switch function {
        case .listRowSeparator(let visibility):
            listRowSeparator(view, visibility)
        case .scrollContentBackground(let visibility):
            scrollContentBackground(view, visibility)
        case .scrollDisabled(let disabled):
            scrollDisabled(view, disabled)
        }
    }
    
    private static func listRowSeparator(_ view: Content, _ visibility: Visibility) -> some View {
        if #available(iOS 15.0, *) {
            return view.listRowSeparator(visibility.value)
        }
        
        return view
    }
    
    private static func scrollContentBackground(_ view: Content, _ visibility: Visibility) -> some View {
        if #available(iOS 16.0, *) {
            return view.scrollContentBackground(visibility.value)
        }
        
        return view
    }
    
    private static func scrollDisabled(_ view: Content, _ disabled: Bool) -> some View {
        if #available(iOS 16.0, *) {
            return view.scrollDisabled(disabled)
        }
        
        return view.introspectScrollView {
            $0.isScrollEnabled = !disabled
        }
    }
}

extension SwiftUICompatibility {
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
}
