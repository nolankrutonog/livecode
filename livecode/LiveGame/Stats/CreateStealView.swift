//
//  StealView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/25/24.
//

import SwiftUI


struct CreateStealView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameCollectionName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: LineupWithCapNumbers
    let awayInTheGame: LineupWithCapNumbers
    
    @State private var timeString: String = ""
    @State private var isTimePickerPresented = false
    
    @State private var selectedTeam: String = ""
    @State private var stolenBy: String = ""
    @State private var turnoverBy: String = ""
    @State private var showingAlert = false
    
    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: LineupWithCapNumbers, awayInTheGame: LineupWithCapNumbers) {
        self.gameCollectionName = gameCollectionName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        _selectedTeam = State(initialValue: homeTeam)
//        _stolenBy = State(initialValue: homeInTheGame.field.first ?? "no_player")
//        _turnoverBy = State(initialValue: awayInTheGame.field.first ?? "no_player")
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
                    Text("").tag("")
                    ForEach(players, id: \.self) { player in
                        Text(player.name).tag(player.name)
                    }
                }
                
                Picker("Turnover by", selection: $turnoverBy) {
                    Text("").tag("")
                    ForEach(otherPlayers, id: \.self) { player in
                        Text(player.name).tag(player.name)
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
                .disabled(!canSubmit())
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
                                gameCollectionName: gameCollectionName,
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
    private func canSubmit() -> Bool {
        return !stolenBy.isEmpty && !turnoverBy.isEmpty
    }
}

struct StealView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            CreateStealView(
                gameCollectionName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame
            )
            .environmentObject(FirebaseManager())        }
    }
}
