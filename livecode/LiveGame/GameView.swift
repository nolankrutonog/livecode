//
//  GameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

import SwiftUI
//import FirebaseFirestore

struct GameView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var path = NavigationPath()
    
    
    
    let homeTeam: String
    let awayTeam: String
    let gameDocumentName: String
    
    @State private var currentQuarter = 1
    @State private var showNewStat = false
    
    @State private var homeInTheGame = Lineup()
    @State private var homeBench = Lineup()
    @State private var awayInTheGame = Lineup()
    @State private var awayBench = Lineup()
    
    @State private var showingAlert = false
    @State private var navigateToFinishedGameStats = false
    
//    @Binding var gameDocumentName: String
    
    // used to only call onAppear once (setting benches & creating firebase game)
    @State private var hasAppeared = false
    
    init(homeTeam: String, awayTeam: String, gameDocumentName: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.gameDocumentName = gameDocumentName
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
                                         gameDocumentName: gameDocumentName,
                                         homeInTheGame: $homeInTheGame, homeBench: $homeBench,
                                         awayInTheGame: $awayInTheGame, awayBench: $awayBench)
                .environmentObject(firebaseManager)
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
            
            // TODO: if lineups arent set, then make this button gray
            NavigationLink(destination: SelectStatView(
                gameDocumentName: gameDocumentName,
                quarter: currentQuarter,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                homeInTheGame: homeInTheGame,
                awayInTheGame: awayInTheGame
            )
                .environmentObject(firebaseManager)
            ) {
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
                        Task {
                            do {
                                try await firebaseManager.setGameToFinished(gameDocumentName: gameDocumentName)
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                        }
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
                
                homeBench = firebaseManager.getFullLineupOf(teamName: homeTeam)
                awayBench = firebaseManager.getFullLineupOf(teamName: awayTeam)
                
                // TODO: comment when done testing
                homeBench = stanfordFullRoster
                awayBench = uclaFullRoster
                
                firebaseManager.addLineupListener(gameDocumentName: gameDocumentName)
                
            }
        }
        .onChange(of: firebaseManager.currentLineup) {
            updateLineups(firebaseManager.currentLineup)
        }
    }
    
    private func updateLineups(_ newLineup: [String: Lineup]) {
        // Move players from in the game to the bench
        homeBench.field.append(contentsOf: homeInTheGame.field)
        homeBench.goalies.append(contentsOf: homeInTheGame.goalies)
        awayBench.field.append(contentsOf: awayInTheGame.field)
        awayBench.goalies.append(contentsOf: awayInTheGame.goalies)
        
        // Update in the game lineups
        homeInTheGame = newLineup[LineupKeys.homeTeam] ?? Lineup()
        awayInTheGame = newLineup[LineupKeys.awayTeam] ?? Lineup()
        
        // Remove in the game players from the benches
        homeBench.field.removeAll { homeInTheGame.field.contains($0) }
        homeBench.goalies.removeAll { homeInTheGame.goalies.contains($0) }
        awayBench.field.removeAll { awayInTheGame.field.contains($0) }
        awayBench.goalies.removeAll { awayInTheGame.goalies.contains($0) }
    }
}



struct GameView_Previews: PreviewProvider {
    @StateObject static var firebaseManager: FirebaseManager = FirebaseManager()
    
    static var previews: some View {
        NavigationStack {
            GameView(homeTeam: "Stanford", awayTeam: "UCLA",
                     gameDocumentName: "Stanford_vs_UCLA_2024-09-06_1725597362")
            .environmentObject(firebaseManager)
        }
    }
}

