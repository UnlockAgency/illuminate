//
//  ViewModelControllable.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public protocol ViewModalable: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
    init()
}

public protocol ViewModelControllable {
    associatedtype ViewModelType: ViewModalable

    var viewModel: ViewModelType { get }
    init(viewModel: ViewModelType)
}

nonisolated(unsafe) private var viewModelControllableKey: UInt8 = 0

public extension ViewModelControllable {
    var viewModel: ViewModelType {
        get {
            guard let model = objc_getAssociatedObject(self, &viewModelControllableKey) as? ViewModelType else {
                fatalError("Cannot find \(ViewModelType.self) for \(self)")
            }
            return model
        }

        set {
            objc_setAssociatedObject(self, &viewModelControllableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
