//
//  NewGameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//
import SwiftUI

struct NewGameView: View {
    @State private var homeTeam: String = ""
    @State private var awayTeam: String = ""
    @State private var gameDate = Date()
    @State private var rosters: [String] = []
    @State private var gameName: String = ""
    @State private var isGameNameEdited: Bool = false
    @State private var quarterLength: Int = 8
    @State private var navigateToGame = false
    
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
        VStack(spacing: 0) {
            Form {
                Section(header: Text("Game Details")) {
                    Picker("Home Team", selection: $homeTeam) {
                        Text("Select Home Team").tag("")
                        ForEach(rosters, id: \.self) { roster in
                            Text(roster).tag(roster)
                        }
                    }
                    
                    Picker("Away Team", selection: $awayTeam) {
                        Text("Select Away Team").tag("")
                        ForEach(rosters, id: \.self) { roster in
                            Text(roster).tag(roster)
                        }
                    }
                    
                    DatePicker("Select Date", selection: $gameDate, displayedComponents: .date)
                    
                    TextField("Game Name", text: $gameName)
                        .onChange(of: gameName) { _, _ in
                            isGameNameEdited = true
                        }
                }
                
                Section(header: Text("Settings")) {
                    Stepper(value: $quarterLength, in: 1...99) {
                        Text("Quarter Length: \(quarterLength) min")
                    }
                }
            }
            
            NavigationLink(destination: GameView(homeTeam: homeTeam,
                                                 awayTeam: awayTeam,
                                                 gameName: gameName,
                                                 quarterLength: quarterLength)) {
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
        .onAppear(perform: loadRosters)
        .onChange(of: homeTeam) { _, _ in updateGameName() }
        .onChange(of: awayTeam) { _, _ in updateGameName() }
        .onChange(of: gameDate) { _, _ in updateGameName() }
    }
    
    private func loadRosters() {
        if let savedRosters = UserDefaults.standard.array(forKey: userDefaultsRostersKey) as? [String] {
            rosters = savedRosters
        }
    }
    
    private func updateGameName() {
        if !isGameNameEdited && !homeTeam.isEmpty && !awayTeam.isEmpty {
            gameName = generatedGameName
        }
    }
}

#Preview {
    NewGameView()
}
