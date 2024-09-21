//
//  LineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//


import SwiftUI

//struct Lineup: Equatable, Hashable {
//    var goalies: [String] = []
//    var field: [String] = []
//}

class Player: Identifiable, ObservableObject, Equatable, Hashable {
    static func == (lhs: Player, rhs: Player) -> Bool {
            return lhs.id == rhs.id
        }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    var name: String
    var num: Int
    var notes: String
    
    init(num: Int, name: String, notes: String) {
        self.name = name
        self.num = num
        self.notes = notes
    }
    
    func copy() -> Player {
        return Player(num: self.num, name: self.name, notes: self.notes)
    }
}

class LineupWithCapNumbers: ObservableObject, Equatable {
    @Published var goalies: [Player] = []
    @Published var field: [Player] = []
    
    static func == (lhs: LineupWithCapNumbers, rhs: LineupWithCapNumbers) -> Bool {
        return lhs.goalies == rhs.goalies && lhs.field == rhs.field
    }
    
    func copy() -> LineupWithCapNumbers {
        let copy = LineupWithCapNumbers()
        copy.goalies = self.goalies.map { $0.copy() }
        copy.field = self.field.map { $0.copy() }
        return copy
    }
        
    func update(from other: LineupWithCapNumbers) {
        self.goalies = other.goalies.map { $0.copy() }
        self.field = other.field.map { $0.copy() }
    }
    
    public func addGoalie(name: String, num: Int, notes: String) {
        let player = Player(num: num, name: name, notes: notes)
        goalies.append(player)
        goalies.sort { $0.num < $1.num}
    }
    
    public func addFieldPlayer(name: String, num: Int, notes: String) {
        let player = Player(num: num, name: name, notes: notes)
        field.append(player)
        field.sort { $0.num < $1.num }
    }
    
    public func removePlayer(index: Int, isField: Bool) {
        if isField {
            field.remove(at: index)
        } else {
            goalies.remove(at: index)
        }
    }
    
    
    public func removeGoalie(at offsets: IndexSet) {
        goalies.remove(atOffsets: offsets)
    }
    
    public func removeFieldPlayer(at offsets: IndexSet) {
        field.remove(atOffsets: offsets)
    }
    
    public func reset() {
        goalies.removeAll()
        field.removeAll()
    }

}


struct LineupsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager

    
    let homeTeam: String
    let awayTeam: String
    let quarter: Int
    let gameCollectionName: String
    
    @ObservedObject var homeInTheGame: LineupWithCapNumbers
    @ObservedObject var homeBench: LineupWithCapNumbers
    @ObservedObject var awayInTheGame: LineupWithCapNumbers
    @ObservedObject var awayBench: LineupWithCapNumbers

    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTab: Int = 0
    
    @State private var showingDoneAlert = false
    @State private var doneAlertMessage = ""
    @State private var isTimePickerPresented = false
    @State private var timeString: String = ""

    // Backup the original state
    @StateObject private var originalHomeInTheGame = LineupWithCapNumbers()
    @StateObject private var originalHomeBench = LineupWithCapNumbers()
    @StateObject private var originalAwayInTheGame = LineupWithCapNumbers()
    @StateObject private var originalAwayBench = LineupWithCapNumbers()
    
    var body: some View {
        VStack {
            // Custom Tab Bar
            HStack {
                Button(action: {
                    selectedTab = 0
                }) {
                    Text(homeTeam)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 0 ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == 0 ? .white : .primary)
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedTab = 1
                }) {
                    Text(awayTeam)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == 1 ? Color.blue : Color.clear)
                        .foregroundColor(selectedTab == 1 ? .white : .primary)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
//            Picker("7v6", selection: $isSevenOnSix) {
//                Text("Regular").tag(false)
//                Text("7v6").tag(true)
//            }
            
            // Content View
            if selectedTab == 0 {
                TeamLineupView(teamName: homeTeam, inTheGame: homeInTheGame, bench: homeBench)
            } else {
                TeamLineupView(teamName: awayTeam, inTheGame: awayInTheGame, bench: awayBench)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    // Revert to the original state when cancel is pressed
//                    homeInTheGame = originalHomeInTheGame
                    homeInTheGame.update(from: originalHomeInTheGame)
//                    homeBench = originalHomeBench
                    homeBench.update(from: originalHomeBench)
//                    awayInTheGame = originalAwayInTheGame
                    awayInTheGame.update(from: originalAwayInTheGame)
//                    awayBench = originalAwayBench
                    awayBench.update(from: originalAwayBench)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    checkLineupsBeforeDone()
                }
            }
        }
        .onAppear {
            // Backup the original state when the view appears
            originalHomeInTheGame.update(from: homeInTheGame)
            originalHomeBench.update(from: homeBench)
            originalAwayInTheGame.update(from: awayInTheGame)
            originalAwayBench.update(from: awayBench)
        }
        .alert(isPresented: $showingDoneAlert) {
            Alert(
                title: Text("Are you sure you want to set lineups?"),
                message: Text(doneAlertMessage),
                primaryButton: .destructive(Text("Confirm")) {
                    isTimePickerPresented = true
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(maxTime: maxQuarterMinutes, timeString: $timeString, onSubmit: {
                Task {
                    do {
                        try await firebaseManager.createLineupsStat(
                            gameCollectionName: gameCollectionName,
                            quarter: quarter,
                            timeString: $timeString.wrappedValue,
//                            homeTeam: homeTeam,
//                            awayTeam: awayTeam,
                            homeInTheGame: homeInTheGame,
                            awayInTheGame: awayInTheGame
                        )
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Failed to create lineup stat \(error)")
                    }
                }

            }, onCancel: {
                self.isTimePickerPresented = false
            })
        }
    }
    
    private func checkLineupsBeforeDone() {
        var problems = [String]()
        
        if homeInTheGame.field.count != 7 {
            if homeInTheGame.goalies.isEmpty {
                problems.append("\(homeTeam) doesn't have a goalie")
            }
            if homeInTheGame.field.count != 6 {
                problems.append("\(homeTeam) only has \(homeInTheGame.field.count) players in")
            }
        }
        
        if awayInTheGame.field.count != 7 {
            if awayInTheGame.goalies.isEmpty {
                problems.append("\(awayTeam) doesn't have a goalie")
            }
            if awayInTheGame.field.count != 6 {
                problems.append("\(awayTeam) only has \(awayInTheGame.field.count) players in")
            }

        }
        
        if problems.isEmpty {
            isTimePickerPresented = true
        } else {
            doneAlertMessage = problems.joined(separator: "\n")
            showingDoneAlert = true
        }
    }
}



struct LineupsView_Previews: PreviewProvider {
    @StateObject static var firebaseManager = FirebaseManager()

//    let gameCollectionName = "Stanford vs. UCLA 08-18-2024 1724474054"
    @StateObject static var homeInTheGame = stanfordInTheGame
    @StateObject static var homeBench = stanfordBench
    @StateObject static var awayInTheGame = uclaInTheGame
    @StateObject static var awayBench = uclaBench
    
    static var previews: some View {
        LineupsView(
            homeTeam: "Stanford",
            awayTeam: "UCLA",
            quarter: 1,
            gameCollectionName: "Stanford_vs_UCLA_2024-08-28_1724874036",
            homeInTheGame: homeInTheGame,
            homeBench: homeBench,
            awayInTheGame: awayInTheGame,
            awayBench: awayBench
        )
        .environmentObject(firebaseManager)
    }
}


