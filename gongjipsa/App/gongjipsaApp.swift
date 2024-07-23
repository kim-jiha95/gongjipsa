//
//  gongjipsaApp.swift
//  gongjipsa
//
//  Created by Jihaha kim on 7/19/24.
//

import SwiftUI

@main
struct gongjipsaApp: App {
    // AppDelegate를 SwiftUI 앱에 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeViewController()
                .environmentObject(AppRouter.shared)
        }
    }
}

