//
//  FlowStack.swift
//
//
//  Created by Bas van Kuijck on 26/10/2022.

import Foundation
import SwiftUI

/// A sort of tag cloud view
/// Refactored from https://github.com/globulus/swiftui-flow-layout
public struct FlowStack<Item, ItemView: View>: View {
    private let items: [Item]
    private let spacing: CGFloat
    private let alignment: Alignment
    @ViewBuilder private let factory: (Item) -> ItemView
    
    @State private var totalHeight: CGFloat
    
    public init(
        items: [Item],
        alignment: Alignment = .topLeading,
        spacing: CGFloat = 12,
        @ViewBuilder factory: @escaping (Item) -> ItemView
    ) {
        self.items = items
        self.spacing = spacing
        self.factory = factory
        self.alignment = alignment
        totalHeight = 0
    }
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                content(in: geometry)
            }
        }
        .frame(height: totalHeight)
        .padding([.bottom, .trailing], -spacing)
    }
    
    private var verticalAlignment: VerticalAlignment {
        var value: VerticalAlignment = .top
        
        if alignment == .leading || alignment == .trailing || alignment == .center {
            value = .center
        } else if alignment == .bottom || alignment == .bottomLeading || alignment == .bottomTrailing {
            value = .bottom
        }
        
        return value
    }
    
    private var horizontalAlignment: HorizontalAlignment {
        var value: HorizontalAlignment = .center
        
        if alignment == .topLeading || alignment == .leading || alignment == .bottomLeading {
            value = .leading
        } else if alignment == .topTrailing || alignment == .trailing || alignment == .bottomTrailing {
            value = .trailing
        }
        
        return value
    }
    
    @MainActor
    @ViewBuilder
    private func content(in proxy: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var lastHeight = CGFloat.zero
        let itemCount = items.count
        
        ZStack(alignment: alignment) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                factory(item)
                    .padding([horizontalAlignment == .trailing ? .leading : .trailing, verticalAlignment == .bottom ? .top : .bottom], spacing)
                    .alignmentGuide(horizontalAlignment) { viewDimension in
                        if abs(width - viewDimension.width) > proxy.size.width {
                            width = 0
                            height -= lastHeight
                        }
                        lastHeight = viewDimension.height
                        let result = width
                        if index == itemCount - 1 {
                            width = 0
                        } else {
                            width -= viewDimension.width
                        }
                        return result
                    }
                    .alignmentGuide(verticalAlignment) { _ in
                        let result = height
                        if index == itemCount - 1 {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(HeightReaderView(binding: $totalHeight))
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        
    }
}

private struct HeightReaderView: View {
    @Binding var binding: CGFloat
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: geo.frame(in: .local).size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            Task { @MainActor in
                binding = height
            }
        }
    }
}

// MARK: - Previews
// --------------------------------------------------------
#if !TESTING && !RELEASE
struct FlowStack_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FlowStack(
                items: ["Some long item here", "1", "2", "And then some longer one",
                        "Short", "Items", "Here", "And", "A", "Few", "More"]
            ) {
                Text($0)
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(.gray))
            }.padding()
            Spacer()
        }
    }
}
#endif
