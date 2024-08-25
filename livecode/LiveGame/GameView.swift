//
//  GameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let homeTeam: String
    let awayTeam: String
    let gameName: String
    
//    var game: Game
    
    @State private var currentQuarter = 1
    @State private var showNewStat = false
    
    @State private var homeInTheGame = Lineup()
    @State private var homeBench = Lineup()
    @State private var awayInTheGame = Lineup()
    @State private var awayBench = Lineup()
    
    @State private var showingAlert = false
    @State private var navigateToFinishedGameStats = false
    
    @State private var gameDocumentName = ""
    
    // used to only call onAppear once (setting benches & creating firebase game)
    @State private var hasAppeared = false
    
    init(homeTeam: String, awayTeam: String, gameName: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.gameName = gameName
//        self.game = Game(homeTeam: homeTeam, awayTeam: awayTeam, gameName: gameName, events: [])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer() // Center the title
                Text("\(homeTeam) vs. \(awayTeam)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer() // Center the title
            }
            
            Spacer()
            
            Text("Quarter")
                .font(.title)
                .padding(.horizontal)
            
            HStack {
                Button(action: {
                    if currentQuarter > 1 {
                        currentQuarter -= 1
                    }
                }) {
                    Text("-")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(30)
                }
                
                Spacer()
                
                Text("\(currentQuarter)")
                    .font(.system(size: 48, weight: .bold, design: .default))
                
                Spacer()
                
                Button(action: {
                    currentQuarter += 1
                }) {
                    Text("+")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
           
            
            // Larger Lineups button
            NavigationLink(
                destination: LineupsView(homeTeam: homeTeam, awayTeam: awayTeam, quarter: currentQuarter,
                                         gameDocumentName: $gameDocumentName,
                                         homeInTheGame: $homeInTheGame, homeBench: $homeBench,
                                         awayInTheGame: $awayInTheGame, awayBench: $awayBench)
            ) {
                Text("Lineups")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            
            // Larger Stat button
            NavigationLink(destination: SelectStatView(
                quarter: currentQuarter,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                homeInTheGame: homeInTheGame,
                awayInTheGame: awayInTheGame
            )) {
                Text("Stat")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Finish Game button remains at the bottom
            Button(action: {
                showingAlert = true
            }) {
                Text("Finish Game")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(
                   title: Text("Are you sure you want to finish the game?"),
                   primaryButton: .destructive(Text("Finish")) {
                       navigateToFinishedGameStats = true
                   },
                   secondaryButton: .cancel()
                )
            }
            .navigationDestination(isPresented: $navigateToFinishedGameStats) {
                FinishedGameStatsView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !hasAppeared {
                hasAppeared = true // Set this to true so it only runs once
                
//                TODO: uncomment when finished creating stats
//                Task {
//                    do {
//                        gameDocumentName = try await firebaseManager.createGameDocument(gameName: gameName)
//                    } catch {
//                        print("Error creating game \(gameName)")
//                    }
//                }
//                homeBench = firebaseManager.getFullLineupOf(teamName: homeTeam)
//                awayBench = firebaseManager.getFullLineupOf(teamName: awayTeam)
                
                // TODO: for testing purposes, comment when actually running the app
                gameDocumentName = "Stanford_vs_UCLA_2024-08-25_1724557371"
                homeBench = stanfordBench
                awayBench = uclaBench
                homeInTheGame = stanfordInTheGame
                awayInTheGame = uclaInTheGame
            }
        }
    }

}



struct GameView_Previews: PreviewProvider {
    @StateObject static var firebaseManager = FirebaseManager()
    static var previews: some View {
        NavigationStack {
            GameView(homeTeam: "Stanford", awayTeam: "UCLA",
                     gameName: "Stanford_vs_UCLA_2024-08-25_1724557371")
            .environmentObject(firebaseManager)
        }
    }
}
