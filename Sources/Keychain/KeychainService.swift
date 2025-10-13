//
//  KeychainService.swift
//
//  Created by Thomas Roovers on 25/08/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation

public protocol KeychainsService {
    func instance(service: String) -> KeychainService
}

public protocol KeychainService {
    func set(_ data: Data, key: String) throws
    func getData(_ key: String) throws -> Data?
    func remove(_ key: String) throws
}
