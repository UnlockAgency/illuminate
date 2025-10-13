//
//  GridView.swift
//
//  Created by Bas van Kuijck on 21/09/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI

private extension Array {
    func chunk(_ size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public struct GridView<Item, Content: View>: View {
    private struct Chunk {
        let items: [Item]
    }
    
    private let chunks: [Chunk]
    private let builder: (Item) -> Content
    private let columns: Int
    private let spacing: CGFloat
    
    public init(
        items: [Item],
        spacing: CGFloat = 12,
        columns: Int,
        @ViewBuilder builder: @escaping (Item) -> Content
    ) {
        self.chunks = items.chunk(columns).map { Chunk(items: $0) }
        self.columns = columns
        self.spacing = spacing
        self.builder = builder
    }
    
    public var body: some View {
        CompatibleLazyVStack(alignment: .leading, spacing: spacing) {
            ForEach(Array(chunks.enumerated()), id: \.offset) { _, chunk in
                itemsView(chunk.items)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.animation(nil)
    }
    
    private func itemsView(_ items: [Item]) -> some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                builder(item)
                    .animation(nil)
            }
            
            // Fill up the empty views, so that any preceeding cell views will not fill up the entire space
            ForEach(Array(items.count..<columns), id: \.self) { _ in
                Rectangle().foregroundColor(.clear)
            }
        }
    }
}
