//
//  FirebaseManager.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/23/24.
//

import Firebase


class FirebaseManager: ObservableObject {
    @Published var rosters: [String: Lineup] = [:]
    let db = Firestore.firestore()
    private var isFetched: Bool = false
    
    init() {
        Task {
            do {
                try await fetchRosters()
            } catch {
                print("Error fetching rosters: \(error.localizedDescription)")
            }
        }
    }

    func fetchRosters() async throws {
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
                            teamLineups[teamName] = Lineup(goalies: goalies, field: fieldPlayers)
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
            throw FirebaseError.fetchRostersFailed
        }
    }
    
    /* returns a Lineup() given the teamName */
    func getFullLineupOf(teamName: String) -> Lineup {
        return rosters[teamName] ?? Lineup()
    }
    
    /* Creates a game document in Fireabse */
    func createGameDocument(gameName: String) async throws -> String {
        let newGameName = gameName + "_" + String(Int(Date().timeIntervalSince1970))
        do {
            try await db.collection("games")
                .document(newGameName).setData([:])
        } catch {
            print("Error creating game: \(gameName)")
            throw FirebaseError.gameCreationFailed(gameName: gameName)
        }
        print(newGameName)
        return newGameName
    }
    
    /* creates a lineup stat in the given gameDocumentName */
    func createLineupsStat(gameDocumentName: String, quarter: Int, timeString: String,
                          homeTeam: String, awayTeam: String,
                           homeInTheGame: Lineup, awayInTheGame: Lineup) async throws {
        let lineupData: [String: Any] = [
            LineupKeys.quarter: quarter,
            LineupKeys.timeString: timeString,
            LineupKeys.homeTeam: homeTeam,
            LineupKeys.awayTeam: awayTeam,
            LineupKeys.homeInTheGame: [
                LineupKeys.goalies: homeInTheGame.goalies,
                LineupKeys.field: homeInTheGame.field
            ],
            LineupKeys.awayInTheGame: [
                LineupKeys.goalies: awayInTheGame.goalies,
                LineupKeys.field: awayInTheGame.field
            ]
        ]
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .updateData([
                    StatKeys.lineup : FieldValue.arrayUnion([lineupData])
                ])
        } catch {
            throw FirebaseError.lineupStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }
    
    func createTurnoverStat(gameDocumentName: String, quarter: Int, timeString: String, team: String, player: String) async throws {
        let turnoverData: [String: Any] = [
            TurnoverKeys.quarter: quarter,
            TurnoverKeys.timeString: timeString,
            TurnoverKeys.team: team,
            TurnoverKeys.player: player
        ]
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .updateData([
                    StatKeys.turnover: FieldValue.arrayUnion([turnoverData])
                ])
        } catch {
            throw FirebaseError.turnoverStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }
    
}


enum FirebaseError: Error, LocalizedError {
    case fetchRostersFailed
    case gameCreationFailed(gameName: String)
    case lineupStatCreationFailed(gameDocumentName: String)
    case turnoverStatCreationFailed(gameDocumentName: String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .fetchRostersFailed:
            return "Failed to fetch the rosters"
        case .gameCreationFailed(let gameName):
            return "Failed to start game \(gameName)"
        case .lineupStatCreationFailed(let gameDocumentName):
            return "Failed to upload lineup stat to game \(gameDocumentName)"
        case .turnoverStatCreationFailed(let gameDocumentName):
            return "Failed to upload turnover stat to game \(gameDocumentName)"
        case .networkError:
            return "Network error occurred. Please check your internet connection"
        }
    }
}
