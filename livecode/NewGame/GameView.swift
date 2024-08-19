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
    @State private var showHomeStats = false
    @State private var showAwayStats = false
    
    @State private var homeLineup: [String] = Array(repeating: "", count: 7)
    @State private var awayLineup: [String] = Array(repeating: "", count: 7)
    
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
                
                Stepper("", value: $currentQuarter, in: 1...99)
                    .labelsHidden()
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
                Button(action: { showHomeStats = true }) {
                    Text(homeTeam)
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 5)
                }
                
                Button(action: { showAwayStats = true }) {
                    Text(awayTeam)
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.red.opacity(0.5), radius: 5, x: 0, y: 5)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .navigationBarHidden(true)
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showLineups) {
            LineupsView(homeTeam: homeTeam, awayTeam: awayTeam)
        }
        .sheet(isPresented: $showHomeStats) {
            StatsView(teamName: homeTeam)
        }
        .sheet(isPresented: $showAwayStats) {
            StatsView(teamName: awayTeam)
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
