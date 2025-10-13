//
//  ObservableScrollView.swift
//  Plein
//
//  Created by Bas van Kuijck on 28/10/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI

private struct OffsetPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // ...
    }
}

/// A ScrollView wrapper that tracks scroll offset changes.
public struct ObservableScrollView<Content: View>: View {
    private let coordinateSpaceName = "frameLayer"
    
    let axes: Axis.Set
    let showsIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: () -> Content
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offset: Binding<CGFloat>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        _contentOffset = offset
        self.content = content
    }
    
    public var body: some View {
        if #available(iOS 18.0, *) {
            ScrollView(axes, showsIndicators: showsIndicators) {
                content()
            }
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.y
            } action: { oldValue, newValue in
                if newValue != oldValue {
                    contentOffset = -newValue
                }
            }
        } else {
            ScrollView {
                offsetReader
                content().padding(.top, -8)
            }
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(OffsetPreferenceKey.self) { newValue in
                Task { @MainActor in
                    contentOffset = newValue
                }
            }
        }
    }
    
    private var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: (axes == .vertical ? proxy.frame(in: .named(coordinateSpaceName)).minY : proxy.frame(in: .named(coordinateSpaceName)).minX)
                )
        }
        .frame(height: 0)
    }
}
