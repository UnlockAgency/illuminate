//
//  View1ViewModel.swift
//  IluminateExample
//
//  Created by Bas van Kuijck on 09/02/2024.
//  Copyright (c) 2024 Unlock Agency. All rights reserved.
//

import Foundation
import Combine
import IlluminateInjection
import IlluminateCoordination
import UIKit

class View1ViewModel: ViewModalable, ObservableObject {
    var cancellables = Set<AnyCancellable>()
    
    @Published var title: String = ""
    @Published var color: UIColor = UIColor.white
    var onTap: ((String, UIColor) -> Void)?
    
    required init() {
        
    }
    
    deinit {
        print("Dealloc \(self): \(title)")
    }
}
