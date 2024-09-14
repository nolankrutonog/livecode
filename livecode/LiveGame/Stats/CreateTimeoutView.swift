//
//  CreateTimeoutView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/26/24.
//

import SwiftUI


struct CreateTimeoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameCollectionName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    
    @State private var timeString: String = ""
    @State private var selectedTeam: String = ""
    @State private var timeoutType: String = ""
    @State private var isTimePickerPresented = false
    
    init(gameCollectionName: String, quarter: Int, homeTeam: String, awayTeam: String) {
        self.gameCollectionName = gameCollectionName
        self.quarter = quarter
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        _selectedTeam = State(initialValue: homeTeam)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Taken By")) {
                Picker("Team", selection: $selectedTeam) {
                    Text(homeTeam).tag(homeTeam)
                    Text(awayTeam).tag(awayTeam)
                }
//                .pickerStyle(SegmentedPickerStyle())
                .font(.title2)
                .padding(.vertical, 10)
                
                Picker("Type", selection: $timeoutType) {
                    Text("").tag("")
                    Text("Full").tag(TimeoutKeys.full)
                    Text("Half").tag(TimeoutKeys.half)
                }
                .font(.title2)
                .padding(.vertical)
            }
        }
        .navigationTitle("Timeout")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
//                    presentationMode.wrappedValue.dismiss()
                    isTimePickerPresented = true
                }
                .disabled(!canSubmit())
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isTimePickerPresented) {
            TimePickerView(
                maxTime: maxQuarterMinutes,
                timeString: $timeString,
                onSubmit: {
                    Task {
                        do {
                            try await firebaseManager.createTimeoutStat(
                                gameCollectionName: gameCollectionName,
                                quarter: quarter,
                                timeString: timeString,
                                selectedTeam: selectedTeam,
                                timeoutType: timeoutType
                            )
                        } catch {
                            print("Failed to create timout stat: \(error)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()

                }, onCancel: {
                    self.isTimePickerPresented = false
                })
        }
    }
    
    private func canSubmit() -> Bool {
        return !selectedTeam.isEmpty && !timeoutType.isEmpty
    }
}

struct TimeoutView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateTimeoutView(
                gameCollectionName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA"
            )
                .environmentObject(FirebaseManager())
        }
    }
}

