//
//  GameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

import SwiftUI

struct Lineup {
    var goalie: String = ""
    var fieldPlayers: [String] = []
}

struct GameView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let homeTeam: String
    let awayTeam: String
    let gameName: String
    
    var game: Game
    
    @State private var currentQuarter = 1
    @State private var showNewStat = false
    
    @State private var homeLineup = Lineup()
    @State private var homeBench: [String] = []
    @State private var awayLineup = Lineup()
    @State private var awayBench: [String] = []
    
    @State private var showingAlert = false
    @State private var navigateToFinishedGameStats = false
    
    init(homeTeam: String, awayTeam: String, gameName: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.gameName = gameName
        self.game = Game(homeTeam: homeTeam, awayTeam: awayTeam, gameName: gameName, events: [])
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
                destination: LineupsView(homeTeam: homeTeam, awayTeam: awayTeam,
                                         homeLineup: $homeLineup, homeBench: $homeBench,
                                         awayLineup: $awayLineup, awayBench: $awayBench)
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
            NavigationLink(destination: MakeStatView()) {
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
            Task {
                await firebaseManager.createGameDocument(gameName: gameName)
            }
            homeBench = firebaseManager.getPlayersOf(teamName: homeTeam)
            awayBench = firebaseManager.getPlayersOf(teamName: awayTeam)
        }
    }

}


struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GameView(homeTeam: "Stanford", awayTeam: "UCLA",
                     gameName: "Stanford vs. UCLA 08-18-2024")
            .environmentObject(FirebaseManager())
        }
    }
}

