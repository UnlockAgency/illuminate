//
//  CompatibleLazyStack.swift
//
//
//  Created by Thomas Roovers on 25/08/2022.

import Foundation
import SwiftUI

@available(iOS, obsoleted: 15.0, message: "Use `LazyHStack` instead")
public struct CompatibleLazyHStack<Content: View>: View {
    private let content: Content
    private let alignment: VerticalAlignment
    private let spacing: CGFloat?
    
    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            LazyHStack(alignment: alignment, spacing: spacing) {
                content
            }.frame(maxWidth: .infinity)
        } else {
            HStack(alignment: alignment, spacing: spacing) {
                content
            }.frame(maxWidth: .infinity)
        }
    }
}

@available(iOS, obsoleted: 15.0, message: "Use `LazyVStack` instead")
public struct CompatibleLazyVStack<Content: View>: View {
    private let content: Content
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            LazyVStack(alignment: alignment, spacing: spacing) {
                content
            }
        } else {
            VStack(alignment: alignment, spacing: spacing) {
                content
            }
        }
    }
}
