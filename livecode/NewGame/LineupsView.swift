//
//  LineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//


import SwiftUI

struct LineupsView: View {
    let homeTeam: String
    let awayTeam: String
    
    @Binding var homeInTheGame: Lineup
    @Binding var homeBench: Lineup
    @Binding var awayInTheGame: Lineup
    @Binding var awayBench: Lineup

    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTab: Int = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // Backup the original state
    @State private var originalHomeInTheGame: Lineup = Lineup(goalies: [], fieldPlayers: [])
    @State private var originalHomeBench: Lineup = Lineup(goalies: [], fieldPlayers: [])
    @State private var originalAwayInTheGame: Lineup = Lineup(goalies: [], fieldPlayers: [])
    @State private var originalAwayBench: Lineup = Lineup(goalies: [], fieldPlayers: [])
    
    var body: some View {
        VStack {
            // Custom Tab Bar
            HStack {
                Button(action: {
                    selectedTab = 0
                }) {
                    Text(homeTeam)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 0 ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == 0 ? .white : .primary)
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedTab = 1
                }) {
                    Text(awayTeam)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 1 ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == 1 ? .white : .primary)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Content View
            if selectedTab == 0 {
                TeamLineupView(teamName: homeTeam, inTheGame: $homeInTheGame, bench: $homeBench)
            } else {
                TeamLineupView(teamName: awayTeam, inTheGame: $awayInTheGame, bench: $awayBench)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    // Revert to the original state when cancel is pressed
                    homeInTheGame = originalHomeInTheGame
                    homeBench = originalHomeBench
                    awayInTheGame = originalAwayInTheGame
                    awayBench = originalAwayBench
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    checkLineupsBeforeDone()
                }
            }
        }
        .onAppear {
            // Backup the original state when the view appears
            originalHomeInTheGame = homeInTheGame
            originalHomeBench = homeBench
            originalAwayInTheGame = awayInTheGame
            originalAwayBench = awayBench
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to set the lineups?"),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Confirm")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func checkLineupsBeforeDone() {
        var problems = [String]()
        
        // Check Home Team
        if homeInTheGame.goalies.isEmpty {
            problems.append("\(homeTeam) doesn't have a goalie")
        }
        if homeInTheGame.fieldPlayers.count != 6 {
            problems.append("\(homeTeam) only has \(homeInTheGame.fieldPlayers.count) players in")
        }
        
        // Check Away Team
        if awayInTheGame.goalies.isEmpty {
            problems.append("\(awayTeam) doesn't have a goalie")
        }
        if awayInTheGame.fieldPlayers.count != 6 {
            problems.append("\(awayTeam) only has \(awayInTheGame.fieldPlayers.count) players in")
        }
        
        if problems.isEmpty {
            // No problems, dismiss the view
            presentationMode.wrappedValue.dismiss()
        } else {
            // There are problems, show the alert
            alertMessage = problems.joined(separator: "\n")
            showingAlert = true
        }
    }
    
    private func printLineups() {
        print("Home Team (\(homeTeam)) - In The Game: \(homeInTheGame)")
        print("Home Team (\(homeTeam)) - Bench: \(homeBench)")
        print("Away Team (\(awayTeam)) - In The Game: \(awayInTheGame)")
        print("Away Team (\(awayTeam)) - Bench: \(awayBench)")
        print("\n\n\n\n")
    }
}

struct LineupsView_Previews: PreviewProvider {
    @StateObject static var firebaseManager = FirebaseManager()
    @State static var homeInTheGame = stanfordInTheGame
    @State static var homeBench = stanfordBench
    @State static var awayInTheGame = uclaInTheGame
    @State static var awayBench = uclaBench
    
    static var previews: some View {
        LineupsView(
            homeTeam: "Stanford",
            awayTeam: "UCLA",
            homeInTheGame: $homeInTheGame,
            homeBench: $homeBench,
            awayInTheGame: $awayInTheGame,
            awayBench: $awayBench
        )
        .environmentObject(firebaseManager)
    }
}


