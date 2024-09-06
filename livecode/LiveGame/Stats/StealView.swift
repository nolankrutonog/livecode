//
//  StealView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/25/24.
//

import SwiftUI


struct StealView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameDocumentName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    @State private var timeString: String = ""
    @State private var isTimePickerPresented = false
    
    @State private var selectedTeam: String = ""
    @State private var stolenBy: String = ""
    @State private var turnoverBy: String = ""
    @State private var showingAlert = false
    
    init(gameDocumentName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameDocumentName = gameDocumentName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        _selectedTeam = State(initialValue: homeTeam)
        _stolenBy = State(initialValue: homeInTheGame.field.first ?? "no_player")
        _turnoverBy = State(initialValue: awayInTheGame.field.first ?? "no_player")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Steal Details")) {
                Picker("Team", selection: $selectedTeam) {
                    Text(homeTeam).tag(homeTeam)
                    Text(awayTeam).tag(awayTeam)
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(.title2)
                .padding(.vertical, 10)
                
                let players = selectedTeam == homeTeam
                    ? homeInTheGame.field + homeInTheGame.goalies
                    : awayInTheGame.field + awayInTheGame.goalies
                
                let otherPlayers = selectedTeam != homeTeam
                    ? homeInTheGame.field + homeInTheGame.goalies
                    : awayInTheGame.field + awayInTheGame.goalies
                    
                Picker("Stolen by", selection: $stolenBy) {
                    ForEach(players, id: \.self) { player in
                        Text(player).tag(player)
                    }
                }
                
                Picker("Turnover by", selection: $turnoverBy) {
                    ForEach(otherPlayers, id: \.self) { player in
                        Text(player).tag(player)
                    }
                }

            }
        }
        .navigationTitle("Steal")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    isTimePickerPresented = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(
                maxTime: maxQuarterMinutes,
                timeString: $timeString,
                onSubmit: {
                    Task {
                        do {
                            try await firebaseManager.createStealStat(
                                gameDocumentName: gameDocumentName,
                                quarter: quarter,
                                timeString: timeString,
                                selectedTeam: selectedTeam,
                                stolenBy: stolenBy,
                                turnoverBy: turnoverBy
                            )
                        } catch {
                           print("Failed to create exclusion stat: \(error)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                },
                onCancel: {
                    // Simply dismiss the TimePickerView and stay in ExclusionView
                    self.isTimePickerPresented = false
                }
            )
        }
    }
}

struct StealView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            StealView(
                gameDocumentName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame
            )
            .environmentObject(FirebaseManager())        }
    }
}
