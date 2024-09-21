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
    @StateObject private var lineup = LineupWithCapNumbers()

    @State private var showAddPlayerSheet: Bool = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        Form {
            Section(
                header: Text("Roster name"),
                footer: footer()
//                {
//                    var text = ""
//                    if lineup.goalies.count < 1 && lineup.field.count < 6 {
//                        let text = "Creating a new roster requires at least 6 field players and 1 goalie"
//                    }
//                    Text(text)
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
            ) {
                TextField("Enter roster name", text: $rosterName)
                    .font(.title2)
                    .padding(.vertical, 10)
                    .focused($isNameFieldFocused)
            }

            if lineup.goalies.count > 0 {
                Section("Goalies") {
                    ForEach(lineup.goalies) { goalie in
                        Text("\(goalie.num). \(goalie.name)")
                    }
                    .onDelete(perform: lineup.removeGoalie)
                }
            }

            if lineup.field.count > 0 {
                Section("Field") {
                    ForEach(lineup.field) { player in
                        Text("\(player.num). \(player.name)")
                    }
                    .onDelete(perform: lineup.removeFieldPlayer)
                }
            }
        }
        .onTapGesture {
            // Dismiss the keyboard when tapping outside the TextField
            isNameFieldFocused = false
        }
        .overlay(
            Button(action: {
                showAddPlayerSheet = true
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
            .padding(.vertical, 10),
            alignment: .bottomTrailing
        )
        .navigationBarBackButtonHidden(true)
        .navigationTitle("New Roster")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelButton()
            doneButton()
            
        }
        .sheet(isPresented: $showAddPlayerSheet) {
            NavigationStack {
                AddPlayerView(lineup: lineup)
            }
        }
    }
    
    private func cancelButton() -> some ToolbarContent {
        return ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func doneButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") {
                Task {
                    do {
                        try await firebaseManager.createNewRoster(team: rosterName, lineup: lineup)
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .disabled(!canCreateRoster())
        }
    }
    
    private func footer() -> some View {
        var text = ""
        if lineup.goalies.count < 1 || lineup.field.count < 6 {
            text = "Creating a new roster requires at least 6 field players and 1 goalie"
        }
        return Text(text)
            .font(.footnote)
            .foregroundColor(.gray)
    }

    private func canCreateRoster() -> Bool {
        return !rosterName.isEmpty && lineup.field.count >= 6 && lineup.goalies.count >= 1
    }
}



struct NewRosterView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewRosterView().environmentObject(FirebaseManager())
        }
    }
}
