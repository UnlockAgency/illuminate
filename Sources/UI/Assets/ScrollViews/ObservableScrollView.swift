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
    let subject: CurrentValueSubject<CGFloat, Never>
    let content: () -> Content
    @State var cancellables: Set<AnyCancellable>
    
    public init(
        subject: CurrentValueSubject<CGFloat, Never>,
        cancellables: inout Set<AnyCancellable>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.subject = subject
        self.cancellables = cancellables
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            content()
        }.introspectScrollView { scrollView in
            scrollView.publisher(for: \.contentOffset)
                .map { $0.y }
                .subscribe(subject)
                .store(in: &cancellables)
        }
    }
}
