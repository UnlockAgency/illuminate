//
//  NotificationTopicType.swift
//  
//
//  Created by Bas van Kuijck on 09/11/2022.
//

import Foundation

public protocol NotificationTopicType: Codable, Equatable {
    var name: String { get }
}
