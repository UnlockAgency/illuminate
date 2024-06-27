//
//  KeyboardAvoiding.swift
//
//
//  Created by Bas van Kuijck on 29/05/2024.
//

import Foundation
import SwiftUI
import Combine

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return Publishers.Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

@available(iOS 15.0, *)
public struct KeyboardAvoiding: ViewModifier {
    @State private var keyboardActiveAdjustment: CGFloat = 0
    public let padding: CGFloat
    
    public init(padding: CGFloat? = nil) {
        self.padding = padding ?? 36
    }
    
    public func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: keyboardActiveAdjustment) {
                EmptyView().frame(height: 0)
            }
            .onReceive(Publishers.keyboardHeight) {
                self.keyboardActiveAdjustment = min($0, padding)
            }
    }
}

public extension View {
    @ViewBuilder
    func keyboardAvoiding(padding: CGFloat? = nil) -> some View {
        if #available(iOS 15.0, *) {
            modifier(KeyboardAvoiding(padding: padding))
        } else {
            self
        }
    }
}
