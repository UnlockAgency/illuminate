//
//  Publisher+concurrency.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
@preconcurrency import Combine

public enum AsyncContinuationError: Error {
    case finishedWithoutValue
}

public extension Publisher where Failure == Never, Output: Sendable {
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

@available(iOS 15.0, *)
public extension Publisher {
    var first: Output {
        get async throws {
            for try await value in values {
                return value
            }
            throw AsyncContinuationError.finishedWithoutValue
        }
    }
}

public extension Publisher where Output: Sendable {
    /// This will transform any Publisher into a throwable async/await coroutine
    /// Combine -> async
    func async() async throws -> Output {
        if #available(iOS 15.0, *) {
            return try await first
        } else {
            switch await asyncResult() {
            case .failure(let error):
                throw error
            case .success(let value):
                return value
            }
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
public func withAsyncPublisher<Output: Sendable>(_ closure: @escaping @MainActor () async -> Output) -> AnyPublisher<Output, Never> {

    Just(())
        .flatMap { _ in
            return Future<Output, Never> { promise in
                nonisolated(unsafe) let promise = promise
                Task { @MainActor in
                    let output = await closure()
                    promise(.success(output))
                }
            }
        }
        .eraseToAnyPublisher()
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
public func withAsyncThrowingPublisher<Output: Sendable>(_ closure: @escaping @MainActor () async throws -> Output) -> AnyPublisher<Output, Swift.Error> {
    
    Just(())
        .setFailureType(to: Swift.Error.self)
        .flatMap { _ in
            return Future<Output, Swift.Error> { promise in
                nonisolated(unsafe) let promise = promise
                Task { @MainActor in
                    do {
                        let output = try await closure()
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
}
