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
    
    // waits for firebaseManager to fetchRosters
    @State private var isLoading: Bool = true
    @State private var errMsg: String?
    
    @State private var gameDocumentName: String = ""
    
    var generatedGameName: String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]
        let dateString = dateFormatter.string(from: gameDate)
        
        // Replace spaces with underscores or hyphens and remove special characters
        let sanitizedHomeTeam = homeTeam.replacingOccurrences(of: " ", with: "_").filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
        let sanitizedAwayTeam = awayTeam.replacingOccurrences(of: " ", with: "_").filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
        
        return "\(sanitizedHomeTeam)_vs_\(sanitizedAwayTeam)_\(dateString)"
    }
    
    var isFormValid: Bool {
        !homeTeam.isEmpty && !awayTeam.isEmpty && !gameName.isEmpty
    }
    
    var body: some View {
        if isLoading {
            ProgressView("Loading rosters...")
                .onAppear {
                    loadRosters()
                }
        } else if let errMsg = errMsg {
            Text(errMsg)
                .foregroundColor(.red)
                .padding()
            Button("Retry") {
                loadRosters()
            }
            .padding()
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
            
                
                Button(action: {
                    // create new game here
                    if isFormValid {
                        Task {
                            do {
//                                try await firebaseManager.fetchRosters()
                                gameDocumentName = try await firebaseManager.createGameDocument(gameName: gameName)
                                navigateToGame = true
                            } catch {
                                print("Error creating game \(gameName)")
                            }
                        }
                    }
                }) {
                    Text("Start Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(homeTeam: homeTeam, awayTeam: awayTeam, gameDocumentName: gameDocumentName)
                    .environmentObject(firebaseManager)
            }
            .onChange(of: homeTeam) { _, _ in updateGameName() }
            .onChange(of: awayTeam) { _, _ in updateGameName() }
            .onChange(of: gameDate) { _, _ in updateGameName() }
        }
    }
   
    private func updateGameName() {
//        if !isGameNameEdited && !homeTeam.isEmpty && !awayTeam.isEmpty {
//            gameName = generatedGameName
//        }
        if !homeTeam.isEmpty && !awayTeam.isEmpty {
            gameName = generatedGameName
        }
    }
    
    private func loadRosters() {
        isLoading = true
        errMsg = nil

        Task {
            do {
                try await firebaseManager.fetchRosters()
                isLoading = false
            } catch let error as FirebaseError {
                errMsg = error.localizedDescription
                isLoading = false
            } catch {
                errMsg = "An unexpected error occurred."
                isLoading = false
            }
        }
    }
}


struct NewGameView_Preview: PreviewProvider {
    @StateObject static var firebaseManager: FirebaseManager = FirebaseManager()
    static var previews: some View {
        NavigationStack {
            NewGameView()
                .environmentObject(firebaseManager)
        }
    }
}
