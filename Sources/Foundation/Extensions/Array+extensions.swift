//
//  Array+extensions.swift
//
//  Created by Thomas Roovers on 24/08/2022.
//  Copyright © 2022 Unlock Agency. All rights reserved.
//

import Foundation

public extension Array {
    subscript(optional index: Int) -> Element? {
        if index < 0 || index >= count {
            return nil
        }
        return self[index]
    }
    
    func chunk(_ size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

}
