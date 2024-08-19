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
    
    @Binding var homeLineup: [String: Any]
    @Binding var awayLineup: [String: Any]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    TeamLineupView(teamName: homeTeam, lineup: $homeLineup)
                        .frame(width: geometry.size.width / 2)
                    
                    Divider()
                    
                    TeamLineupView(teamName: awayTeam, lineup: $awayLineup)
                        .frame(width: geometry.size.width / 2)
                }
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
        }
    }
}


struct TeamLineupView: View {
    let teamName: String
    @Binding var lineup: [String: Any]
    
    @State private var selectedPosition: Position?
    @State private var bench: [String] = []
    
    init(teamName: String, lineup: Binding<[String: Any]>) {
        self.teamName = teamName
        self._lineup = lineup
        self._bench = State(initialValue: UserDefaults.standard.array(forKey: "\(teamName)_names") as? [String] ?? [])
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
        .onChange(of: bench) { newValue in
            UserDefaults.standard.set(newValue, forKey: "\(teamName)_bench")
        }
    }
    
    private var goalie: String {
        lineup["goalie"] as? String ?? ""
    }
    
    private var field: [String] {
        lineup["field"] as? [String] ?? Array(repeating: "", count: 6)
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
        
        let fromIsBench = if case .bench(_) = from { true } else { false }
        let toIsBench = if case .bench(_) = to { true } else { false }
        
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
        var newLineup = lineup
        switch position {
        case .goalie:
            newLineup["goalie"] = player
        case .field(let index):
            var newField = field
            newField[index] = player
            newLineup["field"] = newField
        case .bench(let index):
            if index < bench.count {
                bench[index] = player
            } else {
                bench.append(player)
            }
        }
        lineup = newLineup
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
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

struct LineupsView_Previews: PreviewProvider {
    @State static var homeLineup: [String: Any] = ["goalie": "", "field": ["", "", "", "", "", ""]]
    @State static var awayLineup: [String: Any] = ["goalie": "", "field": ["", "", "", "", "", ""]]
    
    static var previews: some View {
        LineupsView(
            homeTeam: "Stanford 2024",
            awayTeam: "USC 2024",
            homeLineup: $homeLineup,
            awayLineup: $awayLineup
        )
    }
}
