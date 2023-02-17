//
//  ObservableScrollView.swift
//  Plein
//
//  Created by Bas van Kuijck on 28/10/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Introspect

/// A ScrollView wrapper that tracks scroll offset changes.
/// An explicit Combine approach is setup here, because using a @Published / @Binding variable
public struct ObservableScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let subject: CurrentValueSubject<CGFloat, Never>
    let content: () -> Content
    @State var cancellables: Set<AnyCancellable>
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        subject: CurrentValueSubject<CGFloat, Never>,
        cancellables: inout Set<AnyCancellable>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.subject = subject
        self.cancellables = cancellables
        self.content = content
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
        }
        .introspectScrollView { scrollView in
            scrollView.publisher(for: \.contentOffset)
                .map { axes == .horizontal ? $0.x : $0.y }
                .subscribe(subject)
                .store(in: &cancellables)
        }
    }
}
