////
////  Stats.swift
////  livecode
////
////  Created by Nolan Krutonog on 8/18/24.
////
//
//
//struct GameStats: Codable {
//}
//
//
//enum StatType: String, Codable {
//    case lineup
//    case shot
//    case exclusion
//}
//
//struct Lineup: {
//    
//}
//
//struct Shot: Codable {
//    var quarter: Int
//    var time:
//    var team: String
//    var player: String
//    var phaseOfGame: PhaseOfGame
//    var shooterPosition: ShooterPosition
//    var shooterLocation: ShooterLocation
//    var shotDetails: [ShotDetail]
//    var shotResult: ShotResult
//}
//
//enum ShotDetail: String, Codable {
//    case direct
//    case fake
//    case inBox = "in_box"
//    case outBox = "out_box"
//    case pickupAndShoot = "pickup_and_shoot"
//    case catchAndShoot = "catch_and_shoot"
//}
//
//enum PhaseOfGame: String, Codable {
//    case manUp = "man_up"
//    case manDown = "man_down"
//    case frontCourtOffense = "front_court_offense"
//    case frontCourtDefense = "front_court_defense"
//    case transitionOffense = "transition_offense"
//    case transitionDefense = "transition_defense"
//}
//
//enum ShooterPosition: String, Codable {
//    case one = "1"
//    case two = "2"
//    case three = "3"
//    case four = "4"
//    case five = "5"
//    case six = "6"
//    case twoPost = "2_post"
//    case threePost = "3_post"
//    case center
//    case postUp = "post_up"
//}
//
//enum ShooterLocation: String, Codable {
//    case one = "1"
//    case two = "2"
//    case three = "3"
//    case four = "4"
//    case five = "5"
//}
//
//enum ShotResult: String, Codable {
//    case goal
//    case shot_block
//    case goalie_save
//    case miss
//}
//
