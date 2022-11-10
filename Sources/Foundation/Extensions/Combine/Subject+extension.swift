//
//  Subject+extension.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import Combine

public extension Subject {
    func asSubscriber(demand: Subscribers.Demand = .unlimited) -> AnySubscriber<Output, Failure> {
        AnySubscriber<Output, Failure>(receiveValue: { [weak self] value in
            self?.send(value)
            return demand
        })
    }
}
