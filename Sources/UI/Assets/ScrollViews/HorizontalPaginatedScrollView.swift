//
//  HorizontalPaginatedScrollView.swift
//  
//
//  Created by Bas van Kuijck on 21/02/2023.
//

import Foundation
import SwiftUI
import Introspect
import Combine

public struct HorizontalPaginatedScrollView<Content: View>: View {
    @Binding private var currentPage: Int
    private let content: () -> Content
    @State private var cancellable: AnyCancellable?
    
    public init(currentPage: Binding<Int>, content: @escaping () -> Content) {
        _currentPage = currentPage
        self.content = content
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            TabView(selection: $currentPage) {
                content()
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        } else {
            GeometryReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        content()
                    }
                }
                .introspectScrollView { scrollView in
                    scrollView.isPagingEnabled = true
                    cancellable = scrollView.publisher(for: \.contentOffset)
                        .map { Int(floor($0.x / reader.size.width)) }
                        .removeDuplicates()
                        .assign(to: \.currentPage, on: self) // swiftlint:disable:this combine_weak_assign
                }
            }
        }
    }
}
