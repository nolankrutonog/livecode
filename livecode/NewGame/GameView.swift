//
//  GameView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/18/24.
//

import SwiftUI


struct GameView: View {
    let homeTeam: String
    let awayTeam: String
    let gameName: String
    let quarterLength: Int
    
    @State private var currentQuarter = 1
    @State private var timeRemaining: TimeInterval
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    @State private var showLineups = false
    @State private var showNewStat = false
    
    @State private var homeLineup: [String: Any] = ["goalie": "", "field": ["","","","","",""]]
    @State private var awayLineup: [String: Any] = ["goalie": "", "field": ["","","","","",""]]
    
    init(homeTeam: String, awayTeam: String, gameName: String, quarterLength: Int) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.gameName = gameName
        self.quarterLength = quarterLength
        _timeRemaining = State(initialValue: TimeInterval(quarterLength * 60))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Quarter: \(currentQuarter)")
                    .font(.title3)
                
                Spacer()
                
                Stepper("", value: $currentQuarter, in: 1...99)
                    .labelsHidden()
                
                Button(action: resetTimer) {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(isTimerRunning ? .gray : .blue)
                }
                .disabled(isTimerRunning)
            }
            .padding(.horizontal)
            
            Text(timeString(from: timeRemaining))
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            
            Button(action: toggleTimer) {
                Text(isTimerRunning ? "Stop" : "Start")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isTimerRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                if !isTimerRunning {
                    showLineups = true
                }
            }) {
                Text("Lineups")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(isTimerRunning ? .gray : .primary)
                    .cornerRadius(10)
            }
            .disabled(isTimerRunning)
            .padding(.horizontal)
            
            
            HStack(spacing: 10) {
                Button(action: { showNewStat = true }) {
                    Text("Stat")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
            }
            .padding(.horizontal)
            Spacer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showLineups) {
            LineupsView(homeTeam: homeTeam, awayTeam: awayTeam, homeLineup: $homeLineup, awayLineup: $awayLineup)
        }
        .sheet(isPresented: $showNewStat) {
            StatsView(teamName: homeTeam)
        }
    }
    
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isTimerRunning = false
                }
            }
        }
        isTimerRunning.toggle()
    }
    
    private func resetTimer() {
        if !isTimerRunning {
            timeRemaining = TimeInterval(quarterLength * 60)
        }
    }
}


struct StatsView: View {
    let teamName: String
    
    var body: some View {
        Text("Stats for \(teamName)")
    }
}

#Preview {
    GameView(homeTeam: "Stanford 2024", awayTeam: "USC 2024", gameName: "Stanford 2024 vs. USC 2024 8/18/2024", quarterLength: 8)
}
