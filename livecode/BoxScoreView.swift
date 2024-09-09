//
//  BoxScoreView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/6/24.
//

import SwiftUI

struct BoxScoreView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.presentationMode) var presentationMode

    let gameDocumentName: String
    @State private var gameData: [(Int, [String: Any])] = []
    
    
    var body: some View {
        VStack {
            
        }
        .navigationTitle("Box Score")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .bold()
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
            firebaseManager.addGameListener(gameDocumentName: gameDocumentName)
        }
//        .onChange(of: firebaseManager.gameData) {
//            
//        }
    }
    
//    private func updateGameData(_ newStat: (Int, [String: Any])) {
//        self.gameData.append(newStat)
//    }
}

struct BoxScoreView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BoxScoreView(gameDocumentName: "Stanford_vs_UCLA_2024-09-06_1725658652")
                .environmentObject(FirebaseManager())
        }
    }
}
