//
//  EditRostersView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import SwiftUI
import FirebaseFirestore

struct Roster{
    var year: Int = 0
    var name: String = ""
    var players: [String] = []
}

struct Rosters {
    var years: [Int: [String: [String]]]
}

class RostersManager: ObservableObject {
    @Published var rosters: [Int: [String: [String]]] = [:]
    private let db = Firestore.firestore()
    
    func fetchRosters() {
        db.collection("rosters").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents from Firebase: \(error)")
            } else {
                var newRosters: [Int: [String: [String]]] = [:]
                for document in querySnapshot!.documents {
                    if let year = Int(document.documentID) {
                        newRosters[year] = document.data() as? [String: [String]] ?? [:]
                    }
                }
                DispatchQueue.main.async {
                    self.rosters = newRosters
                }
            }
        }
    } 
    
    func saveRosters() {
        for (year, yearRosters) in rosters {
            db.collection("rosters").document(String(year)).setData(yearRosters) { error in
                if let error = error {
                    print("Error saving rosters for year \(year): \(error)")
                }
            }
        }
    }

    func saveRoster(year: Int, rosterName: String, players: [String]) {
        db.collection("rosters").document(String(year)).setData([rosterName: players], merge: true) { error in
            if let error = error {
                print("Error saving roster \(rosterName) for year \(year): \(error)")
            }
        }
    }
    
    func deleteRoster(year: Int, name: String) {
        rosters[year]?.removeValue(forKey: name)
        if rosters[year]?.isEmpty == true {
            rosters.removeValue(forKey: year)
        }
        
        // Reflect the deletion in Firebase
        db.collection("rosters").document(String(year)).updateData([
            name: FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error deleting roster \(name) for year \(year): \(error)")
            }
        }
    }
}


struct RostersView: View {
    @StateObject private var rostersManager = RostersManager()
    @State private var isEditing = false
    @State private var editedRosters: [Int: [String: [String]]] = [:]
    @State private var showingNewRoster = false
    @State private var newRoster: Roster?

    var body: some View {
        VStack {
            rosterList
            toolbarItems
        }
        .onAppear(perform: rostersManager.fetchRosters)
        .onChange(of: rostersManager.rosters) { _ in
            if !isEditing {
                editedRosters = rostersManager.rosters
            }
        }
        .sheet(item: $newRoster) { roster in
            RosterDetailView(year: roster.year, name: roster.name, players: roster.players)
        }
    }

    private var rosterList: some View {
        Form {
            ForEach(editedRosters.keys.sorted().reversed(), id: \.self) { year in
                Section(header: Text("\(year)")) {
                    ForEach(editedRosters[year]?.keys.sorted() ?? [], id: \.self) { rosterName in
                        rosterRow(year: year, rosterName: rosterName)
                    }
                    .onDelete { indices in
                        deleteRosters(year: year, at: indices)
                    }
                }
            }
        }
    }

    private func rosterRow(year: Int, rosterName: String) -> some View {
        Group {
            if isEditing {
                TextField("Roster Name", text: Binding(
                    get: { rosterName },
                    set: {
                        let players = editedRosters[year]?[rosterName] ?? []
                        editedRosters[year]?.removeValue(forKey: rosterName)
                        editedRosters[year]?[$0] = players
                    }
                ))
            } else {
                NavigationLink(destination: RosterDetailView(year: year, name: rosterName, players: rostersManager.rosters[year]?[rosterName] ?? [])) {
                    Text(rosterName)
                }
            }
        }
    }

    private var toolbarItems: some View {
        HStack {
            Button(isEditing ? "Save" : "Edit") {
                if isEditing {
                    rostersManager.rosters = editedRosters
                    saveChanges()
                } else {
                    editedRosters = rostersManager.rosters
                }
                isEditing.toggle()
            }
            .padding()

            if isEditing {
                Button("Add Roster") {
                    addNewRoster()
                }
                .padding()
            }
        }
    }

    private func deleteRosters(year: Int, at indices: IndexSet) {
        let rosterNames = editedRosters[year]?.keys.sorted() ?? []
        for index in indices {
            let rosterName = rosterNames[index]
            editedRosters[year]?.removeValue(forKey: rosterName)
            rostersManager.deleteRoster(year: year, name: rosterName)
        }
        if editedRosters[year]?.isEmpty == true {
            editedRosters.removeValue(forKey: year)
        }
    }

    private func addNewRoster() {
        let currentYear = Calendar.current.component(.year, from: Date())
        newRoster = rostersManager.addRoster(year: currentYear, name: "New Roster")
    }

    private func saveChanges() {
        for (year, rosters) in editedRosters {
            for (rosterName, players) in rosters {
                rostersManager.saveRoster(year: year, rosterName: rosterName, players: players)
            }
        }
    }
}



struct RostersView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RostersView()
        }
    }
}
