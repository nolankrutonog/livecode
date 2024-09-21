//
//  EditRostersView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/16/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct DisplayRosterView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.presentationMode) var presentationMode
    
    let rosterName: String
    
    @State private var editRoster: Bool = false
    @State private var showAddPlayerSheet: Bool = false
    @StateObject private var lineup: LineupWithCapNumbers = LineupWithCapNumbers()
    @State private var lineupCopy: LineupWithCapNumbers?

    var body: some View {
        VStack {
            Form {
                if lineup.goalies.count > 0 {
                    Section("Goalies") {
                        ForEach(lineup.goalies) { goalie in
                            Text("\(goalie.num). \(goalie.name)")
                        }
                        .if(editRoster) { view in
                            view.onDelete(perform: lineup.removeGoalie)
                        }
                    }
                }
                if lineup.field.count > 0 {
                    Section("Field") {
                        ForEach(lineup.field) { player in
                            Text("\(player.num). \(player.name)")
                        }
                        .if(editRoster) { view in
                            view.onDelete(perform: lineup.removeFieldPlayer)
                        }
                    }
                }
            }
        }
        .if(editRoster) { view in
            view.overlay(
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
            
        }
        .sheet(isPresented: $showAddPlayerSheet) {
            NavigationStack {
                AddPlayerView(lineup: lineup)
            }
        }
        .onAppear {
            Task {
                do {
                    let fetchedLineup = try await firebaseManager.fetchRoster(rosterName: rosterName)
                    lineup.update(from: fetchedLineup)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .navigationTitle(rosterName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            cancelBackToggleButton()
            editDoneToggleButton()
        }
    }
    
    private func cancelBackToggleButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                if editRoster {
                    // Cancel edits and restore original lineup
                    if let copy = lineupCopy {
                        lineup.update(from: copy)
                        lineupCopy = nil
                    }
                    editRoster = false
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    if !editRoster {
                        Image(systemName: "chevron.left")
                    }
                    Text(editRoster ? "Cancel" : "Back")
                }
            }
        }
    }
    
    private func editDoneToggleButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(editRoster ? "Done" : "Edit") {
                if editRoster {
                    // Run async task to save changes
                    Task {
                        do {
                            try await firebaseManager.createNewRoster(team: rosterName, lineup: lineup)
                            lineupCopy = nil // Clear lineup copy after saving
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    // Store original lineup before editing
                    lineupCopy = lineup.copy()
                }
                editRoster.toggle()
            }
        }
    }
}


struct DisplayRosterView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DisplayRosterView(rosterName: "USC").environmentObject(FirebaseManager())
        }
    }
}


struct EditRosterView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let rosterName: String
    
    @Binding private var lineup: LineupWithCapNumbers
    
    var body: some View {
        Form {
            Section(
                header: Text("Roster name"),
                footer: footer()
            ) {
                Text(rosterName)
                    .font(.title2)
                    .padding(.vertical, 10)
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
        .onAppear {
            Task {
                do {
                    lineup = try await firebaseManager.fetchRoster(rosterName: rosterName)
                } catch {
                    print(error.localizedDescription)
                }
            }
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
}
