//
//  NewGameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//
import SwiftUI

struct NewGameView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var homeTeam: String = ""
    @State private var awayTeam: String = ""
    @State private var gameDate = Date()
    @State private var gameName: String = ""
    @State private var isGameNameEdited: Bool = false
    @State private var navigateToGame = false
    
    @State private var isLoading: Bool = true
    
    var generatedGameName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: gameDate)
        return "\(homeTeam) vs. \(awayTeam) \(dateString)"
    }
    
    var isFormValid: Bool {
        !homeTeam.isEmpty && !awayTeam.isEmpty && !gameName.isEmpty
    }
    
    var body: some View {
        if isLoading {
            ProgressView("Loading rosters...")
                .onAppear {
                    Task {
                        await firebaseManager.fetchRosters()
                        isLoading = false
                    }
                }
        } else {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Game Details")) {
                        Picker("Home Team", selection: $homeTeam) {
                            Text("Select Home Team").tag("")
                            ForEach(firebaseManager.rosters.keys.sorted(), id: \.self) { teamName in
                                Text(teamName).tag(teamName)
                            }
                        }
                        
                        Picker("Away Team", selection: $awayTeam) {
                            Text("Select Away Team").tag("")
                            ForEach(firebaseManager.rosters.keys.sorted(), id: \.self) { teamName in
                                Text(teamName).tag(teamName)
                            }
                        }
                        
                        DatePicker("Select Date", selection: $gameDate, displayedComponents: .date)
                        
                        TextField("Game Name", text: $gameName)
                            .onChange(of: gameName) { _, _ in
                                isGameNameEdited = true
                            }
                    }
                }
                
                NavigationLink(destination: GameView(homeTeam: homeTeam,
                                                     awayTeam: awayTeam,
                                                     gameName: gameName)
                    .environmentObject(firebaseManager)
                ) {
                    Text("Start Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .padding()
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: homeTeam) { _, _ in updateGameName() }
            .onChange(of: awayTeam) { _, _ in updateGameName() }
            .onChange(of: gameDate) { _, _ in updateGameName() }
        }
    }
    
    private func updateGameName() {
        if !isGameNameEdited && !homeTeam.isEmpty && !awayTeam.isEmpty {
            gameName = generatedGameName
        }
    }
}


struct NewGameView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewGameView()
                .environmentObject(FirebaseManager())
        }
    }
}
