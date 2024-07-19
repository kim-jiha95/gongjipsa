//
//  AppRouter.swift
//  gongjipsa
//
//  Created by Jihaha kim on 7/19/24.
//

import SwiftUI

class AppRouter: ObservableObject {
    static let shared = AppRouter()
    @Published var currentView: AppView = .homeView
}

enum AppView {
    case homeView
    case appView
    case signInView
}

