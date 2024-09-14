//
//  NewRosterView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/14/24.
//

import SwiftUI

struct NewRosterView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rosterName: String = ""
    @State private var lineup: Lineup = Lineup()
    
    @State private var showNewPlayerSheet: Bool = false
    
    var body: some View {
        VStack {
            
            TextField("Roster name", text: $rosterName)
                .font(.title2) // Set the font size to title
                .padding(15)  // Padding inside the text field
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 2) // Add the outline
               )
            
            if lineup.goalies.count > 0 {
                HStack {
                    Text("Goalies")
                        .font(.title2)
                        .bold()
                    
                    Spacer()

                }
                
                ForEach(lineup.goalies, id: \.self) { goalie in
                    Text(goalie)
                    
                }

            }
            
            if lineup.field.count > 0 {
                HStack {
                    Text("Field")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                
                ForEach(lineup.field, id: \.self) { player in
                    Text(player)
                    
                }
            }

            Spacer()
        }
        .padding()
        .overlay(
            Button(action: {
                showNewPlayerSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                , alignment: .bottomTrailing // Align the button to the bottom-right
        )
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    Task {
                        do {
                            // try await firebaseManager.createNewRoster()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showNewPlayerSheet) {
            AddPlayerView(lineup: $lineup)
        }
    }
}

struct AddPlayerView: View {
    @Binding var lineup: Lineup
    
    var body: some View {
        VStack {
            
        }
    }
}

struct NewRosterView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewRosterView().environmentObject(FirebaseManager())
        }
    }
}
