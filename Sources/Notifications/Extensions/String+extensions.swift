//
//  File.swift
//  
//
//  Created by Bas van Kuijck on 12/09/2023.
//

import Foundation

extension String {
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) // swiftlint:disable:this force_try
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            if let num = UInt8(byteString, radix: 16) {
                data.append(num)
            }
        }
        
        if data.isEmpty {
            return nil
        }
        
        return data
    }
}
