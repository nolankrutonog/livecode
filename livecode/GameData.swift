//
//  GameData.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/10/24.
//

//import Foundation

class GameData {
    
    var gameCollectionName: String = ""
    var homeTeam: String = ""
    var awayTeam: String = ""
    var homeInTheGame = LineupWithCapNumbers()
    var awayInTheGame = LineupWithCapNumbers()
    
    /* Displayables */
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
        for player: Player in homeInTheGame.field + homeInTheGame.goalies {
            if secondsTracker[homeTeamKey]?[player.name] != nil {
                /* if a player is defined already */
                secondsTracker[homeTeamKey]?[player.name]? += (gameTime - prevTime)
            } else {
                secondsTracker[homeTeamKey]?[player.name] = 0
            }
        }
        for player: Player in awayInTheGame.field + awayInTheGame.goalies {
            if secondsTracker[awayTeamKey]?[player.name] != nil {
                /* if a player is defined already */
                secondsTracker[awayTeamKey]?[player.name]? += (gameTime - prevTime)
            } else {
                secondsTracker[awayTeamKey]?[player.name] = 0
            }

        }
        self.prevTime = gameTime
    }
    
    private func handleLineupStat(lineupStat: [String: Any], gameTime: Int) {
        if let homeInTheGameRaw = lineupStat[LineupKeys.homeInTheGame] as? [String: Any],
           let homeField = homeInTheGameRaw[LineupKeys.field] as? [[String: Any]],
           let homeGoalies = homeInTheGameRaw[LineupKeys.goalies] as? [[String: Any]]
        {
            for fbField in homeField {
                if let name = fbField[nameKey] as? String,
                   let num = fbField[numberKey] as? Int,
                   let notes = fbField[notesKey] as? String {
                    self.homeInTheGame.addFieldPlayer(name: name, num: num, notes: notes)
                }
            }
            for fbGoalie in homeGoalies {
                if let name = fbGoalie[nameKey] as? String,
                   let num = fbGoalie[numberKey] as? Int,
                   let notes = fbGoalie[notesKey] as? String {
                    self.homeInTheGame.addGoalie(name: name, num: num, notes: notes)
                }
            }
        }
        
        if let awayInTheGameRaw = lineupStat[LineupKeys.awayInTheGame] as? [String: Any],
           let awayField = awayInTheGameRaw[LineupKeys.field] as? [[String: Any]],
           let awayGoalies = awayInTheGameRaw[LineupKeys.goalies] as? [[String: Any]]
        {
            for fbField in awayField {
                if let name = fbField[nameKey] as? String,
                   let num = fbField[numberKey] as? Int,
                   let notes = fbField[notesKey] as? String {
                    self.awayInTheGame.addFieldPlayer(name: name, num: num, notes: notes)
                }
            }
            for fbGoalie in awayGoalies {
                if let name = fbGoalie[nameKey] as? String,
                   let num = fbGoalie[numberKey] as? Int,
                   let notes = fbGoalie[notesKey] as? String {
                    self.awayInTheGame.addGoalie(name: name, num: num, notes: notes)
                }
            }
        }

    }
    
    struct Shot: Hashable {
        var gameTime: Int
        var shooter: String
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
            return "Error: handleShotStat() main guard failure"
        }
        
        description += shooter + " shoots "
        
        var shooterPosition: String?
        var shotDetail: String?
        
        if phaseOfGame != ShotKeys.phases.penalty {
            guard let position = shotStat[ShotKeys.shooterPosition] as? String,
                  let detail = shotStat[ShotKeys.shotDetail] as? String else {
                return "Error: handleShotStat() non-penalty guard failure"
            }
            shooterPosition = position
            shotDetail = detail
            
            description += "in " + ShotKeys.phasesToDisp[phaseOfGame]! + " and "
        } else {
            description += "a penalty and "
        }
        
        var assistedBy: String?
        var goalConcededBy: String?
        var savedBy: String?
        var fieldBlockedBy: String?
        
        if shotResult == ShotKeys.shotResults.goal {
            guard let assist = shotStat[ShotKeys.assistedBy] as? String,
                  let concededBy = shotStat[ShotKeys.goalConcededBy] as? String else {
                return "Error: handleShotStat() is goal guard failure"
            }
            assistedBy = assist
            goalConcededBy = concededBy
            
            description += "dents the twine."
        } else if shotResult == ShotKeys.shotResults.fieldBlock {
            guard let fieldBlock = shotStat[ShotKeys.fieldBlockedBy] as? String else {
                return "Error: handleShotStat() is field block guard failure"
            }
            fieldBlockedBy = fieldBlock
            description += "was field blocked."
        } else if shotResult == ShotKeys.shotResults.goalieSave {
            guard let save = shotStat[ShotKeys.savedBy] as? String else {
                return "Error: handleShotStat() is goalie save guard failure"
            }
            savedBy = save
            description += "was saved."
        } else if shotResult == ShotKeys.shotResults.miss {
            description += " sails wide of the cage."
        }
       
        var shot = Shot(gameTime: gameTime, shooter: shooter, phaseOfGame: phaseOfGame, shotLocation: shotLocation, isSkip: isSkip, shotResult: shotResult)
        shot.shooterPosition = shooterPosition
        shot.shotDetail = shotDetail
        shot.assistedBy = assistedBy
        shot.goalConcededBy = goalConcededBy
        shot.savedBy = savedBy
        shot.fieldBlockedBy = fieldBlockedBy
        
       
        if team == homeTeam {
            shotTracker[homeTeamKey, default: [:]][shooter, default: []].append(shot)
            if shotResult == ShotKeys.shotResults.goal {
                homeScore += 1
            }
        } else if team == awayTeam {
            shotTracker[awayTeamKey, default: [:]][shooter, default: []].append(shot)
            if shotResult == ShotKeys.shotResults.goal {
                awayScore += 1
            }
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
        
        
        guard let player = exclusionStat[ExclusionKeys.excludedPlayer] as? String,
              let type = exclusionStat[ExclusionKeys.exclusionType] as? String,
              let drawnBy = exclusionStat[ExclusionKeys.drawnBy] as? String,
              let phase = exclusionStat[ExclusionKeys.phaseOfGame] as? String,
              let excludedTeam = exclusionStat[ExclusionKeys.excludedTeam] as? String else {
            return "Error: handleExclusionStat() guard error"
        }
        
        let exclusion = Exclusion(gameTime: gameTime, exclusionType: type, drawnBy: drawnBy, phaseOfGame: phase)

        if excludedTeam == homeTeam {
            exclusionTracker[homeTeamKey, default: [:]][player, default: []].append(exclusion)
        } else if excludedTeam == awayTeam {
            exclusionTracker[awayTeamKey, default: [:]][player, default: []].append(exclusion)
        }
        
        var description: String = ""
        description += player + " was excluded in " + (PhaseOfGameKeys.toDisp[phase] ?? "...\nERROR: phase of game not recognized")
        return description
    }

    
    struct Steal {
        var gameTime: Int
        var stolenBy: String
        var turnoverBy: String
    }
    
    var stealTracker: [String: [Steal]] = [:]
    
    private func handleStealStat(stealStat: [String: Any], gameTime: Int) -> String {
        guard let stolenBy = stealStat[StealKeys.stolenBy] as? String,
              let turnoverBy = stealStat[StealKeys.turnoverBy] as? String,
              let team = stealStat[StealKeys.team] as? String else {
            return "Error: handleStealStat() guard failure"
        }
        
        let steal = Steal(gameTime: gameTime, stolenBy: stolenBy, turnoverBy: turnoverBy)
        
        if team == homeTeam {
            stealTracker[homeTeamKey, default: []].append(steal)
        } else {
            stealTracker[awayTeamKey, default: []].append(steal)
        }
        
        return "Steal by " + stolenBy + " for " + team
    }
    
    struct Turnover {
        var gameTime: Int
        var player: String
        var turnoverType: String
    }
    var turnoverTracker: [String: [Turnover]] = [:]
    
    private func handleTurnoverStat(turnoverStat: [String: Any], gameTime: Int) -> String {
        guard let team = turnoverStat[TurnoverKeys.team] as? String,
              let player = turnoverStat[TurnoverKeys.player] as? String,
              let turnoverType = turnoverStat[TurnoverKeys.turnoverType] as? String else {
            return "Error: handleTurnoverStat() gaurd failure"
        }
        
        let turnover = Turnover(gameTime: gameTime, player: player, turnoverType: turnoverType)
        
        if team == homeTeam {
            turnoverTracker[homeTeamKey, default: []].append(turnover)
        } else if team == awayTeam {
            turnoverTracker[awayTeamKey, default: []].append(turnover)
        }
        
        return "Turnover by " + team + ", committed by " + player
    }
    
    struct Timeout {
        var gameTime: Int
        var timeoutType: String
    }
    
    var timeoutTracker: [String: [Timeout]] = [:]
    
    private func handleTimeoutStat(timeoutStat: [String: Any], gameTime: Int) -> String {
        guard let team = timeoutStat[TimeoutKeys.team] as? String,
              let timeoutType = timeoutStat[TimeoutKeys.timeoutType] as? String else {
            return "Error: handleTimeoutStat() guard failure"
        }
        
        let timeout = Timeout(gameTime: gameTime, timeoutType: timeoutType)
        
        if team == homeTeam {
            timeoutTracker[homeTeamKey, default: []].append(timeout)
            homeTimeoutsLeft -= timeoutType == TimeoutKeys.full ? 1 : 0.5
        } else if team == awayTeam {
            timeoutTracker[awayTeamKey, default: []].append(timeout)
            awayTimeoutsLeft -= timeoutType == TimeoutKeys.full ? 1 : 0.5
      }
        
        return (TimeoutKeys.toDisp[timeoutType] ?? "") + " timeout taken by " + team
    }
    
    
    /* This is the init function for the game, run once in FirebaseManager.addGameListener() */
    public func populate(stats: [(Int, String, [String: Any])], homeTeam: String, awayTeam: String) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        
        secondsTracker[homeTeamKey] = [:]
        secondsTracker[awayTeamKey] = [:]
        
        exclusionTracker[homeTeamKey] = [:]
        exclusionTracker[awayTeamKey] = [:]
        
        stealTracker[homeTeamKey] = []
        stealTracker[awayTeamKey] = []
        
        shotTracker[homeTeamKey] = [:]
        shotTracker[awayTeamKey] = [:]
        
        turnoverTracker[homeTeamKey] = []
        turnoverTracker[awayTeamKey] = []
        
        timeoutTracker[homeTeamKey] = []
        timeoutTracker[awayTeamKey] = []
        
        for stat in stats {
            addStat(gameTime: stat.0, statType: stat.1, stat: stat.2)
        }
        
//        self.isPopulated = true
    }
    
    
    public func addStat(gameTime: Int, statType: String, stat: [String: Any]) {
        updateSecondsTracker(gameTime: gameTime)
        var description: String = ""
        
        switch statType {
        case StatType.lineup:
            handleLineupStat(lineupStat: stat, gameTime: gameTime)
            description += "Lineup change"
        case StatType.shot:
            description += handleShotStat(shotStat: stat, gameTime: gameTime)
        case StatType.exclusion:
            description += handleExclusionStat(exclusionStat: stat, gameTime: gameTime)
        case StatType.steal:
            description += handleStealStat(stealStat: stat, gameTime: gameTime)
        case StatType.turnover:
            description += handleTurnoverStat(turnoverStat: stat, gameTime: gameTime)
        case StatType.timeout:
            description += handleTimeoutStat(timeoutStat: stat, gameTime: gameTime)
        default:
            description += "Error: Unknown stat recorded"
        }
        
//        print(description)
        
        playByPlay.append((gameTime, description))
    }
    
    public func reset() {
//        isPopulated = false
        secondsTracker.removeAll()
        shotTracker.removeAll()
        exclusionTracker.removeAll()
        stealTracker.removeAll()
        turnoverTracker.removeAll()
        timeoutTracker.removeAll()
        playByPlay.removeAll()
        
        gameCollectionName = ""
        homeTeam = ""
        awayTeam = ""
        homeInTheGame = LineupWithCapNumbers()
        awayInTheGame = LineupWithCapNumbers()
        homeScore = 0
        awayScore = 0
        quarter = 1
        homeTimeoutsLeft = 3.5
        awayTimeoutsLeft = 3.5
        
    }
    
    
}
