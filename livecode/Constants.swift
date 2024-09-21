//
//  Constants.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

// ContentView.swift 

import SwiftUI

let editRostersString = "Edit Rosters"
let newGameString = "New Game"
let previousGamesString = "Previous Games"


let userDefaultsRostersKey = "rostersKey"

/*
 to get the players:
 "\(rosterName)_names"
 is the key for userDefaults
 */

let maxQuarterMinutes = 8
let currentYear = String(Calendar.current.component(.year, from: Date()))

let gamesCollection = "games"
let gameNamesCollection = "game_names"
let rostersCollection = "rosters"

let metadataDocument = "metadata"

let isFinishedField = "is_finished"
let timestampField = "timestamp"

/* for each document in game collection */
let gameTimeField = "game_time"
let statTypeField = "stat_type"
let statField = "stat"

let homeTeamKey = "home_team"
let awayTeamKey = "away_team"


let fieldKey = "field"
let goaliesKey = "goalies"
let nameKey = "name"
let numberKey = "number"
let notesKey = "notes"



