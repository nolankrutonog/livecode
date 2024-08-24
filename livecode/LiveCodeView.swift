//
//  LiveCodeView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import SwiftUI
import FirebaseCore

struct LiveCodeView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Solid white background
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // App logo or title
                    Text("LiveCode")
                        .font(.system(size: 48, weight: .bold, design: .default)) // Bold font
                        .foregroundColor(.black) // Black font color
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Navigation buttons
//                    NavigationLink(destination: EditRostersView()) {
//                        MenuButton(title: "Edit Rosters", icon: "list.bullet")
//                    }

                    NavigationLink(destination: NewGameView()) {
                        MenuButton(title: "Start New Game", icon: "plus.circle")
                    }
                    
                    
                    NavigationLink(destination: FollowLiveGameView()) {
                        MenuButton(title: "Follow Live Game", icon: "play.circle")
                    }
                    

                    NavigationLink(destination: PreviousGamesView()) {
                        MenuButton(title: "Previous Games", icon: "clock.arrow.circlepath")
                    }
                    
                    Spacer()
                }
                .padding()
                .toolbar {
                    
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        NavigationLink(destination: EditRostersView()) {
//                            Image(systemName: "list.triangle")
//                        }
//                    }
                }
            }
        }
    }
   
}


struct FollowLiveGameView: View {
    var body: some View {
        VStack {
            
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.1)) // Light black background for buttons
        .foregroundColor(.black) // Black font color for button text
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 1) // Black border for buttons
        )
    }
}

//#Preview {
//    LiveCodeView()
//}

struct LiveCodeView_Preview: PreviewProvider {
    static var previews: some View {
        LiveCodeView()
            .environmentObject(FirebaseManager())
    }
}
