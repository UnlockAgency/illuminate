//
//  View+colors.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    public func foregroundColor(_ uiColor: UIColor) -> some View {
        foregroundColor(Color(uiColor))
    }
    
    public func background(_ uiColor: UIColor) -> some View {
        background(Color(uiColor))
    }
}
