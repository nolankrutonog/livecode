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
    
    @Binding var homeLineup: Lineup
    @Binding var homeBench: [String]
    @Binding var awayLineup: Lineup
    @Binding var awayBench: [String]

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
                TeamLineupView(teamName: homeTeam, lineup: $homeLineup, bench: $homeBench)
            } else {
                TeamLineupView(teamName: awayTeam, lineup: $awayLineup, bench: $awayBench)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct LineupsView_Previews: PreviewProvider {
    @State static var homeLineup: Lineup = Lineup()
            

    @State static var homeBench: [String] = UserDefaults.standard.array(forKey: "Stanford_names") as? [String] ?? []
    @State static var awayLineup: Lineup = Lineup()
    @State static var awayBench: [String] = UserDefaults.standard.array(forKey: "UCLA_names") as? [String] ?? []

    static var previews: some View {
        LineupsView(
            homeTeam: "Stanford",
            awayTeam: "UCLA",
            homeLineup: $homeLineup,
            homeBench: $homeBench,
            awayLineup: $awayLineup,
            awayBench: $awayBench
        )
    }
}
