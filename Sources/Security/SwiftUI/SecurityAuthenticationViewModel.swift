//
//  SecurityAuthenticationViewModel.swift
//  
//
//  Created by Thomas Roovers on 05/10/2022.
//

import Combine

public enum AuthenticationResult: Int {
    case pending
    case successful
    case failed
    case cancelled
    case fallback
}

public protocol SecurityAuthenticationViewModel {
    var result: AnyPublisher<AuthenticationResult, Never> { get set }
}
