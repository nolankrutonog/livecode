//
//  RosterDetailView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/22/24.
//

import SwiftUI

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

struct RosterDetailView_Preview: PreviewProvider {
    @State static var sampleRosterName = "Sample Roster"

    static var previews: some View {
        RosterDetailView(rosterName: $sampleRosterName) {
            print("Save action triggered")
        }
    }
}
