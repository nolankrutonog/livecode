//
//  FirebaseManager.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/23/24.
//

import Firebase


class GameData {
    var homeTeam: String = ""
    var awayTeam: String = ""
    var homeInTheGame: Lineup = Lineup()
    var awayInTheGame: Lineup = Lineup()
    
    /*
     * if a user follows a game and requires all the stats, then isPopulated will
     * be set to true after all the stats are updated in the gameData
     */
    var isPopulated: Bool = false
    
    var homeScore: Int = 0
    var awayScore: Int = 0
    var quarter: Int = 1 // updated on every new stat
    var homeTimeoutsLeft: Float = 3.5
    var awayTimeoutsLeft: Float = 3.5

    var playByPlay: [(Int, String)] = []
    
    /*
     * SECONDS_TRACKER is a map from <team> (home/awayTeam) to a map of players from <playerName>: <secondsPlayed>
     */
    var secondsTracker: [String: [String: Int]] = [:]
    var prevTime: Int = 0
    
    
    /* Updates the time that players are in the game */
    private func updateSecondsTracker(gameTime: Int) {
        for player: String in homeInTheGame.field + homeInTheGame.goalies + awayInTheGame.field + awayInTheGame.goalies {
            if secondsTracker[LineupKeys.homeTeam]?[player] != nil {
                /* if a player is defined already */
                secondsTracker[LineupKeys.homeTeam]?[player]? += (gameTime - prevTime)
            } else {
                secondsTracker[LineupKeys.homeTeam]?[player] = 0
            }
        }
        self.prevTime = gameTime
    }
    
    private func handleLineupStat(lineupStat: [String: Any], gameTime: Int) {
        if let homeInTheGameRaw = lineupStat[LineupKeys.homeInTheGame] as? [String: Any],
           let homeField = homeInTheGameRaw[LineupKeys.field] as? [String],
           let homeGoalies = homeInTheGameRaw[LineupKeys.goalies] as? [String] 
        {
            self.homeInTheGame = Lineup(goalies: homeGoalies, field: homeField)
        }
        
        if let awayInTheGameRaw = lineupStat[LineupKeys.awayInTheGame] as? [String: Any],
           let awayField = awayInTheGameRaw[LineupKeys.field] as? [String],
           let awayGoalies = awayInTheGameRaw[LineupKeys.goalies] as? [String]
        {
            self.awayInTheGame = Lineup(goalies: awayGoalies, field: awayField)
        }

    }
    
    struct Shot {
        var gameTime: Int
        var phaseOfGame: String
        var shooterPosition: String?
        var shotLocation: String
        var shotDetail: String?
        var isSkip: Bool
        var shotResult: String
        
        var assistedBy: String?
        var goalConcededBy: String?
        var fieldBlockedBy: String?
        var savedBy: String?
    }
    
    var shotTracker: [String: [String: [Shot]]] = [:]
    
    private func handleShotStat(shotStat: [String: Any], gameTime: Int) {
        print(shotStat)
        guard let team = shotStat[ShotKeys.team] as? String,
              let shooter = shotStat[ShotKeys.shooter] as? String,
              let phaseOfGame = shotStat[ShotKeys.phaseOfGame] as? String,
              let shotLocation = shotStat[ShotKeys.shotLocation] as? String,
              let isSkip = shotStat[ShotKeys.isSkip] as? Bool,
              let shotResult = shotStat[ShotKeys.shotResult] as? String else {
            return
        }
        
        var shooterPosition: String?
        var shotDetail: String?
        
        if phaseOfGame != ShotKeys.phases.penalty {
            guard let position = shotStat[ShotKeys.shooterPosition] as? String,
                  let detail = shotStat[ShotKeys.shotDetail] as? String else {
                return
            }
            shooterPosition = position
            shotDetail = detail
        }
        
        var assistedBy: String?
        var goalConcededBy: String?
        var savedBy: String?
        var fieldBlockedBy: String?
        
        if shotResult == ShotKeys.shotResults.goal {
            guard let assist = shotStat[ShotKeys.assistedBy] as? String,
                  let concededBy = shotStat[ShotKeys.goalConcededBy] as? String else {
                return
            }
            assistedBy = assist
            goalConcededBy = concededBy
        } else if shotResult == ShotKeys.shotResults.fieldBlock {
            guard let fieldBlock = shotStat[ShotKeys.fieldBlockedBy] as? String else {
                return
            }
            fieldBlockedBy = fieldBlock
        } else if shotResult == ShotKeys.shotResults.goalieSave {
            guard let save = shotStat[ShotKeys.savedBy] as? String else {
                return
            }
            savedBy = save
        }
       
        var shot = Shot(gameTime: gameTime, phaseOfGame: phaseOfGame, shotLocation: shotLocation, isSkip: isSkip, shotResult: shotResult)
        shot.shooterPosition = shooterPosition
        shot.shotDetail = shotDetail
        shot.assistedBy = assistedBy
        shot.goalConcededBy = goalConcededBy
        shot.savedBy = savedBy
        shot.fieldBlockedBy = fieldBlockedBy
       
        if team == homeTeam {
            shotTracker[LineupKeys.homeTeam, default: [:]][shooter, default: []].append(shot)
        } else if team == awayTeam {
            shotTracker[LineupKeys.awayTeam, default: [:]][shooter, default: []].append(shot)
        }
        
    }
    
    /* EXCLUSION_TRACKER is a map from <team> (home/awayTeam) to a map of players from <playerName>: [Exclusion] */
    struct Exclusion {
        var gameTime: Int
        var exclusionType: String
        var drawnBy: String
        var phaseOfGame: String
    }
    var exclusionTracker: [String /* home/awayTeam */: [String /* playerName*/ : [Exclusion]]] = [:]
    
    private func handleExclusionStat(exclusionStat: [String: Any], gameTime: Int) {
        guard let player = exclusionStat[ExclusionKeys.excludedPlayer] as? String,
              let type = exclusionStat[ExclusionKeys.exclusionType] as? String,
              let drawnBy = exclusionStat[ExclusionKeys.drawnBy] as? String,
              let phase = exclusionStat[ExclusionKeys.phaseOfGame] as? String,
              let excludedTeam = exclusionStat[ExclusionKeys.excludedTeam] as? String else {
            return
        }

        let exclusion = Exclusion(gameTime: gameTime, exclusionType: type, drawnBy: drawnBy, phaseOfGame: phase)

        if excludedTeam == homeTeam {
            exclusionTracker[LineupKeys.homeTeam, default: [:]][player, default: []].append(exclusion)
        } else if excludedTeam == awayTeam {
            exclusionTracker[LineupKeys.awayTeam, default: [:]][player, default: []].append(exclusion)
        }
    }

    
    struct Steal {
        var gameTime: Int
        var stolenBy: String
        var turnoverBy: String
    }
    
    var stealTracker: [String: [Steal]] = [:]
    
    private func handleStealStat(stealStat: [String: Any], gameTime: Int) {
        guard let stolenBy = stealStat[StealKeys.stolenBy] as? String,
              let turnoverBy = stealStat[StealKeys.turnoverBy] as? String,
              let team = stealStat[StealKeys.team] as? String else {
            return
        }
        
        let steal = Steal(gameTime: gameTime, stolenBy: stolenBy, turnoverBy: turnoverBy)
        
        if team == homeTeam {
            stealTracker[LineupKeys.homeTeam, default: []].append(steal)
        } else {
            stealTracker[LineupKeys.awayTeam, default: []].append(steal)
        }
    }
    
    struct Turnover {
        var gameTime: Int
        var player: String
        var turnoverType: String
    }
    var turnoverTracker: [String: [Turnover]] = [:]
    
    private func handleTurnoverStat(turnoverStat: [String: Any], gameTime: Int) {
        guard let team = turnoverStat[TurnoverKeys.team] as? String,
              let player = turnoverStat[TurnoverKeys.player] as? String,
              let turnoverType = turnoverStat[TurnoverKeys.turnoverType] as? String else {
            return
        }
        
        let turnover = Turnover(gameTime: gameTime, player: player, turnoverType: turnoverType)
        
        if team == homeTeam {
            turnoverTracker[LineupKeys.homeTeam, default: []].append(turnover)
        } else if team == awayTeam {
            turnoverTracker[LineupKeys.awayTeam, default: []].append(turnover)
        }
    }
    
    struct Timeout {
        var gameTime: Int
        var timeoutType: String
    }
    
    var timeoutTracker: [String: [Timeout]] = [:]
    
    private func handleTimeoutStat(timeoutStat: [String: Any], gameTime: Int) {
        guard let team = timeoutStat[TimeoutKeys.team] as? String,
              let timeoutType = timeoutStat[TimeoutKeys.timeoutType] as? String else {
            return
        }
        
        let timeout = Timeout(gameTime: gameTime, timeoutType: timeoutType)
        
        if team == homeTeam {
            timeoutTracker[LineupKeys.homeTeam, default: []].append(timeout)
        } else if team == awayTeam {
            timeoutTracker[LineupKeys.awayTeam, default: []].append(timeout)
        }
    }
    
    private func handleStat(stat: [String: Any], gameTime: Int) {
        if let lineupStat = stat[StatType.lineup] as? [String: Any] {
            handleLineupStat(lineupStat: lineupStat, gameTime: gameTime)
        } else if let shotStat = stat[StatType.shot] as? [String: Any] {
            handleShotStat(shotStat: shotStat, gameTime: gameTime)
        } else if let exclusionStat = stat[StatType.exclusion] as? [String: Any] {
            handleExclusionStat(exclusionStat: exclusionStat, gameTime: gameTime)
        } else if let stealStat = stat[StatType.steal] as? [String: Any] {
            handleStealStat(stealStat: stealStat, gameTime: gameTime)
        } else if let turnoverStat = stat[StatType.turnover] as? [String: Any] {
            handleTurnoverStat(turnoverStat: turnoverStat, gameTime: gameTime)
        } else if let timeoutStat = stat[StatType.timeout] as? [String: Any] {
            handleTimeoutStat(timeoutStat: timeoutStat, gameTime: gameTime)
        }

    }
    
    
    /* This is the init function */
    public func populate(data: [(Int, [String: Any])], homeTeam: String, awayTeam: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        
        secondsTracker[LineupKeys.homeTeam] = [:]
        secondsTracker[LineupKeys.awayTeam] = [:]
        
        exclusionTracker[LineupKeys.homeTeam] = [:]
        exclusionTracker[LineupKeys.awayTeam] = [:]
        
        stealTracker[LineupKeys.homeTeam] = []
        stealTracker[LineupKeys.awayTeam] = []
        
        shotTracker[LineupKeys.homeTeam] = [:]
        shotTracker[LineupKeys.awayTeam] = [:]
        
        turnoverTracker[LineupKeys.homeTeam] = []
        turnoverTracker[LineupKeys.awayTeam] = []
        
        timeoutTracker[LineupKeys.homeTeam] = []
        timeoutTracker[LineupKeys.awayTeam] = []
        
        for entry in data {
            let gameTime = Int(entry.0)
            updateSecondsTracker(gameTime: gameTime)
            let stat = entry.1
            handleStat(stat: stat, gameTime: gameTime)
        }
        
        self.isPopulated = true
    }
    
    
    public func addStat(stat: (Int, [String: Any])) {
        let gameTime = Int(stat.0)
        updateSecondsTracker(gameTime: gameTime)
        handleStat(stat: stat.1, gameTime: gameTime)
    }
}


class FirebaseManager: ObservableObject {
    let db = Firestore.firestore()
    
    /*
     * ROSTERS is a map of the rosters from Firebase. They map from team_name: String (document) to a roster: struct Lineup (field).
     * The rosters should only be fetched once (upon creating a new game) and in future releases will be able to edit rosters in
     * Firebase from the app.
     * rosters is <team_name> : <entire roster> as bench lineup
     */
    @Published var rosters: [String: Lineup] = [:]
    private var rostersAreFetched: Bool = false

    /*
     * CURRENT_LINEUP is the current in-the-game players on both teams. The home team key is "home_team", found in LineupKeys.homeTeam,
     * the same is true for the away team. CURRENT_LINEUP is set from the most recent lineup stat in Firebase of the current game. This
     * requires that each device statting a game only has one live game at once. CURRENT_LINEUP is a published variable that is set
     * every time a new lineup stat is added to a game in Firebase.
     * currentLineup is <team_name> : <most recent lineup choice>
     */
    @Published var currentLineup: [String: Lineup] = [:]
    
    
    /*
     * GAME_DATA is a map of all the game events, most recent ones first. Each device can only follow one game at a time, so addGameListener()
     * will add every stat to GAME_DATA only once. We are calling this populating. After GAME_DATA is fully populated, the published Bool
     * GAME_IS_POPULATED will be set to true, and only the most recent stat will be appended to GAME_DATA. When a user decides to leave
     * FollowGameView(), GAME_IS_POPULATED must be set to false and GAME_DATA emptied, so that the next game the user chooses to
     * follow will be populated with the correct game data.
     */
//    @Published var gameData: [(Int, [String: Any])] = []
//    @Published var gameIsPopulated: Bool = false
    @Published var gameData: GameData = GameData()
    
   
    /* Listens to a live game and adds the most recent stat to gameData. If gameIsNotPopulated, it sets gameData to sortedData */
    func addGameListener(gameDocumentName: String) {
        db.collection("games").document(gameDocumentName).addSnapshotListener { gameSnapshot, error in
            guard let game = gameSnapshot else {
                print("Error listening to game \(gameDocumentName): \(String(describing: error))")
                return
            }
            
            if let data = game.data() {
                if let homeTeam = data[LineupKeys.homeTeam] as? String,
                   let awayTeam = data[LineupKeys.awayTeam] as? String {
                    
                    let sortedData = data.compactMap { (key, value) -> (Int, [String: Any])? in
                        guard let intKey = Int(key),
                              let valueMap = value as? [String: Any] else {
                            return nil
                        }
                        return (intKey, valueMap)
                    }
                    /* want this sorted from 0 to end so stats are added in order of when they occur */
                        .sorted(by: { $0.0 < $1.0 })
                    
                    
                    if !self.gameData.isPopulated {
                        self.gameData.populate(data: sortedData, homeTeam: homeTeam, awayTeam: awayTeam)
                    } else {
                        // add most recent stat
                        self.gameData.addStat(stat: sortedData[sortedData.count - 1])
                    }
                }
            }
        }
    }
    
    /* Returns a list of gameDocumentNames in sorted order by timestamp descending where "is_finished" flag is false */
    func fetchAllLiveGameNames() async throws -> [String] {
        var gameNames: [String] = []
        do {
            let querySnapshot = try await db.collection("games")
                .whereField("is_finished", in: [false])
                .order(by: "timestamp", descending: true)
                .getDocuments()
            for gameDocument in querySnapshot.documents {
                gameNames.append(gameDocument.documentID)
            }
        } catch {
            print("Error getting live game names: \(error.localizedDescription)")
        }
        return gameNames
    }
    
    /* returns a list of gameDocumentNames where "is_finished" flag is true */
    func fetchAllFinishedGameNames() async throws -> [String] {
        var gameNames: [String] = []
        do {
            let querySnapshot = try await db.collection("games")
                .whereField("is_finished", in: [true])
                .order(by: "timestamp", descending: true)
                .getDocuments()
            for gameDocument in querySnapshot.documents {
                gameNames.append(gameDocument.documentID)
            }
        } catch {
            print("Error getting finished game names: \(error.localizedDescription)")
        }
        return gameNames
    }
    
    
    /* Adds a listener to the document GAME_DOCUMENT_NAME in GameView to find the most recent lineup stat */
    func addGameViewLineupListener(gameDocumentName: String) {
        db.collection("games").document(gameDocumentName).addSnapshotListener { gameSnapshot, error in
            guard let game = gameSnapshot else {
                print("Error listening to game \(gameDocumentName): \(String(describing: error))")
                return
            }
            
            if let data = game.data() {
                let sortedData = data.compactMap { (key, value) -> (Int, [String: Any])? in
                    guard let intKey = Int(key), let valueMap = value as? [String: Any] else {
                        /* This also excludes metadata keys like "is_finished" and "timestamp" */
                        return nil
                    }
                    return (intKey, valueMap)
                }
                .sorted(by: { $0.0 > $1.0 })
                
                var homeInTheGame: Lineup = Lineup()
                var awayInTheGame: Lineup = Lineup()
                
                for stat in sortedData {
                    let entry = stat.1 // stat.0 is the timestamp
                    
                    if let lineupStat = entry[StatType.lineup] as? [String: Any] {
                        if let homeInTheGameRaw = lineupStat[LineupKeys.homeInTheGame] as? [String: Any],
                           let homeField = homeInTheGameRaw[LineupKeys.field] as? [String],
                           let homeGoalies = homeInTheGameRaw[LineupKeys.goalies] as? [String] {
                            
//                            let homeInTheGame = Lineup(goalies: homeGoalies, field: homeField)
//                            DispatchQueue.main.async {
//                                self.currentLineup[LineupKeys.homeTeam] = homeInTheGame
//                            }
                            homeInTheGame = Lineup(goalies: homeGoalies, field: homeField)
                        } else {
                            print("Error: lineup stat set incorrectly in cloud.")
                        }
                        
                        if let awayInTheGameRaw = lineupStat[LineupKeys.awayInTheGame] as? [String: Any],
                           let awayField = awayInTheGameRaw[LineupKeys.field] as? [String],
                           let awayGoalies = awayInTheGameRaw[LineupKeys.goalies] as? [String]
                        {
//                            let awayInTheGame = Lineup(goalies: awayGoalies, field: awayField)
//                            DispatchQueue.main.async {
//                                self.currentLineup[LineupKeys.awayTeam] = awayInTheGame
//                            }
                            awayInTheGame = Lineup(goalies: awayGoalies, field: awayField)
                        } else {
                            print("Error: lineup stat set incorrectly in cloud.")
                        }
                        
                        // Return if you found the most recent lineup stat
                        DispatchQueue.main.async {
                            self.currentLineup[LineupKeys.homeTeam] = homeInTheGame
                            self.currentLineup[LineupKeys.awayTeam] = awayInTheGame
                        }
                        return
                    }
                }
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

    /* Populates rosters */
    func fetchRosters() async throws {
        guard !rostersAreFetched else { return }
        rostersAreFetched = true
        
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
    func createGameDocument(gameName: String, homeTeam: String, awayTeam: String) async throws -> String {
        let newGameName = gameName + "_" + String(Int(Date().timeIntervalSince1970))
        do {
            var gameData: [String: Any] = [:]
            gameData["timestamp"] = FieldValue.serverTimestamp()
            gameData["is_finished"] = false
            gameData["home_team"] = homeTeam
            gameData["away_team"] = awayTeam
            try await db.collection("games")
                .document(newGameName).setData(gameData)
        } catch {
            print("Error creating game: \(gameName)")
            throw FirebaseError.gameCreationFailed(gameName: gameName)
        }
        return newGameName
    }
    
    
    /* Sets GAME_DOCUMENT_NAME's "is_finished" to true in firebase */
    func setGameToFinished(gameDocumentName: String) async throws {
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["is_finished": true], merge: true)
        } catch {
            print("Error setting game to finished: \(gameDocumentName)")
            throw FirebaseError.setGameToFinishedFailed
        }
    }
    
    
    /* creates a lineup stat in the given gameDocumentName */
    func createLineupsStat(gameDocumentName: String, quarter: Int, timeString: String,
//                          homeTeam: String, awayTeam: String,
                           homeInTheGame: Lineup, awayInTheGame: Lineup) async throws {
        
        assert(!gameDocumentName.isEmpty)
        
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let lineupData: [String: Any] = [
            StatType.lineup: [
//                LineupKeys.homeTeam: homeTeam,
//                LineupKeys.awayTeam: awayTeam,
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
    func createTurnoverStat(gameDocumentName: String, quarter: Int, timeString: String, team: String, player: String, turnoverType: String) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let turnoverData: [String: Any] = [
            StatType.turnover: [
                TurnoverKeys.team: team,
                TurnoverKeys.player: player,
                TurnoverKeys.turnoverType: turnoverType
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
                           timeString: String, selectedTeam: String,
                           timeoutType: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        let timeoutData: [String: Any] = [
            StatType.timeout: [
                TimeoutKeys.team: selectedTeam,
                TimeoutKeys.timeoutType: timeoutType
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
    
    func createShotStat(gameDocumentName: String, quarter: Int, timeString: String,
                        selectedTeam: String, shooter: String, phaseOfGame: String,
                        shooterPosition: String, shotLocation: String, shotDetail: String,
                        isSkip: Bool, shotResult: String, assistedBy: String, goalConcededBy: String,
                        fieldBlockedBy: String, savedBy: String
    ) async throws {
        let timeElapsed = toTimeElapsed(timeString: timeString, quarter: quarter)
        var shotData: [String: Any] = [
            StatType.shot: [
                ShotKeys.team: selectedTeam,
                ShotKeys.shooter: shooter,
                ShotKeys.phaseOfGame: phaseOfGame,
                ShotKeys.shotLocation: shotLocation,
                ShotKeys.isSkip: isSkip,
                ShotKeys.shotResult: shotResult
            ]
        ]
        
        if var shotDetails = shotData[StatType.shot] as? [String: Any] {
            
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
            
            shotData[StatType.shot] = shotDetails
        }
        
        do {
            try await db.collection("games")
                .document(gameDocumentName)
                .setData(["\(timeElapsed)": shotData], merge: true)
        } catch {
            throw FirebaseError.shotStatCreationFailed(gameDocumentName: gameDocumentName)
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
    case shotStatCreationFailed(gameDocumentName: String)
    case fetchAllGamesFailed
    case setGameToFinishedFailed
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
        case .shotStatCreationFailed(let gameDocumentName):
            return "Failed to upload shot stat to game \(gameDocumentName)"
        case .fetchAllGamesFailed:
            return "Failed to fetch game names"
        case .setGameToFinishedFailed:
            return "Failed to set game to finished"
        case .networkError:
            return "Network error occurred. Please check your internet connection"
        }
    }
}
