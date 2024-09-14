//
//  BoxScoreView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/6/24.
//

import SwiftUI

struct BoxScoreView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hasAppeared: Bool = false
    
    let gameCollectionName: String
    
    init(gameCollectionName: String) {
        self.gameCollectionName = gameCollectionName
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    VStack {
                        Text(firebaseManager.gameData.homeTeam)
                            .font(.title)
                            .foregroundColor(.primary)
                            .bold()
                            .multilineTextAlignment(.center)
                        NavigationLink(destination: GoalsView(isHome: true).environmentObject(firebaseManager)) {
                            Text("\(firebaseManager.gameData.homeScore)")
                                .font(.system(size: 64))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
  
                        }
                        Text("TOL: \(getTOL(isHome: true))")
                            .font(.title3)
                    }
                    .frame(width: geometry.size.width / 2)

                    VStack {
                        Text(firebaseManager.gameData.awayTeam)
                            .font(.title)
                            .foregroundColor(.primary)
                            .bold()
                            .multilineTextAlignment(.center)
                        NavigationLink(destination: GoalsView(isHome: false).environmentObject(firebaseManager)) {
                            Text("\(firebaseManager.gameData.awayScore)")
                                .font(.system(size: 64))
                                .fontWeight(.bold)
                                .foregroundColor(.red)
  
                        }
                        Text("TOL: \(getTOL(isHome: false))")
                            .font(.title3)
                    }
                    .frame(width: geometry.size.width / 2)
                }
            }

            Spacer()
        }
//        .navigationTitle("Box Score")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    firebaseManager.gameData.reset()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .bold()
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                
                
//                /* Uncomment when done testing */
                
                
                
                Task {
                    do {
                        
                        // TODO: this is a temporary fix, read TODO in firebasemanager
                        try await firebaseManager.populateGameData(gameCollectionName: gameCollectionName)
                        firebaseManager.addGameListener(gameCollectionName: gameCollectionName)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
    }
    
    private func getTOL(isHome: Bool) -> String {
        let TOL = isHome ? firebaseManager.gameData.homeTimeoutsLeft : firebaseManager.gameData.awayTimeoutsLeft
        return TOL.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", TOL) : String(format: "%.1f", TOL)
    }
    
}

struct GoalsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var isHome: Bool
    @State private var goals: [GameData.Shot] = []
    @State private var team: String = ""

    init(isHome: Bool) {
        _isHome = State(initialValue: isHome)
    }

    var body: some View {
        VStack {
            ForEach(goals, id: \.self) { goal in
                Text("\(goal.shooter): \(goal.gameTime) seconds")
            }
        }
        .navigationTitle("\(team) Goals")
        .onAppear {
            if isHome {
                team = firebaseManager.gameData.homeTeam
            } else {
                team = firebaseManager.gameData.awayTeam
            }
            
            let key = isHome ? homeTeamKey : awayTeamKey
            let singleTeamShotTracker: [String: [GameData.Shot]] = firebaseManager.gameData.shotTracker[key] ?? [:]

            var updatedGoals: [GameData.Shot] = []
            for (_, shotList) in singleTeamShotTracker {
                for shot in shotList where shot.shotResult == ShotKeys.shotResults.goal {
                    updatedGoals.append(shot)
                }
            }
            goals = updatedGoals
        }
    }
}

struct BoxScoreView_Preview: PreviewProvider {
    static var firebaseManager: FirebaseManager = {
        let manager = FirebaseManager()
        manager.gameData.homeTeam = "Stanford"
        manager.gameData.awayTeam = "UCLA"
        manager.gameData.homeScore = 0
        manager.gameData.awayScore = 0
        manager.gameData.homeTimeoutsLeft = 3.5
        manager.gameData.awayTimeoutsLeft = 3.5
        return manager
    }()

    static var previews: some View {
        NavigationStack {
            BoxScoreView(gameCollectionName: "Stanford_vs_UCLA_2024-09-12_1726197263")
                .environmentObject(firebaseManager)
        }
    }
}
