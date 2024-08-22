//
//  TeamLineupsView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/20/24.
//

import SwiftUI

struct TeamLineupView: View {
    let teamName: String
    @Binding var lineup: Lineup
    @Binding var bench: [String]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let maxFieldPlayers = 6
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                inTheGameView(players: $lineup.fieldPlayers, otherPlayers: $bench, height: geometry.size.height * 0.45)
                benchView(players: $bench, otherPlayers: $lineup.fieldPlayers, height: geometry.size.height * 0.45)
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
    }
    
    
    func inTheGameView(players: Binding<[String]>, otherPlayers: Binding<[String]>, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("In the game")
                .font(.headline)
                .foregroundStyle(.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color:.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(players.wrappedValue, id: \.self) { player in
                            Text(player)
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(.green.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(color: .green.opacity(0.3), radius: 2, x: 0, y: 1)
                                .onDrag {
                                    NSItemProvider(object: player as NSString)
                                }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: height)
            .onDrop(of: [.text], delegate: BoxDropDelegate(destinationBoxes: players, sourceBoxes: otherPlayers, isInTheGame: true, maxFieldPlayers: maxFieldPlayers))

        }
    }
    func benchView(players: Binding<[String]>, otherPlayers: Binding<[String]>, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bench")
                .font(.headline)
                .foregroundStyle(.primary)
            
                        ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color:.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(players.wrappedValue, id: \.self) { player in
                            Text(player)
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(.gray.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                                .onDrag {
                                    NSItemProvider(object: player as NSString)
                                }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: height)
            .onDrop(of: [.text], delegate: BoxDropDelegate(destinationBoxes: players, sourceBoxes: otherPlayers, isInTheGame: false, maxFieldPlayers: maxFieldPlayers))

        }
    }

}

struct BoxDropDelegate: DropDelegate {
    @Binding var destinationBoxes: [String]
    @Binding var sourceBoxes: [String]
    
    let isInTheGame: Bool
    let maxFieldPlayers: Int
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return false }
        
        itemProvider.loadObject(ofClass: NSString.self) { (reading, error) in
            if let error = error {
                print("Error loading dragged item: \(error.localizedDescription)")
                return
            }
            
            guard let item = reading as? String else { return }
            
            DispatchQueue.main.async {
                if let sourceIndex = self.sourceBoxes.firstIndex(of: item) {
                    self.sourceBoxes.remove(at: sourceIndex)
                    
                    if self.isInTheGame {
                        if self.destinationBoxes.count < self.maxFieldPlayers {
                            self.destinationBoxes.append(item)
                        } else {
                            // If "In the game" is full, put the player back in the source
                            self.sourceBoxes.insert(item, at: sourceIndex)
                        }
                    } else {
                        // Moving to bench, always allow
                        self.destinationBoxes.insert(item, at: 0)
                    }
                }
            }
        }
        return true
    }
}
    

// TESTING
struct TeamLineupContainerView: View {
    @State var lineup: Lineup
    @State var bench: [String]
    let teamName: String
    
    var body: some View {
        TeamLineupView(teamName: teamName, lineup: $lineup, bench: $bench)
    }
}

struct TeamLineupsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamLineupContainerView(
            lineup: Lineup(fieldPlayers: ["Player10", "Player11"]),
            bench: (0...9).map { "Player\($0)" },
            teamName: "Stanford"
        )
    }
}
