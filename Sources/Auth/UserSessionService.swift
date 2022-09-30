//
//  UserSessionService.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

import Combine

public protocol UserSessionService {
    
    /// Sign the user in
    /// - Parameter authenticatable: `Authenticatable`
    func didLogin<T: Authenticatable>(_ authenticatable: T)
    
    /// Check if the current user of the app is signed in
    /// - Returns: `Bool`
    func isLoggedIn() -> Bool
    
    /// Sign the current logged in user out of the app
    /// - Returns: `AnyPublisher<Void, Never>`
    func logout() -> AnyPublisher<Void, Never>
    
    func store<T: Authenticatable>(_ authenticatable: T)
    
    func clear()
}
