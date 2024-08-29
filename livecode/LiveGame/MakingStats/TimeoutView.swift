//
//  TimeoutView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/26/24.
//

import SwiftUI


struct TimeoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let gameDocumentName: String
    let quarter: Int
    let homeTeam: String
    let awayTeam: String
    
    @State private var timeString: String = ""
    @State private var selectedTeam: String = ""
    @State private var isTimePickerPresented = false
    
    init(gameDocumentName: String, quarter: Int, homeTeam: String, awayTeam: String) {
        self.gameDocumentName = gameDocumentName
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
                .pickerStyle(SegmentedPickerStyle())
                .font(.title2)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Timeout")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
//                    presentationMode.wrappedValue.dismiss()
                    isTimePickerPresented = true
                }
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
                                gameDocumentName: gameDocumentName,
                                quarter: quarter,
                                timeString: timeString,
                                selectedTeam: selectedTeam
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
}

struct TimeoutView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimeoutView(
                gameDocumentName: "Stanford_vs_UCLA_2024-08-25_1724557371",
                quarter: 1,
                homeTeam: "Stanford",
                awayTeam: "UCLA"
            )
                .environmentObject(FirebaseManager())
        }
    }
}

