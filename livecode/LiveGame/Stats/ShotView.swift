//
//  ShotView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/26/24.
//

import SwiftUI

/*
struct ShotViewSinglePage: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameCollectionName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    @State private var selectedTeam: String = ""
    @State private var shooter: String = ""
    @State private var phaseOfGame: String = ShotKeys.dispPhases.frontCourtOffense
    @State private var shooterPosition: String = ""
    @State private var shotLocation: String = ""
    let boxSize = 100.0

    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup) {
        self.gameCollectionName = gameCollectionName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        
        _selectedTeam = State(initialValue: homeTeam)
        _shooter = State(initialValue: homeInTheGame.field[0])
    }

   
    var body: some View {
        Form {
            Section(header: Text("Shot Details")) {
                Picker("Team", selection: $selectedTeam) {
                    Text(homeTeam).tag(homeTeam)
                    Text(awayTeam).tag(awayTeam)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                let offense = selectedTeam == homeTeam ? homeInTheGame.field + homeInTheGame.goalies : awayInTheGame.field + awayInTheGame.goalies
                
                Picker("Shooter", selection: $shooter) {
                    ForEach(offense, id: \.self) { player in
                        Text(player).tag(player)
                    }
                }
                
                Picker("Phase", selection: $phaseOfGame) {
                    Text(ShotKeys.dispPhases.frontCourtOffense).tag(ShotKeys.phases.frontCourtOffense)
                    Text(ShotKeys.dispPhases.transitionOffense).tag(ShotKeys.phases.transitionOffense)
                    Text(ShotKeys.dispPhases.sixOnFive).tag(ShotKeys.phases.sixOnFive)
                    Text(ShotKeys.dispPhases.penalty).tag(ShotKeys.phases.penalty)
                }
                
                if phaseOfGame != ShotKeys.phases.penalty {
                    Picker("Position", selection: $shooterPosition) {
                        switch phaseOfGame {
                        case ShotKeys.phases.transitionOffense:
                            Text(ShotKeys.dispTransitionOffensePositions.leftSide).tag(ShotKeys.transitionOffensePositions.leftSide)
                            Text(ShotKeys.dispTransitionOffensePositions.rightSide).tag(ShotKeys.transitionOffensePositions.rightSide)
                            Text(ShotKeys.dispTransitionOffensePositions.postUp).tag(ShotKeys.transitionOffensePositions.postUp)
                        case ShotKeys.phases.sixOnFive:
                            Text(ShotKeys.sixOnFivePositions.one).tag(ShotKeys.sixOnFivePositions.one)
                            Text(ShotKeys.sixOnFivePositions.two).tag(ShotKeys.sixOnFivePositions.two)
                            Text(ShotKeys.sixOnFivePositions.three).tag(ShotKeys.sixOnFivePositions.three)
                            Text(ShotKeys.sixOnFivePositions.four).tag(ShotKeys.sixOnFivePositions.four)
                            Text(ShotKeys.sixOnFivePositions.five).tag(ShotKeys.sixOnFivePositions.five)
                            Text(ShotKeys.sixOnFivePositions.six).tag(ShotKeys.sixOnFivePositions.six)
                        default: // front court offense
                            Text(ShotKeys.dispFcoPositions.one).tag(ShotKeys.fcoPositions.one)
                            Text(ShotKeys.dispFcoPositions.two).tag(ShotKeys.fcoPositions.two)
                            Text(ShotKeys.dispFcoPositions.three).tag(ShotKeys.fcoPositions.three)
                            Text(ShotKeys.dispFcoPositions.four).tag(ShotKeys.fcoPositions.four)
                            Text(ShotKeys.dispFcoPositions.five).tag(ShotKeys.fcoPositions.five)
                            Text(ShotKeys.dispFcoPositions.center).tag(ShotKeys.fcoPositions.center)
                            Text(ShotKeys.dispFcoPositions.postUp).tag(ShotKeys.fcoPositions.postUp)
                            Text(ShotKeys.dispFcoPositions.drive).tag(ShotKeys.fcoPositions.drive)
//                            Text(ShotKeys.dispFcoPositions.redirect).tag(ShotKeys.fcoPositions.redirect)
                            
                        }
                    }
                }
                    
                VStack(spacing: 0) {
                    HStack {
                        Text("Location: \(shotLocation)")
                            .padding(.leading, 10)
                        Spacer()
                    }
                    
                    HStack(spacing: 0) {
                        shotLocationBox(tag: "2")
                        shotLocationBox(tag: "3")
                        shotLocationBox(tag: "4")
                    }
                    .padding(.vertical, 10)
                    HStack(spacing: 0) {
                        shotLocationBox(tag: "1")
                        Spacer()
                        shotLocationBox(tag: "5")
                    }
                }
            }
        }
    }
    
    private func shotLocationBox(tag: String) -> some View {
        Button(action: {
            shotLocation = tag
            print("shotLocation set to \(tag)")
        }) {
            Text(ShotKeys.locationNumToValue[tag]!)
                .frame(width: boxSize, height: boxSize)
                .background(shotLocation == tag ? Color.blue : Color.gray)
                .cornerRadius(10)
                .foregroundColor(shotLocation == tag ? .primary : .white)
        }
        .padding(.horizontal, 5)
    }
}
*/

struct ShotViewModel {
    // initialized values
    var gameCollectionName: String = ""
    var homeTeam: String = ""
    var awayTeam: String = ""
    var quarter: Int = 1
    var offenseLineup: Lineup = Lineup()
    var defenseLineup: Lineup = Lineup()
    
    // values filled in by user
    var selectedTeam: String = ""
    var shooter: String = ""
    var phaseOfGame: String = ""
    var shooterPosition: String = "" // isEmpty on penalty
    var shotLocation: String = ""
    var shotDetail: String = "" // isEmpty on penalty
    var isSkip: Bool = false
    var shotResult: String = ""
    
    // only one of the members below is selected
    var assistedBy: String = ""
    var goalConcededBy: String = ""
    var fieldBlockedBy: String = ""
    var savedBy: String = ""
}

//struct ShotViewModel: Equatable, Hashable {
//    // Conformance to Equatable
//    static func == (lhs: ShotViewModel, rhs: ShotViewModel) -> Bool {
//        return lhs.gameCollectionName == rhs.gameCollectionName &&
//               lhs.homeTeam == rhs.homeTeam &&
//               lhs.awayTeam == rhs.awayTeam &&
//               lhs.quarter == rhs.quarter &&
//               lhs.offenseLineup == rhs.offenseLineup &&
//               lhs.defenseLineup == rhs.defenseLineup &&
//               lhs.selectedTeam == rhs.selectedTeam &&
//               lhs.shooter == rhs.shooter &&
//               lhs.phaseOfGame == rhs.phaseOfGame &&
//               lhs.shooterPosition == rhs.shooterPosition &&
//               lhs.shotLocation == rhs.shotLocation &&
//               lhs.shotDetail == rhs.shotDetail &&
//               lhs.isSkip == rhs.isSkip &&
//               lhs.shotResult == rhs.shotResult &&
//               lhs.assistedBy == rhs.assistedBy &&
//               lhs.goalConcededBy == rhs.goalConcededBy &&
//               lhs.fieldBlockedBy == rhs.fieldBlockedBy &&
//               lhs.savedBy == rhs.savedBy
//    }
//    
//    // Conformance to Hashable
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(gameCollectionName)
//        hasher.combine(homeTeam)
//        hasher.combine(awayTeam)
//        hasher.combine(quarter)
//        hasher.combine(offenseLineup)
//        hasher.combine(defenseLineup)
//        hasher.combine(selectedTeam)
//        hasher.combine(shooter)
//        hasher.combine(phaseOfGame)
//        hasher.combine(shooterPosition)
//        hasher.combine(shotLocation)
//        hasher.combine(shotDetail)
//        hasher.combine(isSkip)
//        hasher.combine(shotResult)
//        hasher.combine(assistedBy)
//        hasher.combine(goalConcededBy)
//        hasher.combine(fieldBlockedBy)
//        hasher.combine(savedBy)
//    }
//    
//    // Initialized values
//    var gameCollectionName: String = ""
//    var homeTeam: String = ""
//    var awayTeam: String = ""
//    var quarter: Int = 1
//    var offenseLineup: Lineup = Lineup()
//    var defenseLineup: Lineup = Lineup()
//    
//    // Values filled in by user
//    var selectedTeam: String = ""
//    var shooter: String = ""
//    var phaseOfGame: String = ""
//    var shooterPosition: String = "" // isEmpty on penalty
//    var shotLocation: String = ""
//    var shotDetail: String = "" // isEmpty on penalty
//    var isSkip: Bool = false
//    var shotResult: String = ""
//    
//    // Only one of the members below is selected
//    var assistedBy: String = ""
//    var goalConcededBy: String = ""
//    var fieldBlockedBy: String = ""
//    var savedBy: String = ""
//}


//struct ShotView: View {
//    @EnvironmentObject var firebaseManager: FirebaseManager
//    @Binding var navigationPath: [AnyHashable]
//    
//    @State private var shotViewModel: ShotViewModel = ShotViewModel()
////    @State private var path = NavigationPath() // NavigationPath to control the stack
////    @State private var nextView: String = ""
//    @State private var navigateToSelectPlayer = false;
//    
//    let gameCollectionName: String
//    let quarter: Int
//    let homeTeam: String
//    let awayTeam: String
//    let homeInTheGame: Lineup
//    let awayInTheGame: Lineup
//    
//    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup, navigationPath: Binding<[AnyHashable]>) {
//        self._navigationPath = navigationPath
//        self.gameCollectionName = gameCollectionName
//        self.quarter = quarter
//        self.homeTeam = homeTeam
//        self.awayTeam = awayTeam
//        self.homeInTheGame = homeInTheGame
//        self.awayInTheGame = awayInTheGame
//        
//        shotViewModel.gameCollectionName = gameCollectionName
//        shotViewModel.quarter = quarter
//        
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button(action: {
//                shotViewModel.selectedTeam = homeTeam
//                shotViewModel.offenseLineup = homeInTheGame
//                shotViewModel.defenseLineup = awayInTheGame
////                navigateToSelectPlayer = true
//            }) {
//                Text(homeTeam)
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 310)
//                    .background(Color.gray)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            }
//            
//            Button(action: {
//                shotViewModel.selectedTeam = awayTeam
//                shotViewModel.offenseLineup = awayInTheGame
//                shotViewModel.defenseLineup = homeInTheGame
////                navigateToSelectPlayer = true
//            }) {
//                Text(awayTeam)
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 310)
//                    .background(Color.white)
//                    .foregroundColor(.primary)
//                    .cornerRadius(12)
//                    .shadow(radius: 10)
//            }
//        }
//        .padding()
////        .navigationDestination(isPresented: $navigateToSelectPlayer) {
////            SelectPlayerView(shotViewModel: $shotViewModel)
////        }
//    }
//}

struct ShotView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Binding var navigationPath: [AnyHashable]
    
    @State private var shotViewModel: ShotViewModel = ShotViewModel()
    
    let gameCollectionName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    let homeInTheGame: Lineup
    let awayInTheGame: Lineup
    
    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String, homeInTheGame: Lineup, awayInTheGame: Lineup, navigationPath: Binding<[AnyHashable]>) {
        self._navigationPath = navigationPath
        self.gameCollectionName = gameCollectionName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeInTheGame = homeInTheGame
        self.awayInTheGame = awayInTheGame
        
        shotViewModel.gameCollectionName = gameCollectionName
        shotViewModel.quarter = quarter
    }

    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(
                destination: SelectPlayerView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
                    .onAppear {
                        shotViewModel.selectedTeam = homeTeam
                        shotViewModel.offenseLineup = homeInTheGame
                        shotViewModel.defenseLineup = awayInTheGame
                    }
            ) {
                Text(homeTeam)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 310)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            NavigationLink(
                destination: SelectPlayerView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
                    .onAppear {
                        shotViewModel.selectedTeam = awayTeam
                        shotViewModel.offenseLineup = awayInTheGame
                        shotViewModel.defenseLineup = homeInTheGame
                    }
            ) {
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
    }
}




//struct SelectPlayerView: View {
//    @Binding var shotViewModel: ShotViewModel
//    @Binding var navigationPath: [AnyHashable]
////    @State private var nextView: String = ""
//    @State private var navigateToSelectPhase = false
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Shooter")) {
//                let offensePlayers = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies
//                ForEach(offensePlayers, id: \.self) { player in
//                    Button(action: {
//                        shotViewModel.shooter = player
////                        path.append("selectPhase")
////                        nextView = "selectPhase"
//                        navigateToSelectPhase = true
//                    }) {
//                        Text(player)
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                            .padding(.vertical)
//                            .cornerRadius(8)
//                    }
//                }
//            }
//        }
//        .navigationDestination(isPresented: $navigateToSelectPhase) {
//            SelectPhaseOfGame(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
//        }
//    }
//    
//}

//struct SelectPlayerView: View, Hashable {
//    @Binding var shotViewModel: ShotViewModel
//    @Binding var navigationPath: [AnyHashable]
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Shooter")) {
//                let offensePlayers = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies
//                ForEach(offensePlayers, id: \.self) { player in
//                    Button(action: {
//                        shotViewModel.shooter = player
//                        // Navigate to SelectPhaseOfGame
//                        navigationPath.append(SelectPhaseOfGame(shotViewModel: $shotViewModel, navigationPath: $navigationPath))
//                    }) {
//                        Text(player)
//                            .font(.title2)
//                            .foregroundColor(.primary)
//                            .padding(.vertical)
//                            .cornerRadius(8)
//                    }
//                }
//            }
//        }
//    }
//    
//    // Implementing Hashable (required for NavigationPath)
//    static func == (lhs: SelectPlayerView, rhs: SelectPlayerView) -> Bool {
//        return lhs.shotViewModel == rhs.shotViewModel &&
//               lhs.navigationPath == rhs.navigationPath
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(shotViewModel)
//        hasher.combine(navigationPath)
//    }
//}



struct SelectPlayerView: View {
    @Binding var shotViewModel: ShotViewModel
    @Binding var navigationPath: [AnyHashable]
    @State private var navigateToSelectPhase = false
    
//    init(shotViewModel: Binding<ShotViewModel>, navigationPath: Binding<AnyHashable>) {
//        
//    }
    
    var body: some View {
        Form {
            Section(header: Text("Shooter")) {
                let offensePlayers = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies
                ForEach(offensePlayers, id: \.self) { player in
                    NavigationLink(
                        destination: SelectPhaseOfGame(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
                    ) {
                        Text(player)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.vertical)
                            .cornerRadius(8)
                    }
                    .onTapGesture {
                        print(player)
                        shotViewModel.shooter = player
                    }
                    .navigationDestination(isPresented: .constant(true)) {
                        SelectPhaseOfGame(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
                    }
                }
            }
        }
    }
}

//struct SelectPlayerView: View {
//    @Binding var shotViewModel: ShotViewModel
//    @Binding var navigationPath: [AnyHashable]
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Shooter")) {
//                let offensePlayers = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies
//                ForEach(offensePlayers, id: \.self) { player in
//                    Button(action: {
//                        // Update the state before navigation
//                        shotViewModel.shooter = player
//                        // Navigate to the next view
////                        navigationPath.append(SelectPhaseOfGame(shotViewModel: $shotViewModel, navigationPath: $navigationPath))
//                    }) {
//                        NavigationLink(
//                            destination: SelectPhaseOfGame(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
//                        ) {
//                            Text(player)
//                                .font(.title2)
//                                .foregroundColor(.primary)
//                                .padding(.vertical)
//                                .cornerRadius(8)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}


//struct SelectPhaseOfGame: View {
//    @Binding var shotViewModel: ShotViewModel
//    @Binding var navigationPath: [AnyHashable]
//    
//    @State var navigateToShooterPosition = false
//    @State var navigateToShotLocation = false
//    
////    let shooterPosition = "shooterPosition"
////    let shotLocation = "shotLocation"
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Phase Of Game")) {
//                phaseButton(label: ShotKeys.dispPhases.frontCourtOffense, phase: ShotKeys.phases.frontCourtOffense)
//                phaseButton(label: ShotKeys.dispPhases.sixOnFive, phase: ShotKeys.phases.sixOnFive)
//                phaseButton(label: ShotKeys.dispPhases.transitionOffense, phase: ShotKeys.phases.transitionOffense)
//                phaseButton(label: ShotKeys.dispPhases.penalty, phase: ShotKeys.phases.penalty)
//            }
//        }
//        .navigationDestination(isPresented: $navigateToShotLocation) {
//            SelectShotLocationView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
//        }
//        .navigationDestination(isPresented: $navigateToShooterPosition) {
//            SelectShooterPositionView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
//        }
////        .navigationDestination(for: String.self) { view in
////            switch view {
////            case shooterPosition:
////                SelectShooterPositionView(shotViewModel: $shotViewModel, path: $path)
////            default:
////                EmptyView()
////            }
////        }
////        .navigationDestination(for: String.self) { view in
////            switch view {
////            case shotLocation:
////                SelectShotLocationView(shotViewModel: $shotViewModel, path: $path)
////            default:
////                EmptyView()
////            }
////        }
//    }
//
//
//    
//    private func phaseButton(label: String, phase: String) -> some View {
//        Button(action: {
//            shotViewModel.phaseOfGame = phase
//            if phase == ShotKeys.phases.penalty {
////                path.append(shotLocation)
//                navigateToShotLocation = true
//            } else {
////                path.append(shooterPosition)
//                navigateToShooterPosition = true
//            }
//        }) {
//            Text(label)
//                .font(.title2)
//                .foregroundColor(.primary)
//                .padding(.vertical)
//                .cornerRadius(8)
//        }
//
//    }
//}

//struct SelectPhaseOfGame: View, Hashable {
//    @Binding var shotViewModel: ShotViewModel
//    @Binding var navigationPath: [AnyHashable]
//    
//    @State var navigateToShooterPosition = false
//    @State var navigateToShotLocation = false
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Phase Of Game")) {
//                phaseButton(label: ShotKeys.dispPhases.frontCourtOffense, phase: ShotKeys.phases.frontCourtOffense)
//                phaseButton(label: ShotKeys.dispPhases.sixOnFive, phase: ShotKeys.phases.sixOnFive)
//                phaseButton(label: ShotKeys.dispPhases.transitionOffense, phase: ShotKeys.phases.transitionOffense)
//                phaseButton(label: ShotKeys.dispPhases.penalty, phase: ShotKeys.phases.penalty)
//            }
//        }
//        .navigationDestination(isPresented: $navigateToShotLocation) {
//            SelectShotLocationView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
//        }
//        .navigationDestination(isPresented: $navigateToShooterPosition) {
//            SelectShooterPositionView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
//        }
//    }
//    
//    private func phaseButton(label: String, phase: String) -> some View {
//        Button(action: {
//            shotViewModel.phaseOfGame = phase
//            if phase == ShotKeys.phases.penalty {
//                navigateToShotLocation = true
//            } else {
//                navigateToShooterPosition = true
//            }
//        }) {
//            Text(label)
//                .font(.title2)
//                .foregroundColor(.primary)
//                .padding(.vertical)
//                .cornerRadius(8)
//        }
//    }
//
//    // Implementing Hashable (required for NavigationPath)
//    static func == (lhs: SelectPhaseOfGame, rhs: SelectPhaseOfGame) -> Bool {
//        lhs.shotViewModel == rhs.shotViewModel &&
//        lhs.navigationPath == rhs.navigationPath
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(shotViewModel)
//        hasher.combine(navigationPath)
//    }
//}


struct SelectPhaseOfGame: View {
    @Binding var shotViewModel: ShotViewModel
    @Binding var navigationPath: [AnyHashable]
    
    var body: some View {
        Form {
            Section(header: Text("Phase Of Game")) {
                NavigationLink(
                    destination: SelectShooterPositionView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
                        .onAppear {
                            shotViewModel.phaseOfGame = ShotKeys.phases.frontCourtOffense
                        }
                ) {
                    Text(ShotKeys.dispPhases.frontCourtOffense)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                }
                //                .simultaneousGesture(TapGesture().onEnded {
                //                    shotViewModel.phaseOfGame = ShotKeys.phases.frontCourtOffense
                //                })
                
                NavigationLink(destination: SelectShooterPositionView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)) {
                    Text(ShotKeys.dispPhases.sixOnFive)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    shotViewModel.phaseOfGame = ShotKeys.phases.sixOnFive
                })
                
                NavigationLink(destination: SelectShooterPositionView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)) {
                    Text(ShotKeys.dispPhases.transitionOffense)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    shotViewModel.phaseOfGame = ShotKeys.phases.transitionOffense
                })
                
                NavigationLink(destination: SelectShotLocationView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)) {
                    Text(ShotKeys.dispPhases.penalty)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(.vertical)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    shotViewModel.phaseOfGame = ShotKeys.phases.penalty
                })
            }
            .onAppear {
                print(shotViewModel.shooter)
            }
        }
    }
}


//struct SelectShooterPositionView: View {
//    @Binding var shotViewModel: ShotViewModel
//    @Binding var navigationPath: [AnyHashable]
//    
//    @State var navigateToShotLocation = false
//   
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Position")) {
//                if shotViewModel.phaseOfGame == ShotKeys.phases.frontCourtOffense {
//                    positionButton(label: ShotKeys.dispFcoPositions.one, key: ShotKeys.fcoPositions.one)
//                    positionButton(label: ShotKeys.dispFcoPositions.two, key: ShotKeys.fcoPositions.two)
//                    positionButton(label: ShotKeys.dispFcoPositions.three, key: ShotKeys.fcoPositions.three)
//                    positionButton(label: ShotKeys.dispFcoPositions.four, key: ShotKeys.fcoPositions.four)
//                    positionButton(label: ShotKeys.dispFcoPositions.five, key: ShotKeys.fcoPositions.five)
//                    positionButton(label: ShotKeys.dispFcoPositions.center, key: ShotKeys.fcoPositions.center)
//                    positionButton(label: ShotKeys.dispFcoPositions.postUp, key: ShotKeys.fcoPositions.postUp)
//                    positionButton(label: ShotKeys.dispFcoPositions.drive, key: ShotKeys.fcoPositions.drive)
//
//                } else if shotViewModel.phaseOfGame == ShotKeys.phases.sixOnFive {
//                    positionButton(label: ShotKeys.sixOnFivePositions.one, key: ShotKeys.sixOnFivePositions.one)
//                    positionButton(label: ShotKeys.sixOnFivePositions.two, key: ShotKeys.sixOnFivePositions.two)
//                    positionButton(label: ShotKeys.sixOnFivePositions.three, key: ShotKeys.sixOnFivePositions.three)
//                    positionButton(label: ShotKeys.sixOnFivePositions.four, key: ShotKeys.sixOnFivePositions.four)
//                    positionButton(label: ShotKeys.sixOnFivePositions.five, key: ShotKeys.sixOnFivePositions.five)
//                    positionButton(label: ShotKeys.sixOnFivePositions.six, key: ShotKeys.sixOnFivePositions.six)
//
//                } else if shotViewModel.phaseOfGame == ShotKeys.phases.transitionOffense {
//                    positionButton(label: ShotKeys.dispTransitionOffensePositions.leftSide, key: ShotKeys.transitionOffensePositions.leftSide)
//                    positionButton(label: ShotKeys.dispTransitionOffensePositions.rightSide, key: ShotKeys.transitionOffensePositions.rightSide)
//                    positionButton(label: ShotKeys.dispTransitionOffensePositions.postUp, key: ShotKeys.transitionOffensePositions.postUp)
//                }
//            }
//        }
////        .navigationDestination(isPresented: $navigateToShotLocation) {
////            SelectShotLocationView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)
////        }
////        .navigationDestination(for: String.self) { view in
////            switch view {
////            case "shotLocation":
////                SelectShotLocationView(shotViewModel: $shotViewModel, path: $path)
////            default:
////                EmptyView()
////            }
////        }
//    }
//    
//    private func positionButton(label: String, key: String) -> some View {
//        Button(action: {
//            shotViewModel.shooterPosition = key
//            navigateToShotLocation = true
////            path.append("shotLocation")
//        }) {
//            Text(label)
//                .font(.title2)
//                .foregroundColor(.primary)
//                .padding(.vertical)
//                .cornerRadius(8)
//        }
//    }
//}

struct SelectShooterPositionView: View {
    @Binding var shotViewModel: ShotViewModel
    @Binding var navigationPath: [AnyHashable]
    
    var body: some View {
        Form {
            Section(header: Text("Position")) {
                if shotViewModel.phaseOfGame == ShotKeys.phases.frontCourtOffense {
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.one, key: ShotKeys.fcoPositions.one)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.two, key: ShotKeys.fcoPositions.two)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.three, key: ShotKeys.fcoPositions.three)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.four, key: ShotKeys.fcoPositions.four)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.five, key: ShotKeys.fcoPositions.five)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.center, key: ShotKeys.fcoPositions.center)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.postUp, key: ShotKeys.fcoPositions.postUp)
                    positionNavigationLink(label: ShotKeys.dispFcoPositions.drive, key: ShotKeys.fcoPositions.drive)
                } else if shotViewModel.phaseOfGame == ShotKeys.phases.sixOnFive {
                    positionNavigationLink(label: ShotKeys.sixOnFivePositions.one, key: ShotKeys.sixOnFivePositions.one)
                    positionNavigationLink(label: ShotKeys.sixOnFivePositions.two, key: ShotKeys.sixOnFivePositions.two)
                    positionNavigationLink(label: ShotKeys.sixOnFivePositions.three, key: ShotKeys.sixOnFivePositions.three)
                    positionNavigationLink(label: ShotKeys.sixOnFivePositions.four, key: ShotKeys.sixOnFivePositions.four)
                    positionNavigationLink(label: ShotKeys.sixOnFivePositions.five, key: ShotKeys.sixOnFivePositions.five)
                    positionNavigationLink(label: ShotKeys.sixOnFivePositions.six, key: ShotKeys.sixOnFivePositions.six)
                } else if shotViewModel.phaseOfGame == ShotKeys.phases.transitionOffense {
                    positionNavigationLink(label: ShotKeys.dispTransitionOffensePositions.leftSide, key: ShotKeys.transitionOffensePositions.leftSide)
                    positionNavigationLink(label: ShotKeys.dispTransitionOffensePositions.rightSide, key: ShotKeys.transitionOffensePositions.rightSide)
                    positionNavigationLink(label: ShotKeys.dispTransitionOffensePositions.postUp, key: ShotKeys.transitionOffensePositions.postUp)
                }
            }
        }
    }
    
    private func positionNavigationLink(label: String, key: String) -> some View {
        NavigationLink(destination: SelectShotLocationView(shotViewModel: $shotViewModel, navigationPath: $navigationPath)) {
            Text(label)
                .font(.title2)
                .foregroundColor(.primary)
                .padding(.vertical)
                .cornerRadius(8)
        }
        .simultaneousGesture(TapGesture().onEnded {
            shotViewModel.shooterPosition = key
        })
    }
}


struct SelectShotLocationView: View {
    @Binding var shotViewModel: ShotViewModel
    @Binding var navigationPath: [AnyHashable]
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
                let inTheGame = shotViewModel.offenseLineup.field + shotViewModel.offenseLineup.goalies + ["None"]
                let canAssist = inTheGame.filter { $0 != shotViewModel.shooter }
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
    @State private var isTimePickerPresented = false
    @State private var timeString = ""
    @Environment(\.presentationMode) var presentationMode
//    @State private var navigateToGameView = false
//    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            Form {
                Section(header: Text("")) {
                    Text("Shooter: ") + Text(shotViewModel.shooter).bold()
                    Text("Phase of Game: ") + Text(shotViewModel.phaseOfGame).bold()
                    if !shotViewModel.shooterPosition.isEmpty {
                        Text("Shooter Position: ") + Text(shotViewModel.shooterPosition).bold()
                    }
                    Text("Shot Location: ") + Text(ShotKeys.locationNumToValue[shotViewModel.shotLocation]!).bold()
                    if !shotViewModel.shotDetail.isEmpty {
                        Text("Shot Detail: ") + Text(ShotKeys.detailKeyToDisp[shotViewModel.shotDetail]!).bold()
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
                isTimePickerPresented = true
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
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(maxTime: maxQuarterMinutes, timeString: $timeString, onSubmit: {
                Task {
                    do {
                        // TODO: make a createShotStat() func in FirebaseManager
                        // TODO: pop the navigation stack all the way to SelectStatsView()
                        
                        // pop out of TimePickerView()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Failed to create lineup stat \(error)")
                    }
                }

            }, onCancel: {
                self.isTimePickerPresented = false
            })
        }
//        .navigationDestination(isPresented: $navigateToGameView) {
//            GameView(homeTeam: $shotViewModel.homeTeam.wrappedValue, 
//                     awayTeam: $shotViewModel.awayTeam.wrappedValue,
//                     gameCollectionName: $shotViewModel.gameCollectionName.wrappedValue
//            )
//            .environmentObject(FirebaseManager())
//        }
    }
}


struct ShotView_Preview: PreviewProvider {
    @State static private var navigationPath: [AnyHashable] = []
    static var previews: some View {
        NavigationStack(path: $navigationPath) {
            ShotView(
                gameCollectionName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA",
                homeInTheGame: stanfordInTheGame,
                awayInTheGame: uclaInTheGame,
                navigationPath: $navigationPath
            )
            .environmentObject(FirebaseManager())
        }
    }
}

//struct ShotViewSinglePage_Preview: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            ShotViewSinglePage(
//                gameCollectionName: "Stanford_vs_UCLA-2024-08-25_1724557371", quarter: 1, homeTeam: "Stanford", awayTeam: "UCLA", homeInTheGame: stanfordInTheGame, awayInTheGame: uclaInTheGame
//            )
//            .environmentObject(FirebaseManager())
//        }
//    }
//}

