//
//  FirebaseManager.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/23/24.
//

import Firebase

class FirebaseManager: ObservableObject {
    let db = Firestore.firestore()
    
//    /*
//     * ROSTERS is a map of the rosters from Firebase. They map from team_name: String (document) to a roster: struct Lineup (field).
//     * The rosters should only be fetched once (upon creating a new game) and in future releases will be able to edit rosters in
//     * Firebase from the app.
//     * rosters is <team_name> : <entire roster> as bench lineup
//     */
//    @Published var rosters: [String: LineupWithCapNumbers] = [:]
//    private var rostersAreFetched: Bool = false

    /*
     * CURRENT_LINEUP is the current in-the-game players on both teams. The home team key is "home_team", found as const homeTeamKey,
     * the same is true for the away team. CURRENT_LINEUP is set from the most recent lineup stat in Firebase of the current game. This
     * requires that each device can only stat one live game at a time. CURRENT_LINEUP is a published variable that is set
     * every time a new lineup stat is added to a game in Firebase.
     * currentLineup is <team_name> : <most recent lineup choice>
     */
    @Published var currentLineup: [String: LineupWithCapNumbers] = [:]
    
    
    /*
     * GAME_DATA is a class that contains the game events. Each device can only follow one game at a time, so addGameListener()
     * will add every stat to GAME_DATA only once. We are calling this populating. After GAME_DATA is fully populated, the Bool
     * GAME_DATA.IS_POPULATED will be set to true, and only the most recent stat will be added to GAME_DATA. When a user decides to leave
     * BoxScoreView(), GAME_IS_POPULATED must be set to false and GAME_DATA emptied, so that the next game the user chooses to
     * follow will be populated with the correct game data.
     */
    @Published var gameDataChanged: Int = 0
    var gameData: GameData = GameData()
   
   
    /*
     * populateGameData() queries the gameCollectionName for all the stats (documents) in the gameCollection. It orders
     * them by gameTimeField ("game_time", also the documentIDs in the gameCollectionName) in ascending order. The snapshot is
     * used to populate the GAME_DATA var of FirebaseManager. This is only called once from BoxScoreView()
     */
    func populateGameData(gameCollectionName: String) async throws {
        let gameRef = db.collection(gamesCollection)
            .document(currentYear)
            .collection(gameCollectionName)

        do {
            var homeTeam: String = ""
            var awayTeam: String = ""
            
            let snapshot = try await gameRef
                .whereField(FieldPath.documentID(), isEqualTo: metadataDocument)
                .getDocuments()
            
            if let metadata = snapshot.documents.first?.data(),
               let ht = metadata[homeTeamKey] as? String,
               let at = metadata[awayTeamKey] as? String {
                homeTeam = ht
                awayTeam = at
            }
          
            let gameSnapshot = try await gameRef
                .whereField(FieldPath.documentID(), isNotEqualTo: metadataDocument)
                .order(by: gameTimeField, descending: false)
                .getDocuments()
            
            var stats: [(Int, String, [String: Any])] = []
            
            for doc in gameSnapshot.documents {
                let data = doc.data()
                
                if let gameTime = data[gameTimeField] as? Int,
                   let statType = data[statTypeField] as? String,
                   let stat = data[statField] as? [String: Any] {
//                    print("populateGameData(), statType: \(statType)")
                    stats.append((gameTime, statType, stat))
                }
                
            }
            // TODO: temporary fix (lol parrish/gigi)
            // removing the last stat because addGameListener(), when snapshot listener is initialized, checks for the most
            // recent stat. So i don't want to count it twice
            stats.remove(at: stats.count - 1)
            
            
            self.gameData.populate(stats: stats, homeTeam: homeTeam, awayTeam: awayTeam)
            self.gameDataChanged += 1
        } catch {
            print(error.localizedDescription)
        }        

    }
    
    /*
     * addGameListener() adds a snapshot listener to the given GAME_COLLECTION_NAME for the most recent stat. This is called from
     * BoxScoreView()
     */
    func addGameListener(gameCollectionName: String) {
        db.collection(gamesCollection)
            .document(currentYear)
            .collection(gameCollectionName)
            .whereField(FieldPath.documentID(), isNotEqualTo: metadataDocument)
            .order(by: gameTimeField, descending: true)
            .limit(to: 1)
            .addSnapshotListener { gameSnapshot, error in
                guard let game = gameSnapshot else {
                    print("Error listening to game \(gameCollectionName): \(String(describing: error))")
                    return
                }
                
                if let stat = game.documents.first {
                    let data = stat.data()
                    
                    if let gameTime = data[gameTimeField] as? Int,
                       let statType = data[statTypeField] as? String,
                       let stat = data[statField] as? [String: Any] {
//                        print("addGameListener(), statType: \(statType)")
                        self.gameData.addStat(gameTime: gameTime, statType: statType, stat: stat)
                        self.gameDataChanged += 1
                    }
                }
            }
        
    }
    
    /*
     * fetchGameNames() returns the list of game collection names from the collection game_names in firebase. If the
     * IS_FINISHED is true, then it returns only the finished games, the reverse is true.
     */
    func fetchGameNames(isFinished: Bool) async throws -> [String] {
        var gameNames: [String] = []
        do {
            let snapshot = try await db.collection(gameNamesCollection)
                .whereField(isFinishedField, isEqualTo: isFinished)
                .getDocuments()
            
           
            for document in snapshot.documents {
                gameNames.append(document.documentID)
            }
      } catch {
            print("Error getting live game names: \(error.localizedDescription)")
        }
        return gameNames
    }
    
    
    
    /*
     * getMostRecentLineup() sets CURRENT_LINEUP to the most recent lineup stat for a given GAME_COLLECTION_NAME. This
     * is run when GameView().onAppear {...} is run to ensure that the current GameView() has the updated lineup in case
     * a user is statting a pre-existing live game.
     */
    func getMostRecentLineup(gameCollectionName: String) async throws {
        let gameCollectionRef = db.collection(gamesCollection)
                                  .document(currentYear)
                                  .collection(gameCollectionName)
            
        do {
            let snapshot = try await gameCollectionRef
                .whereField(FieldPath.documentID(), isNotEqualTo: metadataDocument)
                .order(by: gameTimeField, descending: true)
                .getDocuments()
            
            let homeInTheGame = LineupWithCapNumbers()
            let awayInTheGame = LineupWithCapNumbers()
            
            for document in snapshot.documents {
                let data = document.data()
                
                if data[statTypeField] as? String != StatType.lineup {
                    continue
                }
                
                if let lineupStat = data[statField] as? [String: Any] {
                    if let homeInTheGameRaw = lineupStat[LineupKeys.homeInTheGame] as? [String: Any],
                       let homeField = homeInTheGameRaw[LineupKeys.field] as? [[String: Any]],
                       let homeGoalies = homeInTheGameRaw[LineupKeys.goalies] as? [[String: Any]] {
                        for fbPlayer in homeField {
                            if let name = fbPlayer[nameKey] as? String,
                               let num = fbPlayer[numberKey] as? Int,
                               let notes = fbPlayer[notesKey] as? String {
                                homeInTheGame.addFieldPlayer(name: name, num: num, notes: notes)
                            }
                        }
                        
                        for fbGoalie in homeGoalies {
                            if let name = fbGoalie[nameKey] as? String,
                               let num = fbGoalie[numberKey] as? Int,
                               let notes = fbGoalie[notesKey] as? String {
                                homeInTheGame.addGoalie(name: name, num: num, notes: notes)
                            }
                        }
                        
                    } else {
                        print("Error retrieving lineup stat from Firebase.")
                    }
                    
                    if let awayInTheGameRaw = lineupStat[LineupKeys.awayInTheGame] as? [String: Any],
                       let awayField = awayInTheGameRaw[LineupKeys.field] as? [[String: Any]],
                       let awayGoalies = awayInTheGameRaw[LineupKeys.goalies] as? [[String: Any]] {
                        for fbPlayer in awayField {
                            if let name = fbPlayer[nameKey] as? String,
                               let num = fbPlayer[numberKey] as? Int,
                               let notes = fbPlayer[notesKey] as? String {
                                awayInTheGame.addFieldPlayer(name: name, num: num, notes: notes)
                            }
                        }
                        
                        for fbGoalie in awayGoalies {
                            if let name = fbGoalie[nameKey] as? String,
                               let num = fbGoalie[numberKey] as? Int,
                               let notes = fbGoalie[notesKey] as? String {
                                awayInTheGame.addGoalie(name: name, num: num, notes: notes)
                            }
                        }
                    } else {
                        print("Error retrieving lineup stat from Firebase.")
                    }
                }
                self.currentLineup[homeTeamKey] = homeInTheGame
                self.currentLineup[awayTeamKey] = awayInTheGame
                
                return
            }
        } catch {
            print("Error listening to game \(gameCollectionName): \(String(describing: error))")
        }
        
    }
    
    /* This is run when GameView appears, but always collects to check if it's a lineup stat */
    func addGameViewLineupListener(gameCollectionName: String) {
        let gameCollectionRef = db.collection(gamesCollection)
                                  .document(currentYear)
                                  .collection(gameCollectionName)
        
        gameCollectionRef
            .whereField(FieldPath.documentID(), isNotEqualTo: metadataDocument)
            .order(by: gameTimeField, descending: true)
            .limit(to: 1)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("Error listening for game stats: \(error)")
                    return
                }
                
                
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    
                    if data[statTypeField] as? String != StatType.lineup {
                        return
                    }
                    
                    let homeInTheGame = LineupWithCapNumbers()
                    let awayInTheGame = LineupWithCapNumbers()
   
                    if let lineupStat = data[statField] as? [String: Any] {
                        if let homeInTheGameRaw = lineupStat[LineupKeys.homeInTheGame] as? [String: Any],
                           let homeField = homeInTheGameRaw[LineupKeys.field] as? [[String: Any]],
                           let homeGoalies = homeInTheGameRaw[LineupKeys.goalies] as? [[String: Any]] {
                            
                            for fbPlayer in homeField {
                                if let name = fbPlayer[nameKey] as? String,
                                   let num = fbPlayer[numberKey] as? Int,
                                   let notes = fbPlayer[notesKey] as? String {
                                    homeInTheGame.addFieldPlayer(name: name, num: num, notes: notes)
                                }
                            }
                            
                            for fbGoalie in homeGoalies {
                                if let name = fbGoalie[nameKey] as? String,
                                   let num = fbGoalie[numberKey] as? Int,
                                   let notes = fbGoalie[notesKey] as? String {
                                    homeInTheGame.addGoalie(name: name, num: num, notes: notes)
                                }
                            }
                            
                        } else {
                            print("Error retrieving lineup stat from Firebase.")
                        }
                        
                        if let awayInTheGameRaw = lineupStat[LineupKeys.awayInTheGame] as? [String: Any],
                           let awayField = awayInTheGameRaw[LineupKeys.field] as? [[String: Any]],
                           let awayGoalies = awayInTheGameRaw[LineupKeys.goalies] as? [[String: Any]] {
                            for fbPlayer in awayField {
                                if let name = fbPlayer[nameKey] as? String,
                                   let num = fbPlayer[numberKey] as? Int,
                                   let notes = fbPlayer[notesKey] as? String {
                                   awayInTheGame.addFieldPlayer(name: name, num: num, notes: notes)
                                }
                            }
                            
                            for fbGoalie in awayGoalies {
                                if let name = fbGoalie[nameKey] as? String,
                                   let num = fbGoalie[numberKey] as? Int,
                                   let notes = fbGoalie[notesKey] as? String {
                                   awayInTheGame.addGoalie(name: name, num: num, notes: notes)
                                }
                            }
                        } else {
                            print("Error retrieving lineup stat from Firebase.")
                        }
                    }                    
                    self.currentLineup[homeTeamKey] = homeInTheGame
                    self.currentLineup[awayTeamKey] = awayInTheGame
                }
            }        

    }
    
    /* given a time string and the quarter, returns the amount of seconds passed in the game */
    func toTimeElapsed(timeString: String, quarter: Int) -> Int {
        guard timeString.contains(":") else { return 0 }
        
        let secondsInQuarter = 8 * 60
        
        let minutes = Int(timeString.split(separator: ":")[0]) ?? 0
        let seconds = Int(timeString.split(separator: ":")[1]) ?? 0
        
        let timePassedInQuarter = secondsInQuarter - (minutes * 60 + seconds)
        
        let secondsOfPastQuarters = (quarter - 1) * secondsInQuarter
        
        return secondsOfPastQuarters + timePassedInQuarter
    }

    /*
     * Returns the names of the rosters of the current year, used in SelectRosterView(), NewGameView()
     */
    func fetchRosterNames() async throws -> [String] {
        var rosterNames: [String] = []
        do {
            let snapshot = try await db.collection(rostersCollection)
                .document(currentYear)
                .getDocument()
            
            
            if let data = snapshot.data() {
                rosterNames = data.keys.map { $0 }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        return rosterNames
    }
    
    /*
     * fetchRoster(), given ROSTER_NAME, returns the roster from firebase as the class LineupWithCapNumbers
     */
    func fetchRoster(rosterName: String) async throws -> LineupWithCapNumbers {
        let lineup = LineupWithCapNumbers()
        do {
            let snapshot = try await db.collection(rostersCollection)
                .document(currentYear)
                .getDocument()
            
            if let data = snapshot.data() {
                if let fbRoster = data[rosterName] as? [String: Any],
                   let fbGoalies = fbRoster[goaliesKey] as? [[String: Any]],
                   let fbField = fbRoster[fieldKey] as? [[String: Any]]
                {
                    for fbGoalie in fbGoalies {
                        if let name = fbGoalie[nameKey] as? String,
                           let num = fbGoalie[numberKey] as? Int,
                           let notes = fbGoalie[notesKey] as? String {
                            lineup.addGoalie(name: name, num: num, notes: notes)
                        }
                    }
                    for fbPlayer in fbField {
                        if let name = fbPlayer[nameKey] as? String,
                           let num = fbPlayer[numberKey] as? Int,
                           let notes = fbPlayer[notesKey] as? String {
                            lineup.addFieldPlayer(name: name, num: num, notes: notes)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return lineup
    }
    
    /*
     * createNewRoster() creates a new roster in the current year in firebase. Used in NewRosterView() and EditRosterView()
     */
    func createNewRoster(team: String, lineup: LineupWithCapNumbers) async throws {
        do {
            var rosterData: [String: Any] = [:]
            
            var fieldData: [Any] = []
            for player: Player in lineup.field {
                var playerData: [String: Any] = [:]
                playerData[nameKey] = player.name
                playerData[numberKey] = player.num
                playerData[notesKey] = player.notes
                fieldData.append(playerData)
            }
            rosterData[fieldKey] = fieldData
            
            var goaliesData: [Any] = []
            for goalie: Player in lineup.goalies {
                var goalieData: [String: Any] = [:]
                goalieData[nameKey] = goalie.name
                goalieData[numberKey] = goalie.num
                goalieData[notesKey] = goalie.notes
                goaliesData.append(goalieData)
            }
            rosterData[goaliesKey] = goaliesData
            
            try await db.collection(rostersCollection)
                .document(currentYear)
                .setData([team: rosterData], merge: true) // MUST MERGE! otherwise all rosters are lost

            
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func updateRoster(team: String, lineup: LineupWithCapNumbers) async throws {
//        do {
//            
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
    /* returns a Lineup() given the teamName */
//    func getFullLineupOf(teamName: String) -> LineupWithCapNumbers {
//        return rosters[teamName] ?? Lineup()
//        
//    }
    
    /* Creates a game document in Fireabse */
    func createGameDocument(gameName: String, homeTeam: String, awayTeam: String) async throws -> String {
        let newGameName = gameName + "_" + String(Int(Date().timeIntervalSince1970))
        do {
            var gameDocData: [String: Any] = [:]
            gameDocData[timestampField] = FieldValue.serverTimestamp()
            gameDocData[homeTeamKey] = homeTeam
            gameDocData[awayTeamKey] = awayTeam
            
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(newGameName)
                .document(metadataDocument)
                .setData(gameDocData)
            
            // add game name to game_names collection, set is_finished to false
            try await db.collection(gameNamesCollection)
                .document(newGameName)
                .setData([isFinishedField: false, timestampField: FieldValue.serverTimestamp()])
            
        } catch {
            print("Error creating game: \(gameName)")
            throw FirebaseError.gameCreationFailed(gameName: gameName)
        }
        return newGameName
    }
    
    
    /* Sets GAME_DOCUMENT_NAME's "is_finished" to true in firebase */
    func setGameToFinished(gameCollectionName: String) async throws {
        do {
            try await db.collection(gameNamesCollection)
                .document(gameCollectionName)
                .setData([isFinishedField: true], merge: true)
        } catch {
            print("Error setting game to finished: \(gameCollectionName)")
            throw FirebaseError.setGameToFinishedFailed
        }
    }
    
    
    /* creates a lineup stat in the given gameCollectionName */
    func createLineupsStat(gameCollectionName: String, quarter: Int, timeString: String,
                           homeInTheGame: LineupWithCapNumbers, awayInTheGame: LineupWithCapNumbers) async throws {
        
        assert(!gameCollectionName.isEmpty)
        
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        
        var homeGoalies: [[String: Any]] = []
        for goalie in homeInTheGame.goalies {
            homeGoalies.append([nameKey: goalie.name, numberKey: goalie.num, notesKey: goalie.notes])
        }
        
        var homeField: [[String: Any]] = []
        for player in homeInTheGame.field {
            homeField.append([nameKey: player.name, numberKey: player.num, notesKey: player.notes])
        }
        
        var awayGoalies: [[String: Any]] = []
        for goalie in awayInTheGame.goalies {
            awayGoalies.append([nameKey: goalie.name, numberKey: goalie.num, notesKey: goalie.notes])
        }
        
        var awayField: [[String: Any]] = []
        for player in awayInTheGame.field {
            awayField.append([nameKey: player.name, numberKey: player.num, notesKey: player.notes])
        }

        let lineupData: [String: Any] = [
            gameTimeField: timeElapsed,
            statTypeField: StatType.lineup,
            statField: [
                LineupKeys.homeInTheGame: [
                    LineupKeys.goalies: homeGoalies,
                    LineupKeys.field: homeField
                ],
                LineupKeys.awayInTheGame: [
                    LineupKeys.goalies: awayGoalies,
                    LineupKeys.field: awayField
                ]
            ],
        ]
        
        do {
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(gameCollectionName)
                .document(String(timeElapsed))
                .setData(lineupData, merge: true)
        } catch {
            throw FirebaseError.lineupStatCreationFailed(gameCollectionName: gameCollectionName)
        }
    }
    
    /* Creates turnover stat in firebase */
    func createTurnoverStat(gameCollectionName: String, quarter: Int, timeString: String, team: String, player: String, turnoverType: String) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let turnoverData: [String: Any] = [
            gameTimeField: timeElapsed,
            statTypeField: StatType.turnover,
            statField: [
                TurnoverKeys.team: team,
                TurnoverKeys.player: player,
                TurnoverKeys.turnoverType: turnoverType
            ],
        ]
        
        do {
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(gameCollectionName)
                .document(String(timeElapsed))
                .setData(turnoverData, merge: true)
        } catch {
            throw FirebaseError.turnoverStatCreationFailed(gameCollectionName: gameCollectionName)
        }
    }
    /* Creates exclusion stat in firebase */
    func createExclusionStat(gameCollectionName: String, quarter: Int, timeString: String,
                             excludedTeam: String,
                             excludedPlayer: String,
                             phaseOfGame: String,
                             exclusionType: String,
                             drawnBy: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let exclusionData: [String: Any] = [
            gameTimeField: timeElapsed,
            statTypeField: StatType.exclusion,
            statField: [
                ExclusionKeys.excludedTeam: excludedTeam,
                ExclusionKeys.excludedPlayer: excludedPlayer,
                ExclusionKeys.phaseOfGame: phaseOfGame,
                ExclusionKeys.exclusionType: exclusionType,
                ExclusionKeys.drawnBy: drawnBy
            ],
        ]
        
        do {
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(gameCollectionName)
                .document(String(timeElapsed))
                .setData(exclusionData, merge: true)
        } catch {
            throw FirebaseError.turnoverStatCreationFailed(gameCollectionName: gameCollectionName)
        }
    }
    
    /* creates a steal statistic for the game GAME_DOCUMENT_NAME */
    func createStealStat(gameCollectionName: String, quarter: Int,
                         timeString: String, selectedTeam: String,
                         stolenBy: String, turnoverBy: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let stealData: [String: Any] = [
            gameTimeField: timeElapsed,
            statTypeField: StatType.steal,
            statField: [
                StealKeys.team: selectedTeam,
                StealKeys.stolenBy: stolenBy,
                StealKeys.turnoverBy: turnoverBy
            ],
        ]

        do {
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(gameCollectionName)
                .document(String(timeElapsed))
                .setData(stealData, merge: true)
        } catch {
            throw FirebaseError.stealStatCreationFailed(gameCollectionName: gameCollectionName)
        }
    }
    
    func createTimeoutStat(gameCollectionName: String, quarter: Int,
                           timeString: String, selectedTeam: String,
                           timeoutType: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let timeoutData: [String: Any] = [
            gameTimeField: timeElapsed,
            statTypeField: StatType.timeout,
            statField: [
                TimeoutKeys.team: selectedTeam,
                TimeoutKeys.timeoutType: timeoutType
            ],
        ]
        
        do {
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(gameCollectionName)
                .document(String(timeElapsed))
                .setData(timeoutData, merge: true)
        } catch {
            throw FirebaseError.timoutStatCreationFailed(gameCollectionName: gameCollectionName)
        }
    }
    
    func createShotStat(gameCollectionName: String, quarter: Int, timeString: String,
                        selectedTeam: String, shooter: String, phaseOfGame: String,
                        shooterPosition: String, shotLocation: String, shotDetail: String,
                        isSkip: Int, shotResult: String, assistedBy: String, goalConcededBy: String,
                        fieldBlockedBy: String, savedBy: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        var shotData: [String: Any] = [
            gameTimeField: timeElapsed,
            statTypeField: StatType.shot,
            statField: [
                ShotKeys.team: selectedTeam,
                ShotKeys.shooter: shooter,
                ShotKeys.phaseOfGame: phaseOfGame,
                ShotKeys.shotLocation: shotLocation,
                ShotKeys.isSkip: isSkip == 1 ? true: false,
                ShotKeys.shotResult: shotResult
            ],
        ]
        
        if var shotDetails = shotData[statField] as? [String: Any] {
            
            if phaseOfGame != ShotKeys.phases.penalty {
                shotDetails[ShotKeys.shooterPosition] = shooterPosition
                shotDetails[ShotKeys.shotDetail] = shotDetail
            }
            
            if shotResult == ShotKeys.shotResults.goal {
                shotDetails[ShotKeys.assistedBy] = assistedBy
                shotDetails[ShotKeys.goalConcededBy] = goalConcededBy
            } else if shotResult == ShotKeys.shotResults.goalieSave {
                shotDetails[ShotKeys.savedBy] = savedBy
            } else if shotResult == ShotKeys.shotResults.fieldBlock {
                shotDetails[ShotKeys.fieldBlockedBy] = fieldBlockedBy
            }
            
            shotData[statField] = shotDetails
        }
        
        do {
            try await db.collection(gamesCollection)
                .document(currentYear)
                .collection(gameCollectionName)
                .document(String(timeElapsed))
                .setData(shotData, merge: true)
        } catch {
            throw FirebaseError.shotStatCreationFailed(gameCollectionName: gameCollectionName)
        }
    }

}


enum FirebaseError: Error, LocalizedError {
    case fetchRostersFailed
    case gameCreationFailed(gameName: String)
    case lineupStatCreationFailed(gameCollectionName: String)
    case turnoverStatCreationFailed(gameCollectionName: String)
    case exclusionStatCreationFailed(gameCollectionName: String)
    case stealStatCreationFailed(gameCollectionName: String)
    case timoutStatCreationFailed(gameCollectionName: String)
    case shotStatCreationFailed(gameCollectionName: String)
    case fetchAllGamesFailed
    case setGameToFinishedFailed
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .fetchRostersFailed:
            return "Failed to fetch the rosters"
        case .gameCreationFailed(let gameName):
            return "Failed to start game \(gameName)"
        case .lineupStatCreationFailed(let gameCollectionName):
            return "Failed to upload lineup stat to game \(gameCollectionName)"
        case .turnoverStatCreationFailed(let gameCollectionName):
            return "Failed to upload turnover stat to game \(gameCollectionName)"
        case .exclusionStatCreationFailed(let gameCollectionName):
            return "Failed to upload exclusion stat to game \(gameCollectionName)"
        case .stealStatCreationFailed(let gameCollectionName):
            return "Failed to upload steal stat to game \(gameCollectionName)"
        case .timoutStatCreationFailed(let gameCollectionName):
            return "Failed to upload timout stat to game \(gameCollectionName)"
        case .shotStatCreationFailed(let gameCollectionName):
            return "Failed to upload shot stat to game \(gameCollectionName)"
        case .fetchAllGamesFailed:
            return "Failed to fetch game names"
        case .setGameToFinishedFailed:
            return "Failed to set game to finished"
        case .networkError:
            return "Network error occurred. Please check your internet connection"
        }
    }
}
