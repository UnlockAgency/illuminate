//
//  View1Coordinator.swift
//  IluminateExample
//
//  Created by Bas van Kuijck on 09/02/2024.
//  Copyright (c) 2024 Unlock Agency. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import IlluminateCoordination

public class View1Coordinator: BaseCoordinator {
    
    var title: String!
    var color: UIColor!
    
    init(title: String, color: UIColor) {
        self.title = title
        self.color = color
    }
    
    override public func start() {
        let viewModel = View1ViewModel()
        viewModel.title = title
        viewModel.color = color
        let controller = displayHostingController(type: View1View.self, viewModel: viewModel) { view in
            return UIHostingController(rootView: view)
        }
        
        viewModel.onTap = { [weak self] newTitle, newColor in
            self?.start(coordinator: View1Coordinator(title: newTitle, color: newColor))
        }
        controller.title = title
    }
    
    deinit {
        print("Dealloc \(self): \(title ?? "")")
    }
}
