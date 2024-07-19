//
//  AppDelegate.swift
//  gongjipsa
//
//  Created by Jihaha kim on 7/19/24.
//

import SwiftUI

@main
struct gongjipsaApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

