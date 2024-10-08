//
//  livecodeApp.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


import SwiftUI

@main
struct livecodeApp: App {
    
    @StateObject private var firebaseManager = FirebaseManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LiveCodeView()
                .environmentObject(firebaseManager)
        }
    }
}
