//
//  LoadingState.swift
//  
//
//  Created by Bas van Kuijck on 11/11/2022.
//

import Foundation

public enum LoadingState: String, Sendable {
    case loading
    case notLoading
    case updating
    
    public var isBusy: Bool {
        return self != .notLoading
    }
}
