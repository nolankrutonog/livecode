//
//  MakeStatView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/19/24.
//

import SwiftUI

struct SelectStatView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameDocumentName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
   
    init(gameDocumentName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameDocumentName = gameDocumentName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
    }
    
    var body: some View {
        
//        NavigationStack(path: $navigationPath) {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    NavigationLink(destination: ShotSingleView(
                        gameDocumentName: gameDocumentName,
                        quarter: quarter,
                        homeTeam: homeTeam,
                        awayTeam: awayTeam,
                        homeInTheGame: homeInTheGame,
                        awayInTheGame: awayInTheGame
                    ).environmentObject(firebaseManager)
                    ) {
                        StatButton(label: "Shot", gradientColors: [Color.pastelBlue, Color.pastelPurple], iconName: "figure.waterpolo")
                    }
                    
                    NavigationLink(destination: TurnoverView(
                        gameDocumentName: gameDocumentName,
                        quarter: quarter,
                        homeTeam: homeTeam,
                        awayTeam: awayTeam,
                        homeInTheGame: homeInTheGame,
                        awayInTheGame: awayInTheGame
                    )) {
                        StatButton(label: "Turnover", gradientColors: [Color.pastelBlue, Color.pastelPurple], iconName: "hand.thumbsdown.fill")
                    }
                    
                    NavigationLink(destination: ExclusionView(
                        gameDocumentName: gameDocumentName,
                        quarter: quarter,
                        homeTeam: homeTeam,
                        awayTeam: awayTeam,
                        homeInTheGame: homeInTheGame,
                        awayInTheGame: awayInTheGame
                    )) {
                        StatButton(label: "Exclusion", gradientColors: [Color.pastelBlue, Color.pastelPurple], iconName: "person.slash.fill")
                    }
                    
                    NavigationLink(destination: StealView(
                        gameDocumentName: gameDocumentName,
                        quarter: quarter,
                        homeTeam: homeTeam,
                        awayTeam: awayTeam,
                        homeInTheGame: homeInTheGame,
                        awayInTheGame: awayInTheGame
                    )) {
                        StatButton(label: "Steal", gradientColors: [Color.pastelBlue, Color.pastelPurple], iconName: "volleyball.fill")
                    }
                    
                    NavigationLink(destination: TimeoutView(
                        gameDocumentName: gameDocumentName,
                        quarter: quarter,
                        homeTeam: homeTeam,
                        awayTeam: awayTeam
                    )) {
                        StatButton(label: "Timeout", gradientColors: [Color.pastelBlue, Color.pastelPurple], iconName: "timer")
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}

extension Color {
    static let pastelBlue = Color(red: 174/255, green: 198/255, blue: 207/255)
    static let pastelPink = Color(red: 255/255, green: 209/255, blue: 220/255)
    static let pastelGreen = Color(red: 119/255, green: 221/255, blue: 119/255)
    static let pastelYellow = Color(red: 253/255, green: 253/255, blue: 150/255)
    static let pastelPurple = Color(red: 179/255, green: 158/255, blue: 181/255)
    static let pastelOrange = Color(red: 255/255, green: 179/255, blue: 71/255)
}

struct StatButton: View {
    let label: String
    let gradientColors: [Color] // Use a gradient for each button
    let iconName: String
    
    var body: some View {
        ZStack {
            // Gradient background with shadow
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            
            VStack {
                Spacer()
                
                // Placeholder for an icon in the top right corner
                HStack {
                    Spacer()
                    Image(systemName: iconName) // Replace with your actual icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 30)
                        .foregroundColor(.white.opacity(0.7))
                        .padding([.top, .trailing], 10)
                }
                
                // Label at the bottom left
                HStack {
                    Text(label)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding([.leading, .bottom], 10)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .navigationTitle("Stat")
    }
}





struct SelectStatView_Preview: PreviewProvider {
    @State static var navigationPath: [AnyHashable] = []
    static var previews: some View {
        NavigationStack {
            SelectStatView(
                gameDocumentName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame
//                navigationPath: $navigationPath
            )
            .environmentObject(FirebaseManager())
        }
    }
}


