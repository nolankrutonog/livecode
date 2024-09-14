//
//  ShotSingleView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/30/24.
//

import SwiftUI

struct CreateShotSingleView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isTimePickerPresented = false
    @State private var timeString = ""
    
    let gameCollectionName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    
    @State private var selectedTeam: String = ""
    @State private var shooter: String = ""
    @State private var phaseOfGame: String = ""
    @State private var shooterPosition: String = "" // isEmpty on penalty
    @State private var shotLocation: String = ""
    @State private var shotDetail: String = "" // isEmpty on penalty
    @State private var isSkip: Int = 0
    @State private var shotResult: String = ""
    
    // only one of the members below is selected
    @State private var assistedBy: String = ""
    @State private var goalConcededBy: String = ""
    @State private var fieldBlockedBy: String = ""
    @State private var savedBy: String = ""
    
    @State private var is7v6: Bool = false
    @State private var goalie: String = ""
    
    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameCollectionName = gameCollectionName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        
        _selectedTeam = State(initialValue: homeTeam)
//        _shooter = State(initialValue: homeInTheGame.field[0])
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Shot Details")) {
                    Picker("Team", selection: $selectedTeam) {
                        Text(homeTeam).tag(homeTeam)
                        Text(awayTeam).tag(awayTeam)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
//                    let offense = selectedTeam == homeTeam ? homeInTheGame.field + homeInTheGame.goalies : awayInTheGame.field + awayInTheGame.goalies
                    let offense = selectedTeam == homeTeam ? homeInTheGame : awayInTheGame
                    // defense doesnt include goalies
                    let defense = selectedTeam != homeTeam ? homeInTheGame : awayInTheGame
                    Picker("Shooter", selection: $shooter) {
                        Text("").tag("")
                        ForEach(offense.field + offense.goalies, id: \.self) { player in
                            Text(player).tag(player)
                        }
                    }
                    
                    Picker("Phase", selection: $phaseOfGame) {
                        Text("").tag("")
                        Text(ShotKeys.dispPhases.frontCourtOffense).tag(ShotKeys.phases.frontCourtOffense)
                        Text(ShotKeys.dispPhases.transitionOffense).tag(ShotKeys.phases.transitionOffense)
                        Text(ShotKeys.dispPhases.sixOnFive).tag(ShotKeys.phases.sixOnFive)
                        Text(ShotKeys.dispPhases.penalty).tag(ShotKeys.phases.penalty)
                    }
                    
                    if phaseOfGame != ShotKeys.phases.penalty {
                        Picker("Position", selection: $shooterPosition) {
                            Text("").tag("")
                            switch phaseOfGame {
                            case ShotKeys.phases.transitionOffense:
//                                Text(ShotKeys.dispTransitionOffensePositions.leftSide).tag(ShotKeys.transitionOffensePositions.leftSide)
//                                Text(ShotKeys.dispTransitionOffensePositions.rightSide).tag(ShotKeys.transitionOffensePositions.rightSide)
//                                Text(ShotKeys.dispTransitionOffensePositions.postUp).tag(ShotKeys.transitionOffensePositions.postUp)
                                ForEach(Array(ShotKeys.transitionOffensePosToDisp), id: \.key) { key, value in
                                    Text(value).tag(key)
                                }
                            case ShotKeys.phases.sixOnFive:
                                Text(ShotKeys.sixOnFivePositions.one).tag(ShotKeys.sixOnFivePositions.one)
                                Text(ShotKeys.sixOnFivePositions.two).tag(ShotKeys.sixOnFivePositions.two)
                                Text(ShotKeys.sixOnFivePositions.three).tag(ShotKeys.sixOnFivePositions.three)
                                Text(ShotKeys.sixOnFivePositions.four).tag(ShotKeys.sixOnFivePositions.four)
                                Text(ShotKeys.sixOnFivePositions.five).tag(ShotKeys.sixOnFivePositions.five)
                                Text(ShotKeys.sixOnFivePositions.six).tag(ShotKeys.sixOnFivePositions.six)
                            default: // front court offense
                                ForEach(Array(ShotKeys.fcoPositionsToDisp), id: \.key) { key, value in
                                    Text(value).tag(key)
                                }
//                                Text(ShotKeys.dispFcoPositions.one).tag(ShotKeys.fcoPositions.one)
//                                Text(ShotKeys.dispFcoPositions.two).tag(ShotKeys.fcoPositions.two)
//                                Text(ShotKeys.dispFcoPositions.three).tag(ShotKeys.fcoPositions.three)
//                                Text(ShotKeys.dispFcoPositions.four).tag(ShotKeys.fcoPositions.four)
//                                Text(ShotKeys.dispFcoPositions.five).tag(ShotKeys.fcoPositions.five)
//                                Text(ShotKeys.dispFcoPositions.center).tag(ShotKeys.fcoPositions.center)
//                                Text(ShotKeys.dispFcoPositions.postUp).tag(ShotKeys.fcoPositions.postUp)
//                                Text(ShotKeys.dispFcoPositions.drive).tag(ShotKeys.fcoPositions.drive)
                            }
                        }
                    }
                    
                    Picker("Location", selection: $shotLocation) {
                        Text("").tag("")
                        ForEach(Array(ShotKeys.locationNumToValue), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    }
                    
                    if phaseOfGame != ShotKeys.phases.penalty {
                        Picker("Detail", selection: $shotDetail) {
                            Text("").tag("")
                            ForEach(Array(ShotKeys.detailKeyToDisp), id: \.key) { key, value in
                                Text(value).tag(key)
                            }
                        }
                    }
                    
                    Picker("Is skip", selection: $isSkip) {
                        Text("").tag(2)
                        Text("Skip").tag(1)
                        Text("No skip").tag(0)
                    }
                    
                    Picker("Result", selection: $shotResult) {
                        Text("").tag("")
                        ForEach(Array(ShotKeys.resultKeyToDisp), id: \.key) { key, value in
                            Text(value).tag(key)
                        }
                    }
                    
                    if shotResult == ShotKeys.shotResults.goal {
                        Picker("Assisted by", selection: $assistedBy) {
                            Text("").tag("")
                            Text("None").tag("None")
                            ForEach(offense.field + offense.goalies, id: \.self) { player in
                                if player != shooter {
                                    Text(player).tag(player)
                                }
                            }
                        }
                        //                    Picker("Goal conceded by", selection: $goalConcededBy) {
                        //                        Text("").tag("")
                        //                        let goalie = selectedTeam != homeTeam ? homeInTheGame.goalies[0] : awayInTheGame.goalies[0]
                        //                        Text(goalie).tag(goalie)
                        //                    }
                    } else if shotResult == ShotKeys.shotResults.fieldBlock {
                        Picker("Field blocked by", selection: $fieldBlockedBy) {
                            Text("").tag("")
                            ForEach(defense.field, id: \.self) { defender in
                                Text(defender).tag(defender)
                            }
                        }
                    }
                    //                else if shotResult == ShotKeys.shotResults.goalieSave {
                    //                    $savedBy = selectedTeam == homeTeam ? awayInTheGame.goalies[0] : homeInTheGame.goalies[0]
                    //                }
                    if defense.goalies.count == 0 {
                        // 7v6 situation
//                        is7v6 = .constant(true)
                        Picker("Goalie", selection: $goalie) {
                            Text("").tag("")
                            ForEach(defense.field, id: \.self) { player in
                                Text(player).tag(player)
                            }
                        }
                        .onAppear {
                            is7v6 = !is7v6
                        }
                    }
                    
                }
            }
            Button(action: {
                if canSubmit() {
                    isTimePickerPresented = true
                    
                    if phaseOfGame == ShotKeys.phases.penalty {
                        shooterPosition = ""
                        shotDetail = ""
                    }
                    
//                    let possibleGoalie = goalie.isEmpty
//                            ? selectedTeam == homeTeam ? awayInTheGame.goalies.first : homeInTheGame.goalies.first
//                            : goalie
                    
                    if !is7v6 {
                        // TODO: if there's no goalie in the lineup and not 7v6... need to error check with do try catch block?
                        goalie = (selectedTeam == homeTeam ? awayInTheGame.goalies.first : homeInTheGame.goalies.first) ?? ""
                    }
                    
                    if shotResult == ShotKeys.shotResults.goal {
                        fieldBlockedBy = ""
                        savedBy = ""
                        goalConcededBy = goalie
                    } else if shotResult == ShotKeys.shotResults.fieldBlock {
                        savedBy = ""
                        assistedBy = ""
                        goalConcededBy = ""
                    } else if shotResult == ShotKeys.shotResults.miss {
                        savedBy = ""
                        assistedBy = ""
                        goalConcededBy = ""
                        fieldBlockedBy = ""
                    } else if shotResult == ShotKeys.shotResults.goalieSave {
                        assistedBy = ""
                        goalConcededBy = ""
                        fieldBlockedBy = ""
                        savedBy = goalie
                    }
                }
            }) {
                Text("Submit")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(canSubmit() ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .disabled(!canSubmit())
            .padding()
            
        }
        .navigationTitle("Shot")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(
                maxTime: maxQuarterMinutes,
                timeString: $timeString,
                onSubmit: {
                    Task {
                        do {
                            try await firebaseManager.createShotStat(
                                gameCollectionName: gameCollectionName,
                                quarter: quarter,
                                timeString: timeString,
                                selectedTeam: selectedTeam,
                                shooter: shooter,
                                phaseOfGame: phaseOfGame,
                                shooterPosition: shooterPosition,
                                shotLocation: shotLocation,
                                shotDetail: shotDetail,
                                isSkip: isSkip,
                                shotResult: shotResult,
                                assistedBy: assistedBy,
                                goalConcededBy: goalConcededBy,
                                fieldBlockedBy: fieldBlockedBy,
                                savedBy: savedBy
                            )
                        } catch {
                            print("Failed to create shot stat: \(error)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
//                    presentationMode.wrappedValue.dismiss()
                },
                onCancel: {
                    // Simply dismiss the TimePickerView and stay in ExclusionView
                    self.isTimePickerPresented = false
                }
            )
        }
    }
    
    private func canSubmit() -> Bool {
        if shooter.isEmpty 
            || phaseOfGame.isEmpty
            || shotLocation.isEmpty
            || shotResult.isEmpty 
            || isSkip == 2
        {
            return false
        }
        
        if phaseOfGame != ShotKeys.phases.penalty {
            if shooterPosition.isEmpty || shotDetail.isEmpty {
                return false
            }
        }
        
        
        if shotResult == ShotKeys.shotResults.goal && assistedBy.isEmpty {
            return false
        }
        
        if shotResult == ShotKeys.shotResults.fieldBlock && fieldBlockedBy.isEmpty {
            return false
        }
        
        // miss has no additional check
        
        // goalie only if we are 7v6
        if is7v6 && goalie.isEmpty{
            return false
        }
        
        return true
        
//        let constants = !shooter.isEmpty && !phaseOfGame.isEmpty
//        && !shotLocation.isEmpty && !shotResult.isEmpty
//        
//        var others: Bool = false
//        if phaseOfGame != ShotKeys.phases.penalty {
//            others = !shooterPosition.isEmpty && !shotDetail.isEmpty
//        } else {
//            others = true
//        }
//        
//        if shotResult == ShotKeys.shotResults.goal {
//            others = others && !assistedBy.isEmpty
//        }
//        
//        if shotResult == ShotKeys.shotResults.fieldBlock {
//            others = others && !fieldBlockedBy.isEmpty
//        }
//
//        return constants && others
    }
}


struct SingleShotView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            CreateShotSingleView(gameCollectionName: "Stanford_vs_UCLA-2024-08-25_1724557371", 
                           quarter: 1,
                           homeTeam: "Stanford",
                           awayTeam: "UCLA",
                           homeInTheGame: stanford7v6,
                           awayInTheGame: uclaInTheGame)
                .environmentObject(FirebaseManager())
        }
    }
}
