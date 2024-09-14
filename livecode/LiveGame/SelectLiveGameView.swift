//
//  SelectLiveGameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/5/24.
//

import SwiftUI

struct SelectLiveGameView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var destinationGameView: Bool
    
    @State private var toDestination: Bool = false
    @State private var selectedGameCollectionName: String? = nil
    @State private var homeTeam: String = ""
    @State private var awayTeam: String = ""
    @State private var gameNames: [String] = []
    
    @State private var isLoading: Bool = true
    
    
    var body: some View {
        VStack {
            if isLoading {
               ProgressView("Loading live games...")
                    .onAppear {
                        Task {
                            do {
                                try await gameNames = firebaseManager.fetchGameNames(isFinished: false)
                                isLoading = false
                            } catch {
                                print("Error fetching live game names: \n\(error.localizedDescription)")
                            }
                        }
                    }
            } else {
                Form {
                    ForEach(gameNames, id: \.self) { gameCollectionName in
                        let gameTuple: (String, String, String) = convertgameCollectionName(gameCollectionName: gameCollectionName)
                        let homeTeam = gameTuple.0
                        let awayTeam = gameTuple.1
                        let date = gameTuple.2
                        Button(action: {
                            selectedGameCollectionName = gameCollectionName
                            self.homeTeam = homeTeam
                            self.awayTeam = awayTeam
                            toDestination = true
                        }) {
                            Text("\(homeTeam) vs. \(awayTeam) \n\t\(date)")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Live Game")
        .navigationDestination(isPresented: $toDestination) {
            if destinationGameView {
                GameView(homeTeam: homeTeam, awayTeam: awayTeam, gameCollectionName: selectedGameCollectionName ?? "")
                    .environmentObject(firebaseManager)
            } else {
                BoxScoreView(gameCollectionName: selectedGameCollectionName ?? "")
                    .environmentObject(firebaseManager)
            }
        }
        
            
    }
    
    
    /* Splits the GAME_DOCUMENT_NAME in format <Stanford_vs_UCLA_2024-09-06_1725604436> where
     * 0th elem is homeTeam, 2nd elem in awayTeam
     */
    private func convertgameCollectionName(gameCollectionName: String) -> (String, String, String) {
        let asList = gameCollectionName.components(separatedBy: "_")
        let homeTeam = asList[0]
        let awayTeam = asList[2]
        let date = asList[3]
        return (homeTeam, awayTeam, date)
    }
}

struct SelectLiveGame_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectLiveGameView(destinationGameView: false)
                .environmentObject(FirebaseManager())
        }
    }
}
