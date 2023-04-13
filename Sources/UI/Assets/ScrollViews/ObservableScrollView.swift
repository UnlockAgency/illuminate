//
//  ObservableScrollView.swift
//  Plein
//
//  Created by Bas van Kuijck on 28/10/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import SwiftUI

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
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
        ScrollView {
            offsetReader
            content().padding(.top, -8)
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onPreferenceChange(OffsetPreferenceKey.self) { newValue in
            contentOffset = newValue
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
