//
//  Authenticatable.swift
//  
//
//  Created by Thomas Roovers on 30/09/2022.
//

public protocol Authenticatable {
    
    associatedtype ID
    
    var id: ID { get set }
}
