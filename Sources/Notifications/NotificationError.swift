//
//  NotificationError.swift
//  
//
//  Created by Bas van Kuijck on 09/11/2022.
//

import Foundation

public struct NotificationError: Error {
    
    public static let postpone = NotificationError(code: 721)
    
    public let underlyingError: Error?
    public let code: Int
    
    public init(code: Int = 0, error: Error? = nil) {
        self.underlyingError = error
        self.code = 0
    }
    
}
