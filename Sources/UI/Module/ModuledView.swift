//
//  ModuledView.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import Foundation
import SwiftUI
import Introspect
import Combine
import IlluminateUI_Assets

#if canImport(UIKit)
import UIKit
#endif

public struct ModuledView<Result, Content: View>: View {
    
    @ObservedObject private var module: ObservableModule<Result>

    private let content: (Result) -> Content
    private let onReload: (() -> Void)?
    
    public init(
        _ module: ObservableModule<Result>,
        @ViewBuilder content: @escaping (Result) -> Content,
        onReload: (() -> Void)? = nil
    ) {
        self.module = module
        self.content = content
        self.onReload = onReload
    }
    
    public var body: some View {
        if module.loadingState == .loading {
            ZStack {
                Spinner()
                    .frame(width: 24, height: 24)
            }
            .frame(maxWidth: .infinity)
            
        } else {
            Group {
                if let error = module.error {
                    ZStack {
                       // ErrorStateView(error: error, onRetry: onReload)
                    }.frame(maxWidth: .infinity)
                    
                } else {
                    content(module.result)
                }
            }
//            .if(module.loadingState == .updating) {
//                $0.allowsHitTesting(false)
//                    .opacity(0.2)
//                    .overlay(UpdatingView(), alignment: .top)
//            }
        }
    }
}

extension ModuledView {
    struct UpdatingView: View {
        var body: some View {
            ZStack {
                Circle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 0)
                    .frame(width: 44, height: 44)
                
                Spinner()
                    .frame(width: 24, height: 24)
            }
//            .padding(.top, D.Content.padding * 2)
        }
    }
}

extension ModuledView {
    struct ErrorStateView: View {
        let error: Error
        let onRetry: () -> Void
        
        var body: some View {
            Text("Error")
        }
    }
}

// MARK: - Previews
// --------------------------------------------------------

#if !TESTING
struct ModuleView_Previews: PreviewProvider {
    static var loadingModule = ObservableModule<String>(
        initialValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        loadingState: .loading
    )
    
    static var updatingModule = ObservableModule<String>(
        initialValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        loadingState: .updating
    )
    
    static var notLoadingModule = ObservableModule<String>(
        initialValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
        loadingState: .notLoading
    )
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModuledView(loadingModule) { obj in
                    Group {
                        Text(obj)
                    }
                    .padding()
                    .background(
                        Rectangle().fill(.blue)
                    )
                }
                
                ModuledView(notLoadingModule) { obj in
                    Group {
                        Text(obj)
                    }
                    .padding()
                    .background(
                        Rectangle().fill(.blue)
                    )
                }
                
                ModuledView(updatingModule) { obj in
                    Group {
                        Text(obj)
                    }
                    .padding()
                    .background(
                        Rectangle().fill(.blue)
                    )
                }
                
                Spacer()
            }.padding().previewDevice("iPhone 13 mini")
        }
    }
}
#endif
