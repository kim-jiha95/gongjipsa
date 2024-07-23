//
//  HomeViewModel.swift
//  gongjipsa
//
//  Created by Jihaha kim on 7/23/24.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var showSafariScreen = false
    @Published var errorMessage: String?
}

