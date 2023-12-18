//
//  Injected.swift
//
//
//  Created by Bas van Kuijck on 2022/06/23.
//

import Foundation
import Swinject

private func memoize<T>(_ object: Any, key: UnsafeRawPointer, lazyCreateClosure: () -> T) -> T {
    objc_sync_enter(object)
    defer {
        objc_sync_exit(object)
    }
    if let instance = objc_getAssociatedObject(object, key) as? T {
        return instance
    }

    let instance = lazyCreateClosure()
    objc_setAssociatedObject(object, key, instance, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return instance
}

private var resolverKey: UInt8 = 0

public class InjectSettings {
    public static var resolver: Resolver {
        memoize(self, key: &resolverKey) {
            return Container().synchronize()
        }
    }
}

/// Wrapped dependent service is not resolved until service is accessed.
@propertyWrapper
public struct LazyInjected<Service> {
    private(set) var resolver: Resolver
    private var service: Service?
    
    public let name: String?
    
    public var wrappedValue: Service {
        mutating get {
            objc_sync_enter(resolver)
            defer {
                objc_sync_exit(resolver)
            }
            if let service {
                return service
                
            } else if let value = resolver.resolve(Service.self, name: name) {
                service = value
                return value
                
            } else {
                fatalError("Cannot resolve type '\(Service.self)' with name '\(name ?? "(nil)")'")
            }
        }
        mutating set {
            objc_sync_enter(resolver)
            defer {
                objc_sync_exit(resolver)
            }
            service = newValue
        }
    }
    
    public var projectedValue: Self {
        get { return self }
        mutating set { self = newValue }
    }
    
    public init(resolver: Resolver = InjectSettings.resolver, name: String? = nil) {
        self.resolver = resolver
        self.name = name
    }
}

/// Wrapped dependent service is resolved immediately upon struct initialization.
@propertyWrapper
public struct Injected<Service> {
    public var wrappedValue: Service
    
    public var projectedValue: Self {
        get { return self }
        mutating set { self = newValue }
    }
    
    public init(resolver: Resolver = InjectSettings.resolver, name: String? = nil) {
        if let value = resolver.resolve(Service.self, name: name) {
            wrappedValue = value
            
        } else {
            fatalError("Cannot resolve type '\(Service.self)' with name '\(name ?? "(nil)")'")
        }
    }
}
