//
//  GameData.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/10/24.
//

//import Foundation

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
    
    private func handleShotStat(shotStat: [String: Any], gameTime: Int) -> String {
        
        var description: String = ""
        
        guard let team = shotStat[ShotKeys.team] as? String,
              let shooter = shotStat[ShotKeys.shooter] as? String,
              let phaseOfGame = shotStat[ShotKeys.phaseOfGame] as? String,
              let shotLocation = shotStat[ShotKeys.shotLocation] as? String,
              let isSkip = shotStat[ShotKeys.isSkip] as? Bool,
              let shotResult = shotStat[ShotKeys.shotResult] as? String else {
            return ""
        }
        
        description += shooter + " shot "
        
        var shooterPosition: String?
        var shotDetail: String?
        
        if phaseOfGame != ShotKeys.phases.penalty {
            guard let position = shotStat[ShotKeys.shooterPosition] as? String,
                  let detail = shotStat[ShotKeys.shotDetail] as? String else {
                return ""
            }
            shooterPosition = position
            shotDetail = detail
            
            description += "in " + ShotKeys.phasesToDisp[phaseOfGame]! + " and "
        } else {
            description += "a penalty "
        }
        
        var assistedBy: String?
        var goalConcededBy: String?
        var savedBy: String?
        var fieldBlockedBy: String?
        
        if shotResult == ShotKeys.shotResults.goal {
            guard let assist = shotStat[ShotKeys.assistedBy] as? String,
                  let concededBy = shotStat[ShotKeys.goalConcededBy] as? String else {
                return ""
            }
            assistedBy = assist
            goalConcededBy = concededBy
            
            description += " scored."
        } else if shotResult == ShotKeys.shotResults.fieldBlock {
            guard let fieldBlock = shotStat[ShotKeys.fieldBlockedBy] as? String else {
                return ""
            }
            fieldBlockedBy = fieldBlock
            description += " was field blocked."
        } else if shotResult == ShotKeys.shotResults.goalieSave {
            guard let save = shotStat[ShotKeys.savedBy] as? String else {
                return ""
            }
            savedBy = save
            description += " was saved."
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
        
        return description
        
    }
    
    /* EXCLUSION_TRACKER is a map from <team> (home/awayTeam) to a map of players from <playerName>: [Exclusion] */
    struct Exclusion {
        var gameTime: Int
        var exclusionType: String
        var drawnBy: String
        var phaseOfGame: String
    }
    var exclusionTracker: [String /* home/awayTeam */: [String /* playerName*/ : [Exclusion]]] = [:]
    
    private func handleExclusionStat(exclusionStat: [String: Any], gameTime: Int) -> String {
        
        var description: String = ""
        
        guard let player = exclusionStat[ExclusionKeys.excludedPlayer] as? String,
              let type = exclusionStat[ExclusionKeys.exclusionType] as? String,
              let drawnBy = exclusionStat[ExclusionKeys.drawnBy] as? String,
              let phase = exclusionStat[ExclusionKeys.phaseOfGame] as? String,
              let excludedTeam = exclusionStat[ExclusionKeys.excludedTeam] as? String else {
            return ""
        }
        
//        description += player + " was excluded in " + ShotKeys.phasesToDisp[phase]!
        print(phase)

        let exclusion = Exclusion(gameTime: gameTime, exclusionType: type, drawnBy: drawnBy, phaseOfGame: phase)

        if excludedTeam == homeTeam {
            exclusionTracker[LineupKeys.homeTeam, default: [:]][player, default: []].append(exclusion)
        } else if excludedTeam == awayTeam {
            exclusionTracker[LineupKeys.awayTeam, default: [:]][player, default: []].append(exclusion)
        }
        
        return description
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
        var description: String = ""
        if let lineupStat = stat[StatType.lineup] as? [String: Any] {
            handleLineupStat(lineupStat: lineupStat, gameTime: gameTime)
            description += "Lineup change."
        } else if let shotStat = stat[StatType.shot] as? [String: Any] {
            description += handleShotStat(shotStat: shotStat, gameTime: gameTime)
        } else if let exclusionStat = stat[StatType.exclusion] as? [String: Any] {
            description += handleExclusionStat(exclusionStat: exclusionStat, gameTime: gameTime)
        } else if let stealStat = stat[StatType.steal] as? [String: Any] {
            handleStealStat(stealStat: stealStat, gameTime: gameTime)
        } else if let turnoverStat = stat[StatType.turnover] as? [String: Any] {
            handleTurnoverStat(turnoverStat: turnoverStat, gameTime: gameTime)
        } else if let timeoutStat = stat[StatType.timeout] as? [String: Any] {
            handleTimeoutStat(timeoutStat: timeoutStat, gameTime: gameTime)
        }
        
        playByPlay.append((gameTime, description))

    }
    
    
    /* This is the init function for the game, run once in FirebaseManager.addGameListener() */
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
