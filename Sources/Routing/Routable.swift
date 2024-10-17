//
//  Routable.swift
//  
//
//  Created by Bas van Kuijck on 07/11/2022.
//

import Foundation

public protocol Routable: Sendable { }

extension URL: Routable { }
