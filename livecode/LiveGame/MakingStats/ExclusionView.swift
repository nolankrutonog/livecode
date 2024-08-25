//
//  ExclusionView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/25/24.
//

import SwiftUI


/* requires: gameDocumentName, quarter, homeTeam, awayTeam,
             homeInTheGame, awayInTheGame
 */
struct ExclusionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameDocumentName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    @State private var timeString: String = ""
//    @State private var showingAlert = false
    @State private var isTimePickerPresented = false
    
    @State private var excludedTeam: String = ""
    @State private var excludedPlayer: String = ""
    @State private var phaseOfGame: String = ""
    @State private var exclusionType: String = ""
    @State private var drawnBy: String = ""

    init(gameDocumentName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameDocumentName = gameDocumentName
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
//            teamSelectionSection
//            phaseOfGameSelectionSection
//            playerSelectionSection
//            exclusionDetailsSection
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
                    ForEach(players, id: \.self) { player in
                        Text(player).tag(player)
                    }
                }
                
                Picker("Excluded in", selection: $phaseOfGame) {
                    ForEach(PhaseOfGameKeys.defensePhases, id: \.self) { phase in
                        Text(phase).tag(phase)
                    }
                }
                
                Picker("Exclusion type", selection: $exclusionType) {
                    ForEach(ExclusionKeys.exclusionTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                
                Picker("Drawn by", selection: $drawnBy) {
                    ForEach(otherPlayers, id: \.self) { player in
                        Text(player).tag(player)
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
                maxTime: 8,
                timeString: $timeString,
                onSubmit: {
                    Task {
                        do {
                            try await firebaseManager.createExclusionStat(
                                gameDocumentName: gameDocumentName,
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
                    print(timeString)
                },
                onCancel: {
                    // Simply dismiss the TimePickerView and stay in ExclusionView
                    self.isTimePickerPresented = false
                }
            )
        }
    }
//    private var confirmBackAlert: Alert {
//        Alert(
//            title: Text("Are you sure you want to go back?"),
//            message: Text("Your selections will be lost."),
//            primaryButton: .destructive(Text("Go Back")) {
//                presentationMode.wrappedValue.dismiss()
//            },
//            secondaryButton: .cancel()
//        )
//    }
    
    
}

struct ExclusionView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExclusionView(
                gameDocumentName: "Stanford_vs_UCLA_2024-08-25_1724557371",
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
