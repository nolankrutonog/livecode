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
    
    
    func toTimeElapsed(timeString: String, quarter: Int) -> Int {
        guard timeString.contains(":") else { return 0 }
        
        let secondsInQuarter = 8 * 60
        
        let minutes = timeString.split(separator: ":")[0]
        let seconds = timeString.split(separator: ":")[1]
            
        return secondsInQuarter - (Int(minutes) ?? 0) * 60 + (Int(seconds) ?? 0) + (quarter - 1) * secondsInQuarter
    }

    /* Populates rosters */
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
        
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let lineupData: [String: Any] = [
            StatType.lineup: [
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
        ]
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["\(timeElapsed)": lineupData], merge: true)
        } catch {
            throw FirebaseError.lineupStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }
    
    /* Creates turnover stat in firebase */
    func createTurnoverStat(gameDocumentName: String, quarter: Int, timeString: String, team: String, player: String) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let turnoverData: [String: Any] = [
            StatType.turnover: [
                TurnoverKeys.team: team,
                TurnoverKeys.player: player
            ]
        ]
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["\(timeElapsed)": turnoverData], merge: true)
        } catch {
            throw FirebaseError.turnoverStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }
    /* Creates exclusion stat in firebase */
    func createExclusionStat(gameDocumentName: String, quarter: Int, timeString: String,
                             excludedTeam: String,
                             excludedPlayer: String,
                             phaseOfGame: String,
                             exclusionType: String,
                             drawnBy: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let exclusionData: [String: Any] = [
            StatType.exclusion: [
                ExclusionKeys.excludedTeam: excludedTeam,
                ExclusionKeys.excludedPlayer: excludedPlayer,
                ExclusionKeys.phaseOfGame: phaseOfGame,
                ExclusionKeys.exclusionType: exclusionType,
                ExclusionKeys.drawnBy: drawnBy
            ]
        ]
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["\(timeElapsed)": exclusionData], merge: true)
        } catch {
            throw FirebaseError.turnoverStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }
    
    /* creates a steal statistic for the game GAME_DOCUMENT_NAME */
    func createStealStat(gameDocumentName: String, quarter: Int,
                         timeString: String, selectedTeam: String,
                         stolenBy: String, turnoverBy: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let stealData: [String: Any] = [
            StatType.steal: [
                StealKeys.team: selectedTeam,
                StealKeys.stolenBy: stolenBy,
                StealKeys.turnoverBy: turnoverBy
            ]
        ]

        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["\(timeElapsed)": stealData], merge: true)
        } catch {
            throw FirebaseError.stealStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }
    
    func createTimeoutStat(gameDocumentName: String, quarter: Int,
                           timeString: String, selectedTeam: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let timeoutData: [String: Any] = [
            StatType.timeout: [
                TimeoutKeys.team: selectedTeam
            ]
        ]
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["\(timeElapsed)": timeoutData], merge: true)
        } catch {
            throw FirebaseError.timoutStatCreationFailed(gameDocumentName: gameDocumentName)
        }
    }

}


enum FirebaseError: Error, LocalizedError {
    case fetchRostersFailed
    case gameCreationFailed(gameName: String)
    case lineupStatCreationFailed(gameDocumentName: String)
    case turnoverStatCreationFailed(gameDocumentName: String)
    case exclusionStatCreationFailed(gameDocumentName: String)
    case stealStatCreationFailed(gameDocumentName: String)
    case timoutStatCreationFailed(gameDocumentName: String)
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
        case .exclusionStatCreationFailed(let gameDocumentName):
            return "Failed to upload exclusion stat to game \(gameDocumentName)"
        case .stealStatCreationFailed(let gameDocumentName):
            return "Failed to upload steal stat to game \(gameDocumentName)"
        case .timoutStatCreationFailed(let gameDocumentName):
            return "Failed to upload timout stat to game \(gameDocumentName)"
        case .networkError:
            return "Network error occurred. Please check your internet connection"
        }
    }
}
