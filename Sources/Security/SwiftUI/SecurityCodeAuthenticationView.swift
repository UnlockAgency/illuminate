//
//  File.swift
//  
//
//  Created by Thomas Roovers on 05/10/2022.
//

import SwiftUI

protocol SecurityCodeAuthenticationView: View {
    var viewModel: SecurityAuthenticationViewModel { get set }
}
