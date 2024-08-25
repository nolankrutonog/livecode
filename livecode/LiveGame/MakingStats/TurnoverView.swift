//
//  TurnoverView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/24/24.
//
import SwiftUI

struct TurnoverView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameDocumentName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    @State private var timeString: String = ""
    @State private var selectedTeam: String = ""
    @State private var selectedPlayer: String = ""
    @State private var showingAlert = false
    @State private var isTimePickerPresented = false
    
    init(gameDocumentName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameDocumentName = gameDocumentName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        _selectedTeam = State(initialValue: homeTeam) // Default to home team
    }
    
    var body: some View {
        Form {
            teamSelectionSection
            playerSelectionSection
        }
        .navigationTitle("Turnover")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelButton
            doneButton
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showingAlert) {
            confirmBackAlert
        }
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(
                maxTime: 8,
                timeString: $timeString,
                onSubmit: {
                    Task {
                        do {
                            try await firebaseManager.createTurnoverStat(
                                gameDocumentName: gameDocumentName,
                                quarter: quarter, 
                                timeString: timeString,
                                team: selectedTeam,
                                player: selectedPlayer
                            )
                        } catch {
                           print("Failed to create turnover stat: \(error)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                    print(timeString)
                },
                onCancel: {
                    // Simply dismiss the TimePickerView and stay in TurnoverView
                    self.isTimePickerPresented = false
                }
            )
        }
        
    }
    
    // MARK: - Components
    
    private var teamSelectionSection: some View {
        Section(header: Text("Select Team")) {
            Picker("Team", selection: $selectedTeam) {
                Text(homeTeam).tag(homeTeam)
                Text(awayTeam).tag(awayTeam)
            }
            .pickerStyle(SegmentedPickerStyle())
            .font(.title2)  // Increase the size of the text
            .padding(.vertical, 10)  // Increase the vertical padding
        }
    }
    
    
    private var playerSelectionSection: some View {
        Section(header: Text("Select Player")) {
            let players = selectedTeam == homeTeam ? homeInTheGame.goalies + homeInTheGame.field : awayInTheGame.goalies + awayInTheGame.field
            
            ForEach(players, id: \.self) { player in
                Button(action: {
                    selectedPlayer = player
                }) {
                    HStack {
                        Text(player)
                            .foregroundColor(selectedPlayer == player ? .white : .black)
                        Spacer()
                        if selectedPlayer == player {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 8)  // Reduced spacing between the names
                    .padding(.horizontal)
                    .background(selectedPlayer == player ? Color.gray : Color.clear)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                if selectedPlayer.isEmpty {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showingAlert = true
                }
            }
        }
    }
    
    private var doneButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if !selectedTeam.isEmpty && !selectedPlayer.isEmpty {
                Button("Done") {
                    isTimePickerPresented = true
                }
            }
        }
    }
    
    private var confirmBackAlert: Alert {
        Alert(
            title: Text("Are you sure you want to go back?"),
            message: Text("Your selections will be lost."),
            primaryButton: .destructive(Text("Go Back")) {
                presentationMode.wrappedValue.dismiss()
            },
            secondaryButton: .cancel()
        )
    }
}


struct TurnoverView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            TurnoverView(
                gameDocumentName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame
            )
            .environmentObject(FirebaseManager())
        }
    }
}
