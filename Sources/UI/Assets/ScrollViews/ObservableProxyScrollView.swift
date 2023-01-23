//
//  ObservableProxyScrollView.swift
//  Plein
//
//  Created by Bas van Kuijck on 28/10/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import SwiftUI
import Introspect

public struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue = CGFloat.zero
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

/// A ScrollView wrapper that tracks scroll offset changes and allows the underlying view to scroll to a specific point
@available(iOS 14.0, *)
public struct ObservableProxyScrollView<Content, Key>: View where Content: View, Key: PreferenceKey, Key.Value == CGFloat {
    @Namespace private var scrollSpace
    
    @Binding private var scrollOffset: CGFloat
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: (ScrollViewProxy) -> Content
    private let isPaginated: Bool
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        key: Key.Type,
        scrollOffset: Binding<CGFloat>,
        isPaginated: Bool = false,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> Content
    ) {
        _scrollOffset = scrollOffset
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.isPaginated = isPaginated
        self.content = content
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ScrollViewReader { proxy in
                content(proxy)
                    .background(GeometryReader { geo in
                        let frame = geo.frame(in: .named(scrollSpace))
                        Color.clear
                            .preference(key: Key.self, value: axes == .horizontal ? -frame.minX : -frame.minY)
                    })
            }
        }
        .introspectScrollView { $0.isPagingEnabled = isPaginated }
        .coordinateSpace(name: scrollSpace)
        .onPreferenceChange(Key.self) { value in
            scrollOffset = value
        }
    }
}
