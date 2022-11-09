//
//  Memoization.swift
//  Plein
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public func memoize<T>(_ object: AnyObject, key: UnsafeRawPointer, lazyCreateClosure: () -> T) -> T {
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
