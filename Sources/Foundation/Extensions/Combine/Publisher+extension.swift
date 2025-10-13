//
//  Publisher+extension.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
@preconcurrency import Combine
import UIKit

private enum TimeoutValue<T> {
    case element(T)
    case timeout
}

public extension Publisher where Failure == Never, Output: Sendable {
    func mainSink(_ receivedValue: @escaping @MainActor (Output) -> Void) -> AnyCancellable {
        sink { value in
            Task { @MainActor in
                receivedValue(value)
            }
        }
    }
}

public extension Publisher {
    func withUnretained<Object: AnyObject>(_ obj: Object) -> AnyPublisher<(Object, Output), Failure> {
        flatMap { [weak obj] value -> AnyPublisher<(Object, Output), Failure> in
            guard let obj else {
                return AnyPublisher<(Object, Output), Failure>.never()
            }
            return Just((obj, value)).setFailureType(to: Failure.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    func use(_ handler: @escaping (Output) -> Void) -> AnyPublisher<Output, Failure> {
        map { element in
            handler(element)
            return element
        }.eraseToAnyPublisher()
    }
}

public extension AnyPublisher {
    static func never() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: false, outputType: Output.self, failureType: Failure.self).eraseToAnyPublisher()
    }
}

public extension Publisher where Output == String? {
    var orEmpty: Publishers.Map<Self, String> {
        return map { $0 ?? "" }
    }
}
