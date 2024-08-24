//
//  FirebaseManager.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/23/24.
//

import Firebase

class FirebaseManager: ObservableObject {
    @Published var rosters: [String: [String]] = [:]
//    @Published var allRosters: [Int: [String: [String]]] = [:]
    let db = Firestore.firestore()
    private var isFetched: Bool = false
    
    init() {
        fetchRosters()
    }

    /* fetch the rosters from Firebase of the current year only if needed */
    func fetchRosters() {
        guard !isFetched else { return }
        
        isFetched = true
        
        db.collection("rosters").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting rosters: \(error)")
            } else {
                var fetchedAllRosters: [Int: [String: [String]]] = [:]
                for document in querySnapshot!.documents {
                    if let year = Int(document.documentID) {
                        if let roster = document.data() as? [String: [String]] {
                            fetchedAllRosters[year] = roster
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.rosters = fetchedAllRosters[Calendar.current.component(.year, from: Date())] ?? [:]
                }
            }
        }
    }
    
    /* returns the players of teamName */
    func getPlayersOf(teamName: String) -> [String] {
        return rosters[teamName] ?? []
    }
    
    func createGameDocument(gameName: String) async {
        let newGameName = gameName + " " + String(Int(Date().timeIntervalSince1970))
        do {
            try await db.collection("games")
                .document(newGameName).setData([:])
        } catch {
            print("Error creating game: \(gameName)")
        }
    }
}
