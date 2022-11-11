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

public typealias ModuledViewSettingsErrorState = ((Error, (() -> Void)?) -> any View)
public typealias ModuledViewSettingsLoadingState = (() -> any View)

public class ModuledViewSettings {
    public static var errorState: ModuledViewSettingsErrorState?
    public static var updateState: ModuledViewSettingsLoadingState?
    public static var loadingState: ModuledViewSettingsLoadingState?
}

public struct ModuledView<Result, Content: View>: View {
    
    @ObservedObject private var module: ObservableModule<Result>

    private let content: (Result) -> Content
    private let onReload: (() -> Void)?
    private let errorState: ModuledViewSettingsErrorState?
    private let updateState: ModuledViewSettingsLoadingState?
    private let loadingState: ModuledViewSettingsLoadingState?
    
    public init(
        _ module: ObservableModule<Result>,
        @ViewBuilder content: @escaping (Result) -> Content,
        loadingState: ModuledViewSettingsLoadingState? = ModuledViewSettings.loadingState,
        updateState: ModuledViewSettingsLoadingState? = ModuledViewSettings.updateState,
        errorState: ModuledViewSettingsErrorState? = ModuledViewSettings.errorState,
        onReload: (() -> Void)? = nil
    ) {
        self.module = module
        self.errorState = errorState
        self.updateState = updateState
        self.loadingState = loadingState
        self.content = content
        self.onReload = onReload
    }
    
    public var body: some View {
        if module.loadingState == .loading {
            ZStack {
                loadingView() ?? AnyView(EmptyView())
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
            
        } else {
            return nil
        }
    }
    
    private func updatingView() -> AnyView? {
        if let updateView = updateState {
            return AnyView(updateView())
            
        } else {
            return nil
        }
    }
    
    private func loadingView() -> AnyView? {
        if let loadView = loadingState {
            return AnyView(loadView())
            
        } else {
            return nil
        }
    }
}

// MARK: - Previews
// --------------------------------------------------------

#if !TESTING
struct ModuleView_Previews: PreviewProvider {
    
    private struct ErrorView: View {
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
    
    static var loadingModule = ObservableModule<String>(
        initialValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        loadingState: .loading
    )
    
    static var errorModule: ObservableModule<String> {
        ModuledViewSettings.errorState = { error, onReload in
            ErrorView(error: error, onRetry: onReload)
        }
        
        let module = ObservableModule<String>(
            initialValue: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            loadingState: .loading
        )
        module.error = NSError()
        return module
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
                
                ModuledView(errorModule) { _ in
                    
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
