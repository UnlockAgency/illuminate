//
//  UIColor+helpers.swift
//
//  Created by Bas van Kuijck on 2022/06/23.
//  Copyright © 2022 E-sites. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let components = (
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat((hex >> 0) & 0xff) / 255
        )
        self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha)
    }
    
    convenience init(hexString: String) {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.removeFirst()
        }
        
        if cString.count != 6 {
            self.init(hex: 0x000000)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /// Returns the RGB hex string (FFFFFF) of that specific color
    /// - Returns: `String`
    var hexString: String {
        guard let comp = cgColor.components else {
            return "FFFFFF"
        }

        let components = (comp.count == 4 ? comp : [comp[0], comp[0], comp[0], comp[1]]).map { Int($0 * 255.0) }
        return String(format: "%02X%02X%02X", components[0], components[1], components[2])
    }
    
    /// Adjusts the brightness of the UIColor
    ///
    /// - Parameters:
    ///   - factor: `CGFloat`. from -1.0 to 1.0. Lower then 0 makes it darker, higher then 0 makes it lighter.
    ///
    /// - Returns: `UIColor`
    func adjustBrightness(factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * (1 + factor), alpha: alpha)
        } else {
            return self
        }
    }
    
    var brightness: CGFloat {
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        getWhite(&white, alpha: &alpha)
        return white
    }
}
