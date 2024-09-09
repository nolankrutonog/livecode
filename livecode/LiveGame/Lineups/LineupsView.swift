//
//  LineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//


import SwiftUI

//struct Lineup {
//    var goalies: [String] = []
//    var field: [String] = []
//}

struct Lineup: Equatable, Hashable {
    var goalies: [String] = []
    var field: [String] = []
}


struct LineupsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager

    
    let homeTeam: String
    let awayTeam: String
    let quarter: Int
    let gameDocumentName: String
    
    @Binding var homeInTheGame: Lineup
    @Binding var homeBench: Lineup
    @Binding var awayInTheGame: Lineup
    @Binding var awayBench: Lineup

    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTab: Int = 0
    
    @State private var showingDoneAlert = false
    @State private var doneAlertMessage = ""
    @State private var isTimePickerPresented = false
    @State private var timeString: String = ""

    // Backup the original state
    @State private var originalHomeInTheGame: Lineup = Lineup(goalies: [], field: [])
    @State private var originalHomeBench: Lineup = Lineup(goalies: [], field: [])
    @State private var originalAwayInTheGame: Lineup = Lineup(goalies: [], field: [])
    @State private var originalAwayBench: Lineup = Lineup(goalies: [], field: [])
    
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
//            Picker("7v6", selection: $isSevenOnSix) {
//                Text("Regular").tag(false)
//                Text("7v6").tag(true)
//            }
            
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
        .alert(isPresented: $showingDoneAlert) {
            Alert(
                title: Text("Are you sure you want to set lineups?"),
                message: Text(doneAlertMessage),
                primaryButton: .destructive(Text("Confirm")) {
                    isTimePickerPresented = true
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(maxTime: maxQuarterMinutes, timeString: $timeString, onSubmit: {
                Task {
                    do {
                        try await firebaseManager.createLineupsStat(
                            gameDocumentName: gameDocumentName,
                            quarter: quarter,
                            timeString: $timeString.wrappedValue,
//                            homeTeam: homeTeam,
//                            awayTeam: awayTeam,
                            homeInTheGame: $homeInTheGame.wrappedValue,
                            awayInTheGame: $awayInTheGame.wrappedValue
                        )
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Failed to create lineup stat \(error)")
                    }
                }

            }, onCancel: {
                self.isTimePickerPresented = false
            })
        }
    }
    
    private func checkLineupsBeforeDone() {
        var problems = [String]()
        
        if homeInTheGame.field.count != 7 {
            if homeInTheGame.goalies.isEmpty {
                problems.append("\(homeTeam) doesn't have a goalie")
            }
            if homeInTheGame.field.count != 6 {
                problems.append("\(homeTeam) only has \(homeInTheGame.field.count) players in")
            }
        }
        
        if awayInTheGame.field.count != 7 {
            if awayInTheGame.goalies.isEmpty {
                problems.append("\(awayTeam) doesn't have a goalie")
            }
            if awayInTheGame.field.count != 6 {
                problems.append("\(awayTeam) only has \(awayInTheGame.field.count) players in")
            }

        }
        
        if problems.isEmpty {
            isTimePickerPresented = true
        } else {
            doneAlertMessage = problems.joined(separator: "\n")
            showingDoneAlert = true
        }
    }
}



struct LineupsView_Previews: PreviewProvider {
    @StateObject static var firebaseManager = FirebaseManager()

//    let gameDocumentName = "Stanford vs. UCLA 08-18-2024 1724474054"
    @State static var homeInTheGame = stanfordInTheGame
    @State static var homeBench = stanfordBench
    @State static var awayInTheGame = uclaInTheGame
    @State static var awayBench = uclaBench
    
    static var previews: some View {
        LineupsView(
            homeTeam: "Stanford",
            awayTeam: "UCLA",
            quarter: 1,
            gameDocumentName: "Stanford_vs_UCLA_2024-08-28_1724874036",
            homeInTheGame: $homeInTheGame,
            homeBench: $homeBench,
            awayInTheGame: $awayInTheGame,
            awayBench: $awayBench
        )
        .environmentObject(firebaseManager)
    }
}


