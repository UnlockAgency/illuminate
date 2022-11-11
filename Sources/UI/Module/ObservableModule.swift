//
//  ObservableModule.swift
//  
//
//  Created by Thomas Roovers on 06/10/2022.
//

import Foundation
import SwiftUI
import Dysprosium
import Combine
import IlluminateFoundation

public final class ObservableModule<T>: ObservableObject, DysprosiumCompatible, CustomDebugStringConvertible {
    
    @Published public var loadingState: LoadingState
    @Published public var result: T
    @Published public var error: Error?
    
    public init(initialValue result: T, loadingState: LoadingState = .notLoading) {
        self.result = result
        self.loadingState = loadingState
    }
    
    public func perform(_ task: @escaping () async throws -> T) {
        Task { @MainActor in
            await perform(task)
        }
    }
    
    public func perform<P: Publisher>(_ task: P) where P.Output == T {
        perform(task.async)
    }
    
    public func perform<P: Publisher>(_ task: P) async where P.Output == T {
        await perform {
            try await task.async()
        }
    }
    
    public func perform(withLoadingState startLoadingState: LoadingState? = nil, _ task: @escaping () async throws -> T) async {
        setError(nil)
        
        if let startLoadingState {
            setLoadingState(startLoadingState)
            
        } else if let emptyAble = result as? Emptyable, emptyAble.isNotEmpty {
            setLoadingState(.updating)
            
        } else {
            setLoadingState(.loading)
        }
                    
        do {
            setResult(try await task())
        } catch let resultError {
            print("[Illuminate UI] Error getting '\(T.self)': \(resultError)")
            setError(resultError)
        }
        setLoadingState(.notLoading)
    }
    
    public func setResult(_ result: T) {
        Task { @MainActor in
            self.result = result
            self.objectWillChange.send()
        }
    }
    
    private func setLoadingState(_ loadingState: LoadingState) {
        Task { @MainActor in
            self.loadingState = loadingState
            self.objectWillChange.send()
        }
    }
    
    private func setError(_ error: Error?) {
        Task { @MainActor in
            self.error = error
            self.objectWillChange.send()
        }
    }
    
    public var debugDescription: String {
        return "<Module<\(T.self)>> [ result: \(result), error: \(String(describing: error)), loadingState: \(loadingState) ]"
    }
    
    deinit {
        deallocated()
    }
}
