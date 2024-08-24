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
    
    @Binding var homeInTheGame: Lineup
    @Binding var homeBench: Lineup
    @Binding var awayInTheGame: Lineup
    @Binding var awayBench: Lineup

    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTab: Int = 0
    
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
            
            // Content View
            if selectedTab == 0 {
                TeamLineupView(teamName: homeTeam, inTheGame: $homeInTheGame, bench: $homeBench)
            } else {
                TeamLineupView(teamName: awayTeam, inTheGame: $awayInTheGame, bench: $awayBench)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct LineupsView_Previews: PreviewProvider {
    @StateObject static var firebaseManager = FirebaseManager()
    @State static var homeInTheGame: Lineup = Lineup()
    @State static var homeBench: Lineup = Lineup()
    @State static var awayInTheGame: Lineup = Lineup()
    @State static var awayBench: Lineup = Lineup()
    
    static var previews: some View {
        LineupsView(
            homeTeam: "Stanford",
            awayTeam: "UCLA",
            homeInTheGame: $homeInTheGame,
            homeBench: $homeBench,
            awayInTheGame: $awayInTheGame,
            awayBench: $awayBench
        )
        .environmentObject(firebaseManager)
        .onAppear {
            Task {
                await firebaseManager.fetchRosters()
            }
            homeBench = firebaseManager.getFullLineupOf(teamName: "Stanford")
            awayBench = firebaseManager.getFullLineupOf(teamName: "UCLA")


        }
    }
}


