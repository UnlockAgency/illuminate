//
//  Publisher+concurrency.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    
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
}

func withAsyncThrowingPublisher<Output>(_ closure: @escaping () async throws -> Output) -> AnyPublisher<Output, Swift.Error> {
    Just(())
        .setFailureType(to: Swift.Error.self)
        .tryAsyncMap { _ -> Output in
            try await closure()
        }
}
