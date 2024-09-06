//
//  Stats.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//


let statType: String = "stat_type"

/* A GAME is a list of either Lineup, Shot, Exclusion, Steal, Timeout, Turnover */
struct StatType {
    static let timeout = "timeout"
    static let turnover = "turnover"
    static let steal = "steal"
    static let shot = "shot"
    static let exclusion = "exclusion"
    static let lineup = "lineup"
}

struct StealKeys {
    static let team = "team"
    static let stolenBy = "stolen_by"
    static let turnoverBy = "turnover_by"
}

struct LineupKeys {
    static let homeTeam = "home_team"
    static let awayTeam = "away_team"
    static let homeInTheGame = "home_in_the_game"
    static let awayInTheGame = "away_in_the_game"
    static let goalies = "goalies"
    static let field = "field"
}

struct TurnoverKeys {
    static let team = "team"
    static let player = "player"
}

struct ExclusionKeys {
    static let excludedTeam = "excluded_team"
    static let excludedPlayer = "excluded_player"
    static let phaseOfGame = "phase_of_game"
    static let exclusionType = "exclusion_type"
    static let drawnBy = "drawn_by"
    
    
    
//    static let exclusionTypes = [
//        "On ball center",
//        "On ball",
//        "Off ball",
//        "Penalty"
//    ]
    
    
    static let onBall = "on_ball"
    static let offBall = "off_ball"
    static let onBallCenter = "on_ball_center"
    static let penalty = "penalty"
    
    static let dispOnBall = "On ball"
    static let dispOffBall = "Off ball"
    static let dispOnBallCenter = "On ball center"
    static let dispPenalty = "Penalty"
    
    static let toDisp = [
        onBall: dispOnBall,
        offBall: dispOffBall,
        onBallCenter: dispOnBallCenter,
        penalty: dispPenalty
    ]
}

struct PhaseOfGameKeys {
    static let sixOnFive = "6v5"
    static let frontCourtOffense = "front_court_offense"
    static let transitionOffense = "transition_offense"
    static let fiveOnSix = "5v6"
    static let frontCourtDefense = "front_court_defense"
    static let transitionDefense = "transition_defense"
    
    static let allPhases = [
        "6v5",
        "Front court offense",
        "Transition offense",
        "5v6",
        "Front court defense",
        "Transition defense"
    ]
    
    static let defensePhases = [
        "Front court defense",
        "Transition defense",
        "5v6"
    ]
    
    static let offensePhases = [
        "6v5",
        "Front court offense",
        "Transition offense"
    ]
}

struct TimeoutKeys {
    static let team = "team"
    static let full = "full"
    static let half = "half"
}


struct ShotKeys {
    static let team = "team"
    static let shooter = "shooter"
    static let phaseOfGame = "phase_of_game"
    static let shooterPosition = "shooter_position"
    static let shotLocation = "shot_location"
    static let shotDetail = "shot_detail"
    static let isSkip = "is_skip"
    static let shotResult = "shot_result"
    static let assistedBy = "assisted_by"
    static let goalConcededBy = "goal_conceded_by"
    static let fieldBlockedBy = "field_blocked_by"
    static let savedBy = "saved_by"
    
    struct phases {
        static let frontCourtOffense = "front_court_offense"
        static let sixOnFive = "6v5"
        static let transitionOffense = "transition_offense"
        static let penalty = "penalty"
    }
    
    struct dispPhases {
        static let frontCourtOffense = "Front court offense"
        static let sixOnFive = "6v5"
        static let transitionOffense = "Transition offense"
        static let penalty = "Penalty"
    }
    
    struct fcoPositions {
        static let one = "1"
        static let two = "2"
        static let three = "3"
        static let four = "4"
        static let five = "5"
        static let center = "center"
        static let postUp = "post_up"
        static let drive = "drive"
//        static let redirect = "redirect"
    }
    
    struct dispFcoPositions {
        static let one = "1"
        static let two = "2"
        static let three = "3"
        static let four = "4"
        static let five = "5"
        static let center = "Center"
        static let postUp = "Post up"
        static let drive = "Drive"
//        static let redirect = "Redirect"
    }
    struct sixOnFivePositions {
        static let one = "1"
        static let two = "2"
        static let three = "3"
        static let four = "4"
        static let five = "5"
        static let six = "6"
        static let postUp = "post_up"
        static let drive = "drive"
    }
    
    struct transitionOffensePositions {
        static let leftSide = "left_side"
        static let rightSide = "right_side"
        static let postUp = "post_up"
    }
    
    struct dispTransitionOffensePositions {
        static let leftSide = "Left side"
        static let rightSide = "Right side"
        static let postUp = "Post up"
    }

    struct shotLocations {
        static let one = "1"
        static let two = "2"
        static let three = "3"
        static let four = "4"
        static let five = "5"
    }
    
    static let locationNumToValue = [
        "1": "Goalie right low",
        "2": "Goalie right high",
        "3": "Donut",
        "4": "Goalie left high",
        "5": "Goalie left low"
    ]
    
    struct shotDetailKeys {
//        static let skip = "skip"
        static let fake = "fake"
        static let catchAndShoot = "catch_and_shoot"
        static let pickupAndShoot = "pickup_and_shoot"
        static let foulSixMeters = "foul_six_meters"
        static let redirect = "redirect"
    }
    
    static let detailKeyToDisp = [
        shotDetailKeys.fake: dispShotDetailKeys.fake,
        shotDetailKeys.catchAndShoot: dispShotDetailKeys.catchAndShoot,
        shotDetailKeys.pickupAndShoot: dispShotDetailKeys.pickupAndShoot,
        shotDetailKeys.foulSixMeters: dispShotDetailKeys.foulSixMeters,
        shotDetailKeys.redirect: dispShotDetailKeys.redirect
    ]
    
    struct dispShotDetailKeys {
//        static let skip = "Skip"
        static let fake = "Fake"
        static let catchAndShoot = "Catch and shoot"
        static let pickupAndShoot = "Pickup and shoot"
        static let foulSixMeters = "Foul six meters"
        static let redirect = "Redirect"
    }

    
    struct shotResults {
        static var goal = "goal"
        static var fieldBlock = "field_block"
        static var goalieSave = "goalie_save"
        static var miss = "miss"
    }
    
    struct dispShotResults {
        static var goal = "Goal"
        static var fieldBlock = "Field Block"
        static var goalieSave = "Goalie Save"
        static var miss = "Miss"
    }
    
    static let resultKeyToDisp = [
        shotResults.goal: dispShotResults.goal,
        shotResults.fieldBlock: dispShotResults.fieldBlock,
        shotResults.goalieSave: dispShotResults.goalieSave,
        shotResults.miss: dispShotResults.miss
    ]

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

