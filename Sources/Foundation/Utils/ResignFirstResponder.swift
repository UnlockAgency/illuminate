//
//  ResignFirstResponder.swift
//  
//
//  Created by Bas van Kuijck on 09/11/2022.
//

import Foundation
import UIKit

@MainActor
public func resignFirstResponder() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
