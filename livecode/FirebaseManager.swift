//
//  FirebaseManager.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/23/24.
//

import Firebase


struct Lineup {
    var goalies: [String] = []
    var fieldPlayers: [String] = []
}

//class FirebaseManager: ObservableObject {
//    @Published var rosters: [String: Lineup] = [:]
////    @Published var allRosters: [Int: [String: [String]]] = [:]
//    let db = Firestore.firestore()
//    private var isFetched: Bool = false
//
//    init() {
//        fetchRosters()
//    }
//
//    /* fetch the rosters from Firebase of the current year only if needed
//        rosters in Firebase:
//        * key: year: Int
//        * value: ["teamName": ["field": [players], "goalies": [goalies]]]
//     */
//    func fetchRosters() {
//        guard !isFetched else { return }
//
//        isFetched = true
//
//        db.collection("rosters").getDocuments() { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting rosters: \(error)")
//            } else {
//                var fetchedAllRosters: [Int: [String: Lineup]] = [:]
//                for document in querySnapshot!.documents {
//                    if let year = Int(document.documentID) {
//                        if let data = document.data() as? [String: [String: [String]]] {
//                            var teamLineups: [String: Lineup] = [:]
//                            for (teamName, players) in data {
//                                let goalies = players["goalies"] ?? []
//                                let fieldPlayers = players["field"] ?? []
//                                teamLineups[teamName] = Lineup(goalies: goalies, fieldPlayers: fieldPlayers)
//                            }
//                            fetchedAllRosters[year] = teamLineups
//                        }
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.rosters = fetchedAllRosters[Calendar.current.component(.year, from: Date())] ?? [:]
//                }
//            }
//        }
//    }
//
//    /* returns the players of teamName */
//    func getFullLineupOf(teamName: String) -> Lineup {
//        if !isFetched {
//            fetchRosters()
//        }
//        return rosters[teamName] ?? Lineup()
//    }
//
//    func createGameDocument(gameName: String) async {
//        let newGameName = gameName + " " + String(Int(Date().timeIntervalSince1970))
//        do {
//            try await db.collection("games")
//                .document(newGameName).setData([:])
//        } catch {
//            print("Error creating game: \(gameName)")
//        }
//    }
//}

class FirebaseManager: ObservableObject {
    @Published var rosters: [String: Lineup] = [:]
    let db = Firestore.firestore()
    private var isFetched: Bool = false
    
    init() {
        Task {
            await fetchRosters()
        }
    }

    func fetchRosters() async {
        guard !isFetched else { return }
        isFetched = true
        
        do {
            let querySnapshot = try await db.collection("rosters").getDocuments()
            var fetchedAllRosters: [Int: [String: Lineup]] = [:]
            for document in querySnapshot.documents {
                if let year = Int(document.documentID) {
                    if let data = document.data() as? [String: [String: [String]]] {
                        var teamLineups: [String: Lineup] = [:]
                        for (teamName, players) in data {
                            let goalies = players["goalies"] ?? []
                            let fieldPlayers = players["field"] ?? []
                            teamLineups[teamName] = Lineup(goalies: goalies, fieldPlayers: fieldPlayers)
                        }
                        fetchedAllRosters[year] = teamLineups
                    }
                }
            }
            DispatchQueue.main.async {
                self.rosters = fetchedAllRosters[Calendar.current.component(.year, from: Date())] ?? [:]
            }
        } catch {
            print("Error getting rosters: \(error.localizedDescription)")
        }
    }
    
    func getFullLineupOf(teamName: String) -> Lineup {
        return rosters[teamName] ?? Lineup()
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
