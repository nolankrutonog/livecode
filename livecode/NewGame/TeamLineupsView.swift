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

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let buttonWidth: CGFloat = 120 // Fixed width for buttons
    let buttonHeight: CGFloat = 40 // Fixed height for buttons
    let maxNameLength: Int = 12

    var body: some View {
        VStack {
            Text("Goalie")
                .font(.title)
                .bold()
            
            HStack {
                if !inTheGame.goalies.isEmpty {
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
            
            Text("Field Players")
                .font(.title)
                .bold()
                .padding(.top, 20)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(inTheGame.fieldPlayers, id: \.self) { player in
                        Button(action: {
                            if let index = inTheGame.fieldPlayers.firstIndex(of: player) {
                                inTheGame.fieldPlayers.remove(at: index)
                                bench.fieldPlayers.insert(player, at: 0)
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
                    ForEach(bench.fieldPlayers, id: \.self) { player in
                        Button(action: {
                            if inTheGame.fieldPlayers.count < 6 {
                                if let index = bench.fieldPlayers.firstIndex(of: player) {
                                    bench.fieldPlayers.remove(at: index)
                                    inTheGame.fieldPlayers.append(player)
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

}

struct TeamLineupContainerView: View {
    @State var inTheGame: Lineup
    @State var bench: Lineup
    let teamName: String
    
    var body: some View {
        TeamLineupView(teamName: teamName, inTheGame: $inTheGame, bench: $bench)
    }
}

struct TeamLineupsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamLineupContainerView(
            inTheGame: Lineup(goalies: [], fieldPlayers: ["Player1", "Player2", "Player3", "Player4", "Player5", "Player6"]),
            bench: Lineup(goalies: ["Konstantinos Mathiopoulos"], fieldPlayers: ["Player7", "Player8", "Player9", "Player10", "Player11"]),
            teamName: "Stanford"
        )
    }
}

