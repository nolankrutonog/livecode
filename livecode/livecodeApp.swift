//
//  livecodeApp.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import SwiftUI

@main
struct livecodeApp: App {
    var body: some Scene {
        WindowGroup {
            LiveCodeView()
            
            
            // for testing only, comment out
//            @State var bottomBoxes: [String] = (1...18).map { "Box \($0)" }
//            @State var topBoxes: [String] = []
//            DragAndDropView(bottomBoxes: $bottomBoxes, topBoxes: $topBoxes)
        }
    }
}
