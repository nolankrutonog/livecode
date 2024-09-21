//
//  CreateExclusionView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/25/24.
//

import SwiftUI


/* requires: gameCollectionName, quarter, homeTeam, awayTeam,
             homeInTheGame, awayInTheGame
 */
struct CreateExclusionView: View {
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
    
    @State private var excludedTeam: String = ""
    @State private var excludedPlayer: String = ""
    @State private var phaseOfGame: String = ""
    @State private var exclusionType: String = ""
    @State private var drawnBy: String = ""

    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: LineupWithCapNumbers, awayInTheGame: LineupWithCapNumbers) {
        self.gameCollectionName = gameCollectionName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        _excludedTeam = State(initialValue: homeTeam)
        _exclusionType = State(initialValue: "On ball center")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Exclusion Details")) {
                Picker("Team", selection: $excludedTeam) {
                    Text(homeTeam).tag(homeTeam)
                    Text(awayTeam).tag(awayTeam)
                }
                .pickerStyle(SegmentedPickerStyle())
                .font(.title2)
                .padding(.vertical, 10)
                
                let players = excludedTeam == homeTeam ? homeInTheGame.field + homeInTheGame.goalies : awayInTheGame.field + awayInTheGame.goalies
                let otherPlayers = excludedTeam != homeTeam ? homeInTheGame.field + homeInTheGame.goalies : awayInTheGame.field + awayInTheGame.goalies
                
                Picker("Excluded player", selection: $excludedPlayer) {
                    Text("").tag("")
                    ForEach(players, id: \.self) { player in
                        Text(player.name).tag(player.name)
                    }
                }
                
                Picker("Excluded in", selection: $phaseOfGame) {
                    Text("").tag("")
                    ForEach(Array(PhaseOfGameKeys.defenseToDisp), id: \.key) { key, value in
                        Text(value).tag(key)
                    }
                }
                
                Picker("Exclusion type", selection: $exclusionType) {
                    Text("").tag("")
                    ForEach(Array(ExclusionKeys.toDisp), id: \.key) { key, value in
                        Text(value).tag(key)
                    }
                }
                
                Picker("Drawn by", selection: $drawnBy) {
                    Text("").tag("")
                    ForEach(otherPlayers, id: \.self) { player in
                        Text(player.name).tag(player.name)
                    }
                }
                
            }
        }
        .navigationTitle("Exclusion")
        .navigationBarTitleDisplayMode(.inline)
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
//        .alert(isPresented: $showingAlert) {
//            confirmBackAlert
//        }
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(
                maxTime: maxQuarterMinutes,
                timeString: $timeString,
                onSubmit: {
                    Task {
                        do {
                            try await firebaseManager.createExclusionStat(
                                gameCollectionName: gameCollectionName,
                                quarter: quarter,
                                timeString: timeString,
                                excludedTeam: excludedTeam,
                                excludedPlayer: excludedPlayer,
                                phaseOfGame: phaseOfGame,
                                exclusionType: exclusionType,
                                drawnBy: drawnBy
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

struct ExclusionView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateExclusionView(
                gameCollectionName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 3,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame
            )
            .environmentObject(FirebaseManager())
        }
    }
}
