//
//  AddPlayerView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/16/24.
//

import SwiftUI

/* Used as a sheet */
struct AddPlayerView: View {
    @Environment (\.presentationMode) var presentationMode
    @ObservedObject var lineup: LineupWithCapNumbers
    
    @State var player: [String: String] = [:]
    @State private var name: String = ""
    @State private var num: Int = 1
    @State private var notes: String = ""
    @State private var isField: Bool = true
    
    var body: some View {
        VStack {
            
            Form {
                Picker("Position", selection: $isField) {
                    Text("Field").tag(true)
                    Text("Goalie").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle()) // Style for tabs
                
                Section("Name") {
                    TextField("", text: $name)
                }
                .padding(.vertical, 0)
                

                Section("Number") {
                    Picker("", selection: $num) {
                        ForEach(1...99, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                }
                .padding(.vertical, 0)
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 180)
                        .lineLimit(nil)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("New Player")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if isField {
                        lineup.addFieldPlayer(name: name, num: num, notes: notes)
                    } else {
                        lineup.addGoalie(name: name, num: num, notes: notes)
                    }
                    presentationMode.wrappedValue.dismiss()
                    
                }
                .disabled(!canAddPlayer())
            }
        }
    }
    
    private func canAddPlayer() -> Bool {
        return !name.isEmpty
    }
    
}

struct AddPlayerView_Preview: PreviewProvider {
    @State static var lineup = LineupWithCapNumbers()
    static var previews: some View {
        NavigationStack {
            AddPlayerView(lineup: lineup)
        }
    }
}
