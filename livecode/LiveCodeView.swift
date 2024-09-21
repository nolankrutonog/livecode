//
//  LiveCodeView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import SwiftUI
//import FirebaseCore

struct LiveCodeView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Solid white background
//                Color.white
//                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // App logo or title
                    Text("LiveCode")
                        .font(.system(size: 48, weight: .bold, design: .default)) // Bold font
                        .foregroundColor(.primary) // Black font color
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Navigation buttons
//                    NavigationLink(destination: EditRostersView()) {
//                        MenuButton(title: "Edit Rosters", icon: "list.bullet")
//                    }

                    NavigationLink(destination: NewGameView().environmentObject(firebaseManager)) {
//                        MenuButton(title: "Start New Game", icon: "plus.circle.fill")
                        MenuButton(title: "Stat New Game", icon: "note.text.badge.plus")
                    }
                    
                    NavigationLink(destination: SelectLiveGameView(destinationGameView: true).environmentObject(firebaseManager)) {
                        MenuButton(title: "Stat Live Game", icon: "note.text")
                    }
                   
                    NavigationLink(destination: SelectLiveGameView(destinationGameView: false).environmentObject(firebaseManager)) {
                        MenuButton(title: "Follow Live Game", icon: "figure.waterpolo")
                    }

                    NavigationLink(destination: PreviousGamesView().environmentObject(firebaseManager)) {
                        MenuButton(title: "Finished Games", icon: "clock.arrow.circlepath")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SelectRosterView().environmentObject(firebaseManager)) {
                        Image(systemName: "list.triangle")
                            .foregroundStyle(Color.primary)
                    }
                    
                    .padding(.horizontal, 10)
                }
            }
        }
    }
}


struct MenuButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2.bold())
            Text(title)
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding()
        .background(Color.primary.opacity(0.1)) // Light black background for buttons
        .foregroundColor(.primary) // Black font color for button text
        .cornerRadius(15)
    }
}


//struct StatLiveGame: View {
//    var body: some View {
//        VStack {
//            
//        }
//    }
//}
//
//
//struct FollowLiveGameView: View {
//    var body: some View {
//        VStack {
//            
//        }
//    }
//}

struct LiveCodeView_Preview: PreviewProvider {
    static var previews: some View {
        LiveCodeView()
            .environmentObject(FirebaseManager())
    }
}
