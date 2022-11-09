//
//  NotificationError.swift
//  
//
//  Created by Bas van Kuijck on 09/11/2022.
//

import Foundation

public struct NotificationError: Error {
    public let underlyingError: Error?
    
    public init(error: Error?) {
        self.underlyingError = error
    }
    
}
