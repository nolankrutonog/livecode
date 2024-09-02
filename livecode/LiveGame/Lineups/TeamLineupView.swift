//
//  TeamLineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/20/24.
//

import SwiftUI

struct TeamLineupView: View {
    let teamName: String
    @Binding var inTheGame: Lineup
    @Binding var bench: Lineup
    @Binding private var isSevenOnSix: Bool
    
    @State private var fullInTheGame: [String]
    @State private var fullBench: [String]
    
    init(teamName: String, inTheGame: Binding<Lineup>, bench: Binding<Lineup>, isSevenOnSix: Binding<Bool>) {
        self.teamName = teamName
        self._inTheGame = inTheGame
        self._bench = bench
        self._isSevenOnSix = isSevenOnSix
        
        _fullInTheGame = State(initialValue: inTheGame.wrappedValue.goalies + inTheGame.wrappedValue.field)
        _fullBench = State(initialValue: bench.wrappedValue.goalies + bench.wrappedValue.field)
    }

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let buttonWidth: CGFloat = 120 // Fixed width for buttons
    let buttonHeight: CGFloat = 40 // Fixed height for buttons
    let maxNameLength: Int = 15

    var body: some View {
        VStack {
//            Picker("7v6", selection: $isSevenOnSix) {
//                Text("Regular").tag(false)
//                Text("7v6").tag(true)
//            }
            if !isSevenOnSix {
                regularView()
            } else {
                sevenOnSixView()
            }

        }
    }
    
//    private func sevenOnSixInGame() -> some View {
//        ForEach(inTheGame.goalies + inTheGame.field, id: \.self) { player in
//            Button(action: {
//                // going to bench
//                if let index = inTheGame.field.firstIndex(of: player) {
//                    inTheGame.field.remove(at: index)
//                    bench.field.insert(player, at: 0)
//                } else if let index = inTheGame.goalie.firstIndex(of: player) {
//                    inTheGame.goalies.remove(at: index)
//                    bench.goalies.insert(player, at: 0)
//                }
//            }) {
//                Text(abbreviateName(player))
//                    .font(.system(size: 12, weight: .medium))
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                    .padding()
//                    .frame(width: buttonWidth, height: buttonHeight)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(20)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(Color.white, lineWidth: 1)
//                    )
//            }
//        }
//    }
    
    private func sevenOnSixView() -> some View {
        VStack {
            HStack {
                Text("7v6")
                    .font(.title)
                    .bold()
                Spacer()
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
//                    sevenOnSixInGame()
                    ForEach(inTheGame.goalies + inTheGame.field, id: \.self) { player in
                        Button(action: {
                            // going to bench
                            if let index = inTheGame.field.firstIndex(of: player) {
                                inTheGame.field.remove(at: index)
                                bench.field.insert(player, at: 0)
                            } else if let index = inTheGame.goalie.firstIndex(of: player) {
                                inTheGame.goalies.remove(at: index)
                                bench.goalies.insert(player, at: 0)
                            }
                        }) {
                            Text(abbreviateName(player))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                    ForEach(bench.goalies + bench.field, id: \.self) { player in
                        Button(action: {
                            // going in the game
                            let numInGame = inTheGame.field.count + inTheGame.goalies.count
                            if numInGame < 7 {
                                if let index = bench.field.firstIndex(of: player) {
                                    bench.field.remove(at: index)
                                } else if let index = bench.goalies.firstIndex(of: player) {
                                    bench.goalies.remove(at: index)
                                }
                                
                                let hasGoalie = inTheGame.goalies.count == 1 ? true : false
                                if hasGoalie {
                                    inTheGame.field.append(player)
                                } else {
                                    inTheGame.goalies.append(player)
                                }
                            }
                        }) {
                            Text(abbreviateName(player))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.gray.opacity(0.3)) // Lighter gray background
                                .foregroundColor(.black) // Black text color
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func regularView() -> some View {
        VStack {
            HStack {
                Text("Goalie")
                    .font(.title)
                    .bold()
                Spacer()
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(inTheGame.goalies, id: \.self) { player in
                        Button(action: {
                            if let index = inTheGame.goalies.firstIndex(of: player) {
                                inTheGame.goalies.remove(at: index)
                                bench.goalies.insert(player, at: 0)
                            }
                        }) {
                            Text(abbreviateName(player))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                    ForEach(bench.goalies, id: \.self) { player in
                        Button(action: {
                            if let index = bench.goalies.firstIndex(of: player) {
                                bench.goalies.remove(at: index)
                                if !inTheGame.goalies.isEmpty {
                                    let currentGoalie = inTheGame.goalies.removeFirst()
                                    bench.goalies.insert(currentGoalie, at: 0)
                                }
                                inTheGame.goalies.append(player)
                            }
                        }) {
                            Text(abbreviateName(player))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.gray.opacity(0.3)) // Lighter gray background
                                .foregroundColor(.black) // Black text color
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .frame(height: calculateScrollViewHeight(for: inTheGame.goalies.count + bench.goalies.count))
            
            HStack {
                Text("Field Players")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                Spacer()
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(inTheGame.field, id: \.self) { player in
                        Button(action: {
                            if let index = inTheGame.field.firstIndex(of: player) {
                                inTheGame.field.remove(at: index)
                                bench.field.insert(player, at: 0)
                            }
                        }) {
                            Text(abbreviateName(player))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                    ForEach(bench.field, id: \.self) { player in
                        Button(action: {
                            if inTheGame.field.count < 6 {
                                if let index = bench.field.firstIndex(of: player) {
                                    bench.field.remove(at: index)
                                    inTheGame.field.append(player)
                                }
                            }
                        }) {
                            Text(abbreviateName(player))
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.gray.opacity(0.3)) // Lighter gray background
                                .foregroundColor(.black) // Black text color
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity) // Extend to fill vertical space
        }
        .padding()
    }
    
    
    // Helper function to abbreviate names if they are too long
    func abbreviateName(_ name: String) -> String {
        let maxLength = maxNameLength
        var abbreviatedName = name

        let nameComponents = name.split(separator: " ")
        if let lastName = nameComponents.last {
            let firstName = String(nameComponents.first ?? "")
            let lastNameStr = String(lastName)
            
            if firstName.count + lastNameStr.count + 2 > maxLength {
                abbreviatedName = "\(firstName.prefix(1)). \(lastNameStr)"
                if abbreviatedName.count > maxLength {
                    abbreviatedName = "\(firstName.prefix(1)). \(lastNameStr.prefix(maxLength - 3 - firstName.prefix(1).count))..."
                }
            }
        }
        
        if abbreviatedName.count > maxLength {
            abbreviatedName = String(abbreviatedName.prefix(maxLength)) + "..."
        }
        
        return abbreviatedName
    }
    
    func calculateScrollViewHeight(for numberOfItems: Int) -> CGFloat {
        let rows = (numberOfItems + 2) / 3 // Calculate number of rows needed
        return CGFloat(rows) * (buttonHeight + 10) // Adjust height based on number of rows
    }

}

struct TeamLineupContainerView: View {
    @State var inTheGame: Lineup
    @State var bench: Lineup
    @State var isSevens: Bool = true
    let teamName: String
    
    var body: some View {
        TeamLineupView(teamName: teamName, inTheGame: $inTheGame, bench: $bench, isSevenOnSix: $isSevens)
    }
}

struct TeamLineupsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamLineupContainerView(
//            inTheGame: Lineup(goalies: [], field: ["Player1", "Player2", "Player3", "Player4", "Player5", "Player6"]),
            inTheGame: stanfordInTheGame,
//            bench: Lineup(goalies: ["Konstantinos Mathiopoulos"], field: ["Player7", "Player8", "Player9", "Player10", "Player11"]),
            bench: stanfordBench,
            teamName: "Stanford"
        )
        .environmentObject(FirebaseManager())
    }
}

