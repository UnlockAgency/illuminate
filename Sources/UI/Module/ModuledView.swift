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
import IlluminateUI_Helpers

#if canImport(UIKit)
import UIKit
#endif

public protocol ModuledViewErrorStateable {
    init(error: Error, onRetry: (() -> Void)?)
}

public protocol ModuledViewUpdateStateable {
    init()
}

public class ModuledViewSettings {
    public static var errorStateType: ModuledViewErrorStateable.Type?
    public static var updateStateType: ModuledViewUpdateStateable.Type?
}

public struct ModuledView<Result, Content: View>: View {
    
    @ObservedObject private var module: ObservableModule<Result>

    private let content: (Result) -> Content
    private let onReload: (() -> Void)?
    private let errorState: ((Error, (() -> Void)?) -> any View)?
    private let updateState: (() -> any View)?
    
    public init(
        _ module: ObservableModule<Result>,
        @ViewBuilder content: @escaping (Result) -> Content,
        errorState: ((Error, (() -> Void)?) -> any View)? = nil,
        updateState: (() -> any View)? = nil,
        onReload: (() -> Void)? = nil
    ) {
        self.module = module
        self.errorState = errorState
        self.updateState = updateState
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
                        if let eView = errorView(error: error) {
                            eView
                        }
                    }.frame(maxWidth: .infinity)
                    
                } else {
                    content(module.result)
                }
            }
            .if(module.loadingState == .updating) {
                $0.allowsHitTesting(false)
                    .opacity(0.2)
                    .overlay(updatingView() ?? AnyView(EmptyView()), alignment: .top)
            }
        }
    }
    
    private func errorView(error: Error) -> AnyView? {
        if let errorView = errorState {
            return AnyView(errorView(error, onReload))
            
        } else if let errorViewType = ModuledViewSettings.errorStateType, let errorView = errorViewType.init(error: error, onRetry: onReload) as? (any View) {
            return AnyView(errorView)
            
        } else {
            return nil
        }
    }
    
    private func updatingView() -> AnyView? {
        if let updateView = updateState {
            return AnyView(updateView())
        } else if let updateViewType = ModuledViewSettings.updateStateType, let updateView = updateViewType.init() as? (any View) {
            return AnyView(updateView)
        } else {
            return nil
        }
    }
}

// MARK: - Previews
// --------------------------------------------------------

#if !TESTING
struct ModuleView_Previews: PreviewProvider {
    
    private struct ErrorView: View, ModuledViewErrorStateable {
        let error: Error
        let onRetry: (() -> Void)?
        
        init(error: Error, onRetry: (() -> Void)?) {
            self.error = error
            self.onRetry = onRetry
        }
        
        var body: some View {
            VStack {
                Text(error.localizedDescription)
                if let onRetry {
                    Button("Retry", action: onRetry)
                }
            }
        }
    }
    
    static var loadingModule: ObservableModule<String> {
        ModuledViewSettings.errorStateType = ErrorView.self
        return ObservableModule<String>(
            initialValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            loadingState: .loading
        )
    }
    
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
