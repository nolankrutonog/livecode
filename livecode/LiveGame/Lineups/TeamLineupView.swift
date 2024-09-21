//
//  TeamLineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/20/24.
//

import SwiftUI

struct TeamLineupView: View {
    let teamName: String
    @ObservedObject var inTheGame: LineupWithCapNumbers
    @ObservedObject var bench: LineupWithCapNumbers
    @State private var is7v6: Bool = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let buttonWidth: CGFloat = 120 // Fixed width for buttons
    let buttonHeight: CGFloat = 40 // Fixed height for buttons
    let maxNameLength: Int = 15

    var body: some View {
        VStack {
            Picker("7v6", selection: $is7v6) {
                Text("Regular").tag(false)
                Text("7v6").tag(true)
            }
            if !is7v6 {
                regularView()
            } else {
                sevenOnSixView()
            }

        }
        .onAppear {
            if inTheGame.field.count == 7 {
                is7v6 = true
            }
        }
    }
    
    private func sevenOnSixView() -> some View {
        
        return VStack {
            HStack {
                Text("7v6")
                    .font(.title)
                    .bold()
                Spacer()
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(inTheGame.field, id: \.self) { player in
                        Button(action: {
                            // going to bench
                            if let index = inTheGame.field.firstIndex(of: player) {
                                inTheGame.removePlayer(index: index, isField: true)
                                bench.addFieldPlayer(name: player.name, num: player.num, notes: player.notes)
                            }
                        }) {
                            Text("\(player.num). \(abbreviateName(player.name))")
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
                            // going in the game
                            let numInGame = inTheGame.field.count + inTheGame.goalies.count
                            if numInGame < 7 {
                                if let index = bench.field.firstIndex(of: player) {
                                    bench.removePlayer(index: index, isField: true)
                                }
                                inTheGame.addFieldPlayer(name: player.name, num: player.num, notes: player.notes)
                            }
                        }) {
                            Text("\(player.num). \(abbreviateName(player.name))")
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.gray.opacity(0.3)) // Lighter gray background
                                .foregroundColor(.primary) // Black text color
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
        .onAppear {
            // move all goalies to bench
            for goalie in inTheGame.goalies {
                if let index = inTheGame.goalies.firstIndex(of: goalie) {
                    inTheGame.removePlayer(index: index, isField: false)
                    bench.addGoalie(name: goalie.name, num: goalie.num, notes: goalie.notes)
                }
            }
        }
    }
    
    private func regularView() -> some View {
        return VStack {
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
                                //                                inTheGame.goalies.remove(at: index)
                                //                                bench.goalies.insert(player, at: 0)
                                
                                inTheGame.removePlayer(index: index, isField: false)
                                bench.addGoalie(name: player.name, num: player.num, notes: player.notes)
                            }
                        }) {
                            Text("\(player.num). \(abbreviateName(player.name))")
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
                                bench.removePlayer(index: index, isField: false)
                                //                                bench.goalies.remove(at: index)
                                if !inTheGame.goalies.isEmpty {
                                    let currentGoalie = inTheGame.goalies.removeFirst()
                                    //                                    bench.goalies.insert(currentGoalie, at: 0)
                                    bench.addGoalie(name: currentGoalie.name, num: currentGoalie.num, notes: currentGoalie.notes)
                                }
                                //                                inTheGame.goalies.append(player)
                                inTheGame.addGoalie(name: player.name, num: player.num, notes: player.notes)
                            }
                        }) {
                            Text("\(player.num). \(abbreviateName(player.name))")
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.gray.opacity(0.3)) // Lighter gray background
                                .foregroundColor(.primary) // Black text color
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
                        Button(action:
                                {
                            if let index = inTheGame.field.firstIndex(of: player) {
                                inTheGame.removePlayer(index: index, isField: true)
                                bench.addFieldPlayer(name: player.name, num: player.num, notes: player.notes)
                            }
                        }
                        ) {
                            Text("\(player.num). \(abbreviateName(player.name))")
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
                                    bench.removePlayer(index: index, isField: true)
                                    inTheGame.addFieldPlayer(name: player.name, num: player.num, notes: player.notes)
                                }
                            }
                        }) {
                            Text("\(player.num). \(abbreviateName(player.name))")
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding()
                                .frame(width: buttonWidth, height: buttonHeight)
                                .background(Color.gray.opacity(0.3)) // Lighter gray background
                                .foregroundColor(.primary)
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
    @StateObject var inTheGame: LineupWithCapNumbers
    @StateObject var bench: LineupWithCapNumbers
    @State var isSevens: Bool = true
    let teamName: String
    
    @State private var hasAppeared = false
    
    var body: some View {
        TeamLineupView(teamName: teamName, inTheGame: inTheGame, bench: bench)
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    
                    inTheGame.addGoalie(name:"Goalie", num:1, notes: "")
                    for i in (2...7) {
                        inTheGame.addFieldPlayer(name: "Player", num: i, notes: "")
                    }
                    
                    bench.addGoalie(name: "Goalie1", num: 1, notes: "")
                    for i in (8...16) {
                        bench.addFieldPlayer(name: "Player", num: i, notes: "")
                    }
                }
            }
    }
}

struct TeamLineupsView_Previews: PreviewProvider {
    static var inTheGame = LineupWithCapNumbers()
    static var bench = LineupWithCapNumbers()
    static var previews: some View {
        TeamLineupContainerView(
//            inTheGame: Lineup(goalies: [], field: ["Player1", "Player2", "Player3", "Player4", "Player5", "Player6"]),
            inTheGame: inTheGame,
//            bench: Lineup(goalies: ["Konstantinos Mathiopoulos"], field: ["Player7", "Player8", "Player9", "Player10", "Player11"]),
            bench: bench,
            teamName: "Stanford"
        )
        .environmentObject(FirebaseManager())
    }
}

