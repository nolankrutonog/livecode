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
    
    @State private var selectedPlayerTag: Int = -1
    
    @State private var dummyBench: [String] = (0...9).map { "player\($0)"}
    
    init(teamName: String, lineup: Binding<Lineup>, bench: Binding<[String]>) {
        self.teamName = teamName
        self._lineup = lineup
        self._bench = bench
    }
    
    var body: some View {
        VStack {
            VStack {
                // Field Section
                Text("Field")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                HStack(spacing: 10) {
                    VStack {
                        PlayerContainer(containerTag: 0, playerName: "", playerBlock: nil)
                            .onTapGesture {
                                movePlayer(at: 0)
                            }
                        PlayerContainer(containerTag: 1, playerName: "", playerBlock: nil)
                            .onTapGesture {
                                movePlayer(at: 1)
                            }
                    }
                    VStack {
                        PlayerContainer(containerTag: 2, playerName: "", playerBlock: nil)
                            .onTapGesture {
                                movePlayer(at: 2)
                            }
                        PlayerContainer(containerTag: 3, playerName: "", playerBlock: nil)
                            .onTapGesture {
                                movePlayer(at: 3)
                            }
                        
                    }
                    VStack {
                        PlayerContainer(containerTag: 4, playerName: "", playerBlock: nil)
                            .onTapGesture {
                                movePlayer(at: 4)
                            }
                        PlayerContainer(containerTag: 5, playerName: "", playerBlock: nil)
                            .onTapGesture {
                                movePlayer(at: 5)
                            }
                    }

                    
                }
                .padding()
                
                // Goalie Section
                Text("Goalie")
                    .font(.headline)
                    .padding(.top, 10)
                PlayerContainer(containerTag: 6, playerName: "", playerBlock: nil)
                    .onTapGesture {
                        movePlayer(at: 6)
                    }

                Divider()
                
                VStack {
                    Text("Bench")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), // 4 columns with spacing
                            spacing: 16 // Vertical spacing between rows
                        ) {
                            ForEach(dummyBench.indices, id: \.self) { index in
                                PlayerBlock(playerTag: index, playerName: dummyBench[index], selectedPlayerTag: $selectedPlayerTag)
                                    .onTapGesture {
                                        if selectedPlayerTag == -1 {
                                            selectedPlayerTag = index
                                        } else if selectedPlayerTag != index {
                                            dummyBench.swapAt(selectedPlayerTag, index)
                                            selectedPlayerTag = -1
                                        }
                                        else {
                                            selectedPlayerTag = -1
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16) // Add padding to the sides of the grid
                    }
                }
                .frame(maxHeight: .infinity)
                .padding()
                
                Spacer()
            }
        }
    }
    
    private func movePlayer(at index: Int) {
        if selectedPlayerTag != -1 {
            
        }
    }
    
//    private func createPlayerContainer() -> PlayerContainer {
//       PlayerContainer(
//    }
    
    
}
    


struct PlayerContainer: View {
    let containerTag: Int
    let playerName: String
    var playerBlock: PlayerBlock?
    
    var body: some View {
        ZStack {
            if let playerBlock = playerBlock {
                playerBlock
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2)) // Match the default background color of a PlayerBlock
                    .frame(width: 90, height: 90) // Set the same size as PlayerBlock
                    .cornerRadius(15) // Match the corner radius of PlayerBlock
            }
        }
        .onTapGesture {
            
        }
    }
}

struct PlayerBlock: View {
    let playerTag: Int
    let playerName: String
    @Binding var selectedPlayerTag: Int
    
    var body: some View {
        Text(playerName)
            .multilineTextAlignment(.center) // Center align the text
            .padding(3)
            .frame(width: 80, height: 80) // Ensure it's a square
            .background(playerTag == selectedPlayerTag ? Color.blue : Color.gray.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1) // Optional border
            )
    }
}


struct TeamLineupsView_Previews: PreviewProvider {
    @State static var lineup: Lineup = Lineup()
    @State static var bench: [String] = (0...9).map { "player\($0)" }
    static var previews: some View {
        
        TeamLineupView(teamName: "Stanford", lineup: $lineup, bench: $bench)
    }
}
