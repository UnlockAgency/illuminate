//
//  View1View.swift
//  IluminateExample
//
//  Created by Bas van Kuijck on 09/02/2024.
//  Copyright (c) 2024 Unlock Agency. All rights reserved.
//

import SwiftUI
import Combine
import IlluminateCoordination

struct View1View: View, ViewModelControllable {
    @ObservedObject private(set) var viewModel: View1ViewModel
    
    init(viewModel: View1ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Button {
                viewModel.onTap?(viewModel.title + " +", viewModel.color)
            } label: { Text(viewModel.title) }
        }
        .background(Color(uiColor: viewModel.color))
        .environmentObject(viewModel)
    }
}

// MARK: - Previews
// --------------------------------------------------------
#if DEBUG
struct View1View_Previews: PreviewProvider {
    static var previews: some View {
        View1View(viewModel: View1ViewModel())
    }
}
#endif
