//
//  BackgroundProcessService.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation

public protocol BackgroundProcessService {
    func cancelBackgroundTask(identifier: String)
    func registerBackgroundTask(identifier: String, interval: TimeInterval, handler: @escaping (@escaping (Error?) -> Void) -> Void)
}

public extension BackgroundProcessService {
    func registerBackgroundTask(identifier: String, interval: TimeInterval = 3600, handler: @escaping (@escaping (Error?) -> Void) -> Void) {
        registerBackgroundTask(identifier: identifier, interval: interval, handler: handler)
    }
}
