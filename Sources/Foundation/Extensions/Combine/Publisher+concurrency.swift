//
//  Publisher+concurrency.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import Combine

public extension Publisher where Failure == Never {
    /// This will transform any Publisher into a async/await coroutine
    /// Combine -> async
    func async() async -> Output {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = sink { obj in
                continuation.resume(returning: obj)
                cancellable?.cancel()
            }
        }
    }
}

public extension Publisher {
    /// This will transform any Publisher into a throwable async/await coroutine
    /// Combine -> async
    func async() async throws -> Output {
        switch await asyncResult() {
        case .failure(let error):
            throw error
        case .success(let value):
            return value
        }
    }
    
    /// This will transform any Publisher into a async/await coroutine.
    /// Using a `Result` will keep the Failure type
    /// Combine -> async
    ///
    /// - Returns: `Result<Output, Failure>`
    func asyncResult() async -> Result<Output, Failure> {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = sink { completion in
                if case let .failure(error) = completion {
                    continuation.resume(returning: .failure(error))
                }
                cancellable?.cancel()
            } receiveValue: { obj in
                continuation.resume(returning: .success(obj))
            }
        }
    }
    
    /// Use a async coroutine in a combine publisher sequence, allowing it to throw errors
    /// async -> Combine
    func tryAsyncMap<T>(_ transform: @escaping (Output) async throws -> T) -> AnyPublisher<T, Swift.Error> {
        mapError { $0 as Swift.Error }
        .flatMap { value in
            Future { promise in
                Task { @MainActor in
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                        
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Use a async coroutine in a combine publisher sequence
    /// async -> Combine
    func asyncMap<T>(_ transform: @escaping (Output) async -> T) -> AnyPublisher<T, Failure> {
        flatMap { value -> Future<T, Failure> in
            Future { promise in
                Task { @MainActor in
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

/// Can be used to convert a async sequence to a Combine sequence
///
/// Example:
///
/// ```
/// withAsyncPublisher {
///     let someValue = await someAsyncMethod()
/// }.sink {
///     // ...
/// }
/// ```
///
/// - Returns: `AnyPublisher<Output, Never>`
public func withAsyncPublisher<Output>(_ closure: @escaping () async -> Output) -> AnyPublisher<Output, Never> {
    Just(())
        .asyncMap { _ -> Output in
            await closure()
        }
}

/// Can be used to convert a async sequence to a throwing Combine sequence
///
/// Example:
///
/// ```
/// withAsyncThrowingPublisher {
///     let someValue = try await someAsyncMethod()
/// }.sink {
///     // ...
/// }
/// ```
///
/// - Returns: `AnyPublisher<Output, Swift.Error>`
public func withAsyncThrowingPublisher<Output>(_ closure: @escaping () async throws -> Output) -> AnyPublisher<Output, Swift.Error> {
    Just(())
        .setFailureType(to: Swift.Error.self)
        .tryAsyncMap { _ -> Output in
            try await closure()
        }
}
