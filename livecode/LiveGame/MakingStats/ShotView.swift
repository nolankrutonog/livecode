//
//  ShotView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/26/24.
//

import SwiftUI

struct ShotViewModel {
    var gameDocumentName: String = ""
    var homeTeam: String = ""
    var awayTeam: String = ""
    var quarter: Int = 1
    var offenseLineup: Lineup = Lineup()
    var defenseLineup: Lineup = Lineup()
    
    var selectedTeam: String = ""
    var selectedPlayer: String = ""
    var phaseOfGame: String = ""
    var shooterPosition: String = ""
    var shotLocation: String = ""
    var shotDetail: String = ""
    var isSkip: Bool = false
    var shotResult: String = ""
    var assistedBy: String = ""
    var goalConcededBy: String = ""
    var fieldBlockedBy: String = ""
    var savedBy: String = ""
}

struct ShotView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var shotViewModel: ShotViewModel = ShotViewModel()
//    @State private var path = NavigationPath() // NavigationPath to control the stack
//    @State private var nextView: String = ""
    @State private var navigateToSelectPlayer = false;
    
    let gameDocumentName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    init(gameDocumentName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameDocumentName = gameDocumentName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
    }

    var body: some View {
//        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Button(action: {
//                    shotViewModel.gameDocumentName = gameDocumentName
//                    shotViewModel.quarter = quarter
//                    shotViewModel.homeTeam = homeTeam
//                    shotViewModel.awayTeam = awayTeam
                    shotViewModel.selectedTeam = homeTeam
                    shotViewModel.offenseLineup = homeInTheGame
                    shotViewModel.defenseLineup = awayInTheGame
//                    path.append("selectPlayer")
//                    nextView = "selectPlayer"
                    navigateToSelectPlayer = true
                }) {
                    Text(homeTeam)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 310)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
//                    shotViewModel.gameDocumentName = gameDocumentName
//                    shotViewModel.quarter = quarter
//                    shotViewModel.homeTeam = homeTeam
//                    shotViewModel.awayTeam = awayTeam
                    shotViewModel.selectedTeam = awayTeam
                    shotViewModel.offenseLineup = awayInTheGame
                    shotViewModel.defenseLineup = homeInTheGame
//                    path.append("selectPlayer")
//                    nextView = "selectPlayer"
                    navigateToSelectPlayer = true
                }) {
                    Text(awayTeam)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .frame(height: 310)
                        .background(Color.white)
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .padding()
//            .navigationDestination(isPresented: .constant(nextView == "selectPlayer")) {
//                SelectPlayerView(shotViewModel: $shotViewModel, path: $path)
//            }
            .navigationDestination(isPresented: $navigateToSelectPlayer) {
                SelectPlayerView(shotViewModel: $shotViewModel)
            }
//            .onAppear {
//                shotViewModel.selectedTeam = ""
//                shotViewModel.selectedInTheGame = Lineup()
//                shotViewModel.unselectedInTheGame = Lineup()
//            }
//        }
    }
}


struct SelectPlayerView: View {
    @Binding var shotViewModel: ShotViewModel
//    @Binding var path: NavigationPath
//    @State private var nextView: String = ""
    @State private var navigateToSelectPhase = false
    
    var body: some View {
        Form {
            Section(header: Text("Shooter")) {
                let offensePlayers = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies
                ForEach(offensePlayers, id: \.self) { player in
                    Button(action: {
                        shotViewModel.selectedPlayer = player
//                        path.append("selectPhase")
//                        nextView = "selectPhase"
                        navigateToSelectPhase = true
                    }) {
                        Text(player)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.vertical)
                            .cornerRadius(8)
                    }
                }
            }
        }
//        .navigationDestination(isPresented: .constant(nextView == "selectPhase")) {
//            SelectPhaseOfGame(shotViewModel: $shotViewModel, path: $path)
//        }
        .navigationDestination(isPresented: $navigateToSelectPhase) {
            SelectPhaseOfGame(shotViewModel: $shotViewModel)
        }
    }
    
}

struct SelectPhaseOfGame: View {
    @Binding var shotViewModel: ShotViewModel
//    @Binding var path: NavigationPath
    
    @State var navigateToShooterPosition = false
    @State var navigateToShotLocation = false
    
//    let shooterPosition = "shooterPosition"
//    let shotLocation = "shotLocation"
    
    var body: some View {
        Form {
            Section(header: Text("Phase Of Game")) {
                phaseButton(label: ShotKeys.dispPhases.frontCourtOffense, phase: ShotKeys.phases.frontCourtOffense)
                phaseButton(label: ShotKeys.dispPhases.sixOnFive, phase: ShotKeys.phases.sixOnFive)
                phaseButton(label: ShotKeys.dispPhases.transitionOffense, phase: ShotKeys.phases.transitionOffense)
                phaseButton(label: ShotKeys.dispPhases.penalty, phase: ShotKeys.phases.penalty)
            }
        }
        .navigationDestination(isPresented: $navigateToShotLocation) {
            SelectShotLocationView(shotViewModel: $shotViewModel)
        }
        .navigationDestination(isPresented: $navigateToShooterPosition) {
            SelectShooterPositionView(shotViewModel: $shotViewModel)
        }
//        .navigationDestination(for: String.self) { view in
//            switch view {
//            case shooterPosition:
//                SelectShooterPositionView(shotViewModel: $shotViewModel, path: $path)
//            default:
//                EmptyView()
//            }
//        }
//        .navigationDestination(for: String.self) { view in
//            switch view {
//            case shotLocation:
//                SelectShotLocationView(shotViewModel: $shotViewModel, path: $path)
//            default:
//                EmptyView()
//            }
//        }
    }
    
    private func phaseButton(label: String, phase: String) -> some View {
        Button(action: {
            shotViewModel.phaseOfGame = phase
            if phase == ShotKeys.phases.penalty {
//                path.append(shotLocation)
                navigateToShotLocation = true
            } else {
//                path.append(shooterPosition)
                navigateToShooterPosition = true
            }
        }) {
            Text(label)
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.vertical)
                .cornerRadius(8)
        }

    }
}

struct SelectShooterPositionView: View {
    @Binding var shotViewModel: ShotViewModel
//    @Binding var path: NavigationPath
    
    @State var navigateToShotLocation = false
   
    
    var body: some View {
        Form {
            Section(header: Text("Position")) {
                if shotViewModel.phaseOfGame == ShotKeys.phases.frontCourtOffense {
                    positionButton(label: ShotKeys.dispFcoPositions.one, key: ShotKeys.fcoPositions.one)
                    positionButton(label: ShotKeys.dispFcoPositions.two, key: ShotKeys.fcoPositions.two)
                    positionButton(label: ShotKeys.dispFcoPositions.three, key: ShotKeys.fcoPositions.three)
                    positionButton(label: ShotKeys.dispFcoPositions.four, key: ShotKeys.fcoPositions.four)
                    positionButton(label: ShotKeys.dispFcoPositions.five, key: ShotKeys.fcoPositions.five)
                    positionButton(label: ShotKeys.dispFcoPositions.center, key: ShotKeys.fcoPositions.center)
                    positionButton(label: ShotKeys.dispFcoPositions.postUp, key: ShotKeys.fcoPositions.postUp)
                    positionButton(label: ShotKeys.dispFcoPositions.drive, key: ShotKeys.fcoPositions.drive)

                } else if shotViewModel.phaseOfGame == ShotKeys.phases.sixOnFive {
                    positionButton(label: ShotKeys.sixOnFivePositions.one, key: ShotKeys.sixOnFivePositions.one)
                    positionButton(label: ShotKeys.sixOnFivePositions.two, key: ShotKeys.sixOnFivePositions.two)
                    positionButton(label: ShotKeys.sixOnFivePositions.three, key: ShotKeys.sixOnFivePositions.three)
                    positionButton(label: ShotKeys.sixOnFivePositions.four, key: ShotKeys.sixOnFivePositions.four)
                    positionButton(label: ShotKeys.sixOnFivePositions.five, key: ShotKeys.sixOnFivePositions.five)
                    positionButton(label: ShotKeys.sixOnFivePositions.six, key: ShotKeys.sixOnFivePositions.six)

                } else if shotViewModel.phaseOfGame == ShotKeys.phases.transitionOffense {
                    positionButton(label: ShotKeys.dispTransitionOffensePositions.leftSide, key: ShotKeys.transitionOffensePositions.leftSide)
                    positionButton(label: ShotKeys.dispTransitionOffensePositions.rightSide, key: ShotKeys.transitionOffensePositions.rightSide)
                    positionButton(label: ShotKeys.dispTransitionOffensePositions.postUp, key: ShotKeys.transitionOffensePositions.postUp)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToShotLocation) {
            SelectShotLocationView(shotViewModel: $shotViewModel)
        }
//        .navigationDestination(for: String.self) { view in
//            switch view {
//            case "shotLocation":
//                SelectShotLocationView(shotViewModel: $shotViewModel, path: $path)
//            default:
//                EmptyView()
//            }
//        }
    }
    
    private func positionButton(label: String, key: String) -> some View {
        Button(action: {
            shotViewModel.shooterPosition = key
            navigateToShotLocation = true
//            path.append("shotLocation")
        }) {
            Text(label)
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.vertical)
                .cornerRadius(8)
        }
    }
}

struct SelectShotLocationView: View {
    @Binding var shotViewModel: ShotViewModel
//    @Binding var path: NavigationPath
    @State private var navigate = false
    @State private var isPenalty = false
    
    private let boxSize: CGFloat = 100
    
    var body: some View {
        VStack {
            HStack {
                Text("Select Shot Location")
                    .font(.title2)
                    .padding(.horizontal, 10)
                Spacer()
            }
            HStack {
                locationButton(number: ShotKeys.shotLocations.two)
                locationButton(number: ShotKeys.shotLocations.three)
                locationButton(number: ShotKeys.shotLocations.four)
            }
            HStack {
                // 1 5
                locationButton(number: ShotKeys.shotLocations.one)
                Spacer()
                locationButton(number: ShotKeys.shotLocations.five)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .navigationDestination(isPresented: $navigate) {
            if shotViewModel.phaseOfGame == ShotKeys.phases.penalty {
                SelectSkipView(shotViewModel: $shotViewModel)
            } else {
                SelectShotDetailsView(shotViewModel: $shotViewModel)
            }
        }
    }
    
    private func locationButton(number: String) -> some View {
        Button(action: {
            shotViewModel.shotLocation = number
            navigate = true
        }) {
            Text(number)
                .frame(width: boxSize, height: boxSize)
                .background(shotViewModel.shotLocation == number ? Color.blue : Color.gray)
                .foregroundColor(shotViewModel.shotLocation == number ? .primary : Color.white)
        }
    }
}

struct SelectShotDetailsView: View {
    @Binding var shotViewModel: ShotViewModel
    @State private var navigateToIsSkip = false
    
    var body: some View {
        Form {
            Section(header: Text("Shot Detail")) {
                detailButton(label: ShotKeys.dispShotDetailKeys.fake, key: ShotKeys.shotDetailKeys.fake)
                detailButton(label: ShotKeys.dispShotDetailKeys.catchAndShoot, key: ShotKeys.shotDetailKeys.catchAndShoot)
                detailButton(label: ShotKeys.dispShotDetailKeys.pickupAndShoot, key: ShotKeys.shotDetailKeys.pickupAndShoot)
                detailButton(label: ShotKeys.dispShotDetailKeys.foulSixMeters, key: ShotKeys.shotDetailKeys.foulSixMeters)
            }
        }
        .navigationDestination(isPresented: $navigateToIsSkip) {
            SelectSkipView(shotViewModel: $shotViewModel)
        }
        .onAppear {
            shotViewModel.shotDetail = ""
        }
    }
    
    private func detailButton(label: String, key: String) -> some View {
        Button(action: {
            shotViewModel.shotDetail = key
            navigateToIsSkip = true
        }) {
            Text(label)
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.vertical)
                .cornerRadius(8)
            .cornerRadius(8)
        }

    }
    
}

struct SelectSkipView: View {
    @Binding var shotViewModel: ShotViewModel
    @State private var navigateToShotResult = false
    
    var body: some View {
        Form {
            Section(header: Text("Is skip")) {
                Button(action: {
                    shotViewModel.isSkip = true
                    navigateToShotResult = true
                }) {
                    Text("Skip")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                        .cornerRadius(8)
                }
                Button(action: {
                    shotViewModel.isSkip = false
                    navigateToShotResult = true
                }) {
                    Text("No skip")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                        .cornerRadius(8)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToShotResult) {
            SelectShotResultView(shotViewModel: $shotViewModel)
        }
    }
}

struct SelectShotResultView: View {
    @Binding var shotViewModel: ShotViewModel
    
    @State private var navigateToAssist = false
    @State private var navigateToFieldBlock = false
    @State private var navigateToFinish = false
    
    var body: some View {
        Form {
            Section(header: Text("Result")) {
                resultButton(label: ShotKeys.dispShotResults.goal, key: ShotKeys.shotResults.goal)
                resultButton(label: ShotKeys.dispShotResults.fieldBlock, key: ShotKeys.shotResults.fieldBlock)
                resultButton(label: ShotKeys.dispShotResults.goalieSave, key: ShotKeys.shotResults.goalieSave)
                resultButton(label: ShotKeys.dispShotResults.miss, key: ShotKeys.shotResults.miss)
            }
        }
        .onAppear {
            shotViewModel.savedBy = ""
            shotViewModel.goalConcededBy = ""
        }
        .navigationDestination(isPresented: $navigateToAssist) {
           SelectAssistView(shotViewModel: $shotViewModel)
        }
        .navigationDestination(isPresented: $navigateToFieldBlock) {
           SelectFieldBlockedView(shotViewModel: $shotViewModel)
        }
        .navigationDestination(isPresented: $navigateToFinish) {
            FinishShotView(shotViewModel: $shotViewModel)
        }
    }
    
    private func resultButton(label: String, key: String) -> some View {
        Button(action: {
            shotViewModel.shotResult = key
            if key == ShotKeys.shotResults.goal {
                shotViewModel.goalConcededBy = shotViewModel.defenseLineup.goalies[0]
                if shotViewModel.phaseOfGame == ShotKeys.phases.penalty {
                    navigateToFinish = true
                } else {
                    navigateToAssist = true
                }
            } else if key == ShotKeys.shotResults.fieldBlock {
                navigateToFieldBlock = true
            } else {
                /* on miss or goalie save */
                if key == ShotKeys.shotResults.goalieSave {
                    shotViewModel.savedBy = shotViewModel.defenseLineup.goalies.first!
                }
                navigateToFinish = true
            }
        }) {
            Text(label)
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.vertical)
                .cornerRadius(8)
        }

    }
}

struct SelectFieldBlockedView: View {
    @Binding var shotViewModel: ShotViewModel
    
    @State private var navigateToFinish = false
    
    var body: some View {
        Form {
            Section(header: Text("Blocked By")) {
                ForEach(shotViewModel.defenseLineup.field, id: \.self) { player in
                    Button(action: {
                        shotViewModel.fieldBlockedBy = player
                        navigateToFinish = true
                    }) {
                        Text(player)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.vertical)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            shotViewModel.fieldBlockedBy = ""
        }
        .navigationDestination(isPresented: $navigateToFinish) {
            FinishShotView(shotViewModel: $shotViewModel)
        }
    }
}


struct SelectAssistView: View {
    @Binding var shotViewModel: ShotViewModel
    
    @State private var navigateToFinish = false
    
    var body: some View {
        Form {
            Section(header: Text("Assisted By")) {
                let inTheGame = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies
                let canAssist = inTheGame.filter { $0 != shotViewModel.selectedPlayer }
                ForEach(canAssist, id: \.self) { player in
                    Button(action: {
                        shotViewModel.assistedBy = player
                        navigateToFinish = true
                    }) {
                        Text(player)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.vertical)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            shotViewModel.assistedBy = ""
        }
        .navigationDestination(isPresented: $navigateToFinish) {
            FinishShotView(shotViewModel: $shotViewModel)
        }
    }
}

struct FinishShotView: View {
    @Binding var shotViewModel: ShotViewModel
    @State private var navigateToGameView = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            Form {
                Section(header: Text("")) {
                    Text("Shooter: ") + Text(shotViewModel.selectedPlayer).bold()
                    Text("Phase of Game: ") + Text(shotViewModel.phaseOfGame).bold()
                    if !shotViewModel.shooterPosition.isEmpty {
                        Text("Shooter Position: ") + Text(shotViewModel.shooterPosition).bold()
                    }
                    Text("Shot Location: ") + Text(ShotKeys.locationNumToValue[shotViewModel.shotLocation]!).bold()
                    if !shotViewModel.shotDetail.isEmpty {
                        Text("Shot Detail: ") + Text(shotViewModel.shotDetail).bold()
                    }
                    Text("Is Skip: ") + Text(shotViewModel.isSkip ? "Yes" : "No").bold()
                    Text("Shot Result: ") + Text(shotViewModel.shotResult).bold()
                    if !shotViewModel.assistedBy.isEmpty {
                        Text("Assisted By: ") + Text(shotViewModel.assistedBy).bold()
                    }
                    if !shotViewModel.goalConcededBy.isEmpty {
                        Text("Goal Conceded By: ") + Text(shotViewModel.goalConcededBy).bold()
                    }
                    if !shotViewModel.fieldBlockedBy.isEmpty {
                        Text("Field Blocked By: ") + Text(shotViewModel.fieldBlockedBy).bold()
                    }
                    if !shotViewModel.savedBy.isEmpty {
                        Text("Saved By: ") + Text(shotViewModel.savedBy).bold()
                    }
                }
            }
            Button(action: {
                // TODO: make a createShotStat() func in FirebaseManager
//               navigateToGameView = true
//                dismiss()
//                path.removeLast(path.count)
            }) {
                Text("Submit")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding()
        }
        .navigationDestination(isPresented: $navigateToGameView) {
            GameView(homeTeam: $shotViewModel.homeTeam.wrappedValue, 
                     awayTeam: $shotViewModel.awayTeam.wrappedValue,
                     gameDocumentName: $shotViewModel.gameDocumentName.wrappedValue
            )
            .environmentObject(FirebaseManager())
        }
    }
}


struct ShotView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShotView(
                gameDocumentName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame
            )
            .environmentObject(FirebaseManager())
        }
    }
}

//struct SelectShot___View_Preview: PreviewProvider {
//    
//    static var previews: some View {
//        NavigationStack {
//            SelectShotDetailsView(shotViewModel: .constant(ShotViewModel()))
//            .environmentObject(FirebaseManager())
//        }
//    }
//}


