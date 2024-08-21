//
//  Stats.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

/* A GAME is a list of either Lineup, Shot, Exclusion, Steal, Timeout */
struct Game {
    var homeTeam: String
    var awayTeam: String
    var gameName: String
    var events: [Any]
    
    mutating func addEvent(event: Any) {
        self.events.append(event)
    }
}

struct Timeout: Codable {
    var quarter: Int
    var time: Time
    var team: String
}

struct LineupStat: Codable {
    var quarter: Int
    var time: Time
    var team: String
    var goalie: String
    var field: [String]
    
    init(quarter: Int, time: Time, team: String, goalie: String, field: [String]) {
        self.quarter = quarter
        self.time = time
        self.team = team
        self.goalie = goalie
        self.field = field
    }
}

struct Exclusion: Codable {
    var quarter: Int
    var time: Time
    var team: String
    var player: String
    var phaseOfGame: PhaseOfGame
    var exclusionType: ExclusionType
    
    init(quarter: Int, time: Time, team: String, player: String, phaseOfGame: PhaseOfGame, exclusionType: ExclusionType) {
        self.quarter = quarter
        self.time = time
        self.team = team
        self.player = player
        self.phaseOfGame = phaseOfGame
        self.exclusionType = exclusionType
    }
}

/* <player> on <phaseOfGame> at position <shooterPosition> with <shotDetails> to <shotLocation> resulted in a <shotResult> */
struct Shot: Codable {
    var quarter: Int
    var time: Time
    var team: String
    var player: String
    var phaseOfGame: PhaseOfGame
    var shooterPosition: ShooterPosition
    var shotLocation: ShotLocation
    var shotDetails: [ShotDetail]
    var shotResult: ShotResult
    
    init(quarter: Int, time: Time, team: String, player: String,
         phaseOfGame: PhaseOfGame, shooterPosition: ShooterPosition,
         shotLocation: ShotLocation, shotDetails: [ShotDetail], shotResult: ShotResult) {
        self.quarter = quarter
        self.time = time
        self.team = team
        self.player = player
        self.phaseOfGame = phaseOfGame
        self.shooterPosition = shooterPosition
        self.shotLocation = shotLocation
        self.shotDetails = shotDetails
        self.shotResult = shotResult
    }
}

struct Steal: Codable {
    var quarter: Int
    var time: Time
    var team: String
    var player: String
    
    init(quarter: Int, time: Time, team: String, player: String) {
        self.quarter = quarter
        self.time = time
        self.team = team
        self.player = player
    }
}

enum ExclusionType: String, Codable {
    case offBall
    case onBall
    case onBallCenter
}

struct Time: Codable {
    var minutes: Int
    var seconds: Int
    
    init(minutes: Int, seconds: Int) {
        self.minutes = minutes
        self.seconds = seconds
    }
}


enum ShotDetail: String, Codable {
    case direct
    case fake
    case inBox
    case outBox
    case pickupAndShoot
    case catchAndShoot
    case skip
}

enum PhaseOfGame: String, Codable {
    case manUp
    case manDown
    case frontCourtOffense
    case frontCourtDefense
    case transitionOffense
    case transitionDefense
}

enum ShooterPosition: String, Codable {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case twoPost = "2_post"
    case threePost = "3_post"
    case center
    case postUp = "post_up"
}

enum ShotLocation: String, Codable {
    case one = "goalie-right-low"
    case two = "goalie-right-high"
    case three = "donut"
    case four = "goalie-left-high"
    case five = "goalie-left-low"
}

enum ShotResult: String, Codable {
    case goal
    case shot_block
    case goalie_save
    case miss
}

