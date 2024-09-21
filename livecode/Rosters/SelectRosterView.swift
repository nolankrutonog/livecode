//
//  SelectRosterView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import SwiftUI

struct SelectRosterView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var rosterNames: [String] = []
    
    var body: some View {
        Form {
            ForEach(rosterNames, id: \.self) { rosterName in
                NavigationLink(destination: DisplayRosterView(rosterName: rosterName).environmentObject(firebaseManager)) {
                    Text(rosterName)
                        .font(.title3)
                }
            }
        }
        .onAppear {
//            rosterNames = ["Stanford", "UCLA"]
//            TODO: uncomment when done testing
            Task {
                do {
                    rosterNames = try await firebaseManager.fetchRosterNames()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .navigationTitle("Select Roster")
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: NewRosterView().environmentObject(firebaseManager)) {
                    Text("New Roster")
                }
            }
        }
    }
}


struct SelectRosterView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectRosterView().environmentObject(FirebaseManager())
        }
    }
}

/*
 struct EditRostersView: View {
 @State private var rosters: [String] = []
 @State private var selectedRosterIdx: Int? = nil
 @State private var navigateToRosterDetail = false
 
 var body: some View {
 VStack {
 List {
 ForEach(rosters.indices, id: \.self) { index in
 NavigationLink(destination: RosterDetailView(rosterName: $rosters[index], onSave: saveRosters)) {
 Text(rosters[index])
 .font(.headline)
 }
 }
 .onDelete(perform: deleteRoster)
 }
 
 }
 .navigationTitle("Rosters")
 .navigationBarTitleDisplayMode(.inline)
 .onAppear(perform: loadRosters)
 .overlay(
 Button(action: addRoster) {
 Image(systemName: "plus")
 .resizable()
 .frame(width: 24, height: 24)
 .padding()
 .background(Color.blue)
 .foregroundColor(.white)
 .clipShape(Circle())
 .padding(.trailing)
 }
 .padding()
 .shadow(radius: 2),
 alignment: .bottomTrailing
 )
 
 }
 
 func addRoster() {
 let newRosterName = "New Roster"
 rosters.append(newRosterName)
 saveRosters()
 selectedRosterIdx = rosters.count - 1
 navigateToRosterDetail = true
 }
 
 func deleteRoster(at offsets: IndexSet) {
 rosters.remove(atOffsets: offsets)
 saveRosters()
 }
 
 func saveRosters() {
 UserDefaults.standard.set(rosters, forKey: userDefaultsRostersKey)
 }
 
 func loadRosters() {
 if let savedRosters = UserDefaults.standard.array(forKey: userDefaultsRostersKey) as? [String] {
 rosters = savedRosters
 }
 }
 }
 
 
 
 struct RosterDetailView: View {
 @Binding var rosterName: String
 @State private var editedName: String
 @State private var isEditing = false
 @State private var names: [String] = []
 @State private var newName: String = ""
 @Environment(\.presentationMode) var presentationMode
 var onSave: () -> Void
 
 init(rosterName: Binding<String>, onSave: @escaping () -> Void) {
 self._rosterName = rosterName
 self._editedName = State(initialValue: rosterName.wrappedValue)
 self.onSave = onSave
 }
 
 var body: some View {
 VStack {
 
 if isEditing {
 TextField("Roster Name", text: $editedName)
 .font(.largeTitle)
 .fontWeight(.bold)
 .textFieldStyle(RoundedBorderTextFieldStyle())
 .padding()
 } else {
 Text(rosterName)
 .font(.largeTitle)
 .fontWeight(.bold)
 .frame(maxWidth: .infinity, alignment: .leading)
 .padding()
 }
 
 List {
 ForEach(names, id: \.self) { name in
 Text(name)
 }
 .onDelete(perform: deleteName)
 
 HStack {
 TextField("Add new name", text: $newName)
 Button(action: addName) {
 Image(systemName: "plus.circle.fill")
 .foregroundColor(.blue)
 }
 }
 }
 }
 .navigationBarTitle("", displayMode: .inline)
 .navigationBarItems(trailing: editButton)
 .onAppear(perform: loadNames)
 }
 
 private var editButton: some View {
 HStack {
 if isEditing {
 Button("Cancel") {
 editedName = rosterName
 isEditing.toggle()
 }
 }
 Button(isEditing ? "Done" : "Edit Name") {
 if isEditing {
 rosterName = editedName
 saveNames()
 onSave()
 } else {
 editedName = rosterName
 }
 isEditing.toggle()
 }
 }
 }
 
 private func addName() {
 guard !newName.isEmpty else { return }
 names.append(newName)
 newName = ""
 saveNames()
 }
 
 private func deleteName(at offsets: IndexSet) {
 names.remove(atOffsets: offsets)
 saveNames()
 }
 
 private func saveNames() {
 UserDefaults.standard.set(names, forKey: "\(rosterName)_names")
 }
 
 private func loadNames() {
 if let savedNames = UserDefaults.standard.array(forKey: "\(rosterName)_names") as? [String] {
 names = savedNames
 }
 }
 }
 
 */
