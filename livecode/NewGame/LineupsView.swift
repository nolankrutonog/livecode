//
//  LineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

import SwiftUI

struct LineupsView: View {
    let homeTeam: String
    let awayTeam: String
    @Binding var homeLineup: [String]
    @Binding var awayLineup: [String]
    
    private let userDefaultsHomeTeamKey: String
    private let userDefaultsAwayTeamKey: String
    
    @State private var homeRoster: [String]
    @State private var awayRoster: [String]
    
    init(homeTeam: String, awayTeam: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        userDefaultsHomeTeamKey = "\(homeTeam)_names"
        userDefaultsAwayTeamKey = "\(awayTeam)_names"
        
        _homeRoster = State(initialValue: UserDefaults.standard.array(forKey: userDefaultsHomeTeamKey) as? [String] ?? [])
        _awayRoster = State(initialValue: UserDefaults.standard.array(forKey: userDefaultsAwayTeamKey) as? [String] ?? [])
        
        self._homeLineup = Array(repeating: "", count:7)
        self._awayLineup = Array(repeating: "", count:7)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                TeamLineupView(teamName: homeTeam, roster: homeRoster)
                    .frame(width: geometry.size.width / 2)
                
                Divider()
                
                TeamLineupView(teamName: awayTeam, roster: awayRoster)
                    .frame(width: geometry.size.width / 2)
            }
        }
    }
}


struct TeamLineupView: View {
    let teamName: String
    let roster: [String]
    
    @State private var goalie: String = ""
    @State private var field: [String] = Array(repeating: "", count: 6)
    @State private var bench: [String]
    @State private var selectedPosition: Position?
    
    init(teamName: String, roster: [String]) {
        self.teamName = teamName
        self.roster = roster
        _bench = State(initialValue: roster)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(teamName)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text("Goalie")
                    .font(.subheadline)
                PlayerSlot(player: goalie, number: nil, isSelected: selectedPosition == .goalie)
                    .onTapGesture { handleTap(position: .goalie) }
                
                Text("Field")
                    .font(.subheadline)
                ForEach(0..<6, id: \.self) { index in
                    PlayerSlot(player: field[index], number: index + 1, isSelected: selectedPosition == .field(index))
                        .onTapGesture { handleTap(position: .field(index)) }
                }
                
                Text("Bench")
                    .font(.subheadline)
                ForEach(bench.indices, id: \.self) { index in
                    PlayerSlot(player: bench[index], number: nil, isSelected: selectedPosition == .bench(index))
                        .onTapGesture { handleTap(position: .bench(index)) }
                }
            }
            .padding()
        }
    }
    
    private func handleTap(position: Position) {
        if let selectedPos = selectedPosition {
            if selectedPos == position {
                selectedPosition = nil
            } else {
                let fromPlayer = getPlayer(at: selectedPos)
                let toPlayer = getPlayer(at: position)
                
                if isValidSwap(from: selectedPos, to: position) {
                    setPlayer(at: selectedPos, player: toPlayer)
                    setPlayer(at: position, player: fromPlayer)
                    
                    if case .bench(let index) = selectedPos, toPlayer.isEmpty {
                        bench.remove(at: index)
                    }
                    if case .bench = position, !fromPlayer.isEmpty {
                        bench.append(fromPlayer)
                    }
                }
                
                selectedPosition = nil
            }
        } else {
            if !getPlayer(at: position).isEmpty {
                selectedPosition = position
            }
        }
    }
    
    private func isValidSwap(from: Position, to: Position) -> Bool {
        let fromPlayer = getPlayer(at: from)
        let toPlayer = getPlayer(at: to)
        
        // Check if either position is on the bench
        let fromIsBench = if case .bench(_) = from { true } else { false }
        let toIsBench = if case .bench(_) = to { true } else { false }
        
        // Allow swaps between non-empty positions or from bench to empty positions
        return !fromPlayer.isEmpty && (fromIsBench || toIsBench || !toPlayer.isEmpty)
    }
    
    private func getPlayer(at position: Position) -> String {
        switch position {
        case .goalie:
            return goalie
        case .field(let index):
            return field[index]
        case .bench(let index):
            return bench[index]
        }
    }
    
    private func setPlayer(at position: Position, player: String) {
        switch position {
        case .goalie:
            goalie = player
        case .field(let index):
            field[index] = player
        case .bench(let index):
            if index < bench.count {
                bench[index] = player
            } else {
                bench.append(player)
            }
        }
    }
}

enum Position: Equatable {
    case goalie
    case field(Int)
    case bench(Int)
}

struct PlayerSlot: View {
    let player: String
    let number: Int?
    let isSelected: Bool
    
    var body: some View {
        Text(player.isEmpty ? (number.map { "\($0)" } ?? "") : player)
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .cornerRadius(5)
            .lineLimit(1) // Limit to one line
            .truncationMode(.tail) // Add ellipsis if the text is too
    }
}

#Preview {
    LineupsView(homeTeam: "Stanford 2024", awayTeam: "USC 2024")
}
