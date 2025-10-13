//
//  Task+extension.swift
//
//  Created by Bas van Kuijck on 07/09/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    public static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
