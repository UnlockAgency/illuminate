//
//  UIImage+extension.swift
//  Plein
//
//  Created by Bas van Kuijck on 01/09/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    func withAlphaComponent(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        return newImage
    }
}
