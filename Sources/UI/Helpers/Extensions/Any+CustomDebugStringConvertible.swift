//
//  Any+CustomDebugStringConvertible.swift
//  Plein
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import UIKit
import WebKit

extension UIApplication.State: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .active:
            return "active"
        case .inactive:
            return "inactive"
        case .background:
            return "background"
        @unknown default:
            return "\(rawValue)"
        }
    }
}

extension WKNavigationType: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .backForward:
            return "backForward"
        case .formResubmitted:
            return "formResubmitted"
        case .formSubmitted:
            return "formSubmitted"
        case .linkActivated:
            return "linkActivated"
        case .other:
            return "other"
        case .reload:
            return "reload"
        @unknown default:
            return "\(rawValue)"
        }
    }
}

extension UIUserInterfaceStyle: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unspecified:
            return "unspecified"
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "\(rawValue)"
        }
    }
}
