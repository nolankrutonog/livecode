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
    let gameCollectionName: String
    
    @State private var currentQuarter = 1
    @State private var showNewStat = false
    
    @State private var homeInTheGame = LineupWithCapNumbers()
    @State private var homeBench = LineupWithCapNumbers()
    @State private var awayInTheGame = LineupWithCapNumbers()
    @State private var awayBench = LineupWithCapNumbers()
    
    @State private var showingAlert = false
    @State private var navigateToFinishedGameStats = false
    
//    @Binding var gameCollectionName: String
    
    // used to only call onAppear once (setting benches & creating firebase game)
    @State private var hasAppeared = false
    
    init(homeTeam: String, awayTeam: String, gameCollectionName: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.gameCollectionName = gameCollectionName
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
                                         gameCollectionName: gameCollectionName,
                                         homeInTheGame: homeInTheGame, homeBench: homeBench,
                                         awayInTheGame: awayInTheGame, awayBench: awayBench)
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
                gameCollectionName: gameCollectionName,
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
                                try await firebaseManager.setGameToFinished(gameCollectionName: gameCollectionName)
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
                
                Task {
                    do {
                        try await homeBench = firebaseManager.fetchRoster(rosterName: homeTeam)
                        try await awayBench = firebaseManager.fetchRoster(rosterName: awayTeam)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                Task {
                    do {
                        try await firebaseManager.getMostRecentLineup(gameCollectionName: gameCollectionName)
                        firebaseManager.addGameViewLineupListener(gameCollectionName: gameCollectionName)
                    } catch {
                        print(error.localizedDescription)
                    }

                }
                
                
            }
        }
        .onChange(of: firebaseManager.currentLineup) {
            updateLineups(firebaseManager.currentLineup)
        }
    }
    
    private func updateLineups(_ newLineup: [String: LineupWithCapNumbers]) {
        // Move players from in the game to the bench
        homeBench.field.append(contentsOf: homeInTheGame.field)
        print("homeBench.field:")
        for player in homeBench.field {
            print("\t\(player.name)")
        }
        homeBench.goalies.append(contentsOf: homeInTheGame.goalies)
        awayBench.field.append(contentsOf: awayInTheGame.field)
        awayBench.goalies.append(contentsOf: awayInTheGame.goalies)
        
        // Update inTheGame lineups
        homeInTheGame = newLineup[homeTeamKey] ?? LineupWithCapNumbers()
        print("\n\nhomeInTheGame.field:")
        for player in homeInTheGame.field {
            print("\t\(player.name)")
        }
        awayInTheGame = newLineup[awayTeamKey] ?? LineupWithCapNumbers()
        // Remove inTheGame players from the benches
        
        homeBench.field.removeAll { player in
            homeInTheGame.field.contains { $0.name == player.name }
        }
        homeBench.goalies.removeAll { player in
            homeInTheGame.goalies.contains{ $0.name == player.name }
        }
        
        awayBench.field.removeAll { player in
            awayInTheGame.field.contains { $0.name == player.name }
        }
        awayBench.goalies.removeAll { player in
            awayInTheGame.goalies.contains { $0.name == player.name }
        }
    }
}


struct GameView_Previews: PreviewProvider {
    @StateObject static var firebaseManager: FirebaseManager = FirebaseManager()
    
    static var previews: some View {
        NavigationStack {
            GameView(homeTeam: "UCLA", awayTeam: "USC",
                     gameCollectionName: "UCLA_vs_USC_2024-09-20_1726879121")
            .environmentObject(firebaseManager)
        }
    }
}

