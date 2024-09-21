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
//    @State private var errMsg: String?
    
    @State private var gameCollectionName: String = ""
    
    @State private var teams: [String] = []
    
    var generatedGameName: String {
        
        let sanitizedHomeTeam = homeTeam.replacingOccurrences(of: " ", with: "_").filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
        let sanitizedAwayTeam = awayTeam.replacingOccurrences(of: " ", with: "_").filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        let formattedDate = formatter.string(from: gameDate)

        return "\(sanitizedHomeTeam)_vs_\(sanitizedAwayTeam)_\(formattedDate)"
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
        } 
//        else if let errMsg = errMsg {
//            Text(errMsg)
//                .foregroundColor(.red)
//                .padding()
//            Button("Retry") {
//                loadRosters()
//            }
//            .padding()
//        } 
        else {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Game Details")) {
                        Picker("Home Team", selection: $homeTeam) {
                            Text("Select Home Team").tag("")
                            ForEach(teams, id: \.self) { teamName in
                                Text(teamName).tag(teamName)
                            }
                        }
                        
                        Picker("Away Team", selection: $awayTeam) {
                            Text("Select Away Team").tag("")
                            ForEach(teams, id: \.self) { teamName in
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
                                gameCollectionName = try await firebaseManager.createGameDocument(gameName: gameName, homeTeam: homeTeam, awayTeam: awayTeam)
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
                GameView(homeTeam: homeTeam, awayTeam: awayTeam, gameCollectionName: gameCollectionName)
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
        Task {
            do {
                teams = try await firebaseManager.fetchRosterNames()
                isLoading = false
            } 
            catch {
                print(error.localizedDescription)
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
