//
//  PermissionService.swift
//  Plein
//
//  Created by Bas van Kuijck on 19/09/2022.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import Combine
import Logging

public enum PermissionType: String {
    case notifications
    case location
}

public enum PermissionStatus: String {
    case pending
    case declined
    case granted
}

public protocol PermissionService: AnyObject {
    var logger: Logger? { get set }
    func hasRequestedPermission(for type: PermissionType) -> Bool
    func requestPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never>
    func getPermission(for type: PermissionType) -> AnyPublisher<PermissionStatus, Never>
}
