//
//  TimePickerView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/24/24.
//

import SwiftUI

struct TimePickerView: View {
    let maxTime: Int // Maximum time in minutes
    @Binding var isPresented: Bool
    @Binding var timeString: String
    @State private var errorMessage: String?
    @State private var showSubmitButton: Bool = false
    @FocusState private var isFocused: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Enter Time")
                .font(.title)
                .bold()
            
            HStack(spacing: 5) {
                TextField("", text: $timeString)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .onChange(of: timeString) { _, newValue in
                        validateAndFormatInput(newValue)
                    }
            }
            .font(.largeTitle)
            .frame(width: 150)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage != nil ? Color.red : Color.gray, lineWidth: 2)
            )
            .background(
                errorMessage != nil ?
                    RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.1)) :
                    nil
            )
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            if showSubmitButton {
                Button("Submit") {
                    // Handle submission here
                    isPresented = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isFocused = true
            disableSwipeToDismiss()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func validateAndFormatInput(_ input: String) {
        let numbers = input.filter { $0.isNumber }
        var validatedNumbers = ""
        
        for (index, char) in numbers.enumerated() {
            if index == 0 {
                if let digit = Int(String(char)), digit <= maxTime {
                    validatedNumbers.append(char)
                }
            } else if index == 1 {
                if let firstDigit = Int(String(validatedNumbers.first!)),
                   let secondDigit = Int(String(char)) {
                    if firstDigit == maxTime {
                        if secondDigit == 0 {
                            validatedNumbers.append(char)
                        }
                    } else if secondDigit <= 5 {
                        validatedNumbers.append(char)
                    }
                }
            } else if index == 2 {
                if let firstDigit = Int(String(validatedNumbers.first!)),
                   let lastTwoDigits = Int(validatedNumbers.dropFirst() + String(char)) {
                    if firstDigit == maxTime {
                        if lastTwoDigits == 0 {
                            validatedNumbers.append(char)
                        }
                    } else if lastTwoDigits <= 59 {
                        validatedNumbers.append(char)
                    }
                }
            }
            
            if validatedNumbers.count == 3 {
                break
            }
        }
        
        timeString = formatTimeString(validatedNumbers)
        validateTime(validatedNumbers)
    }
    
    private func formatTimeString(_ numbers: String) -> String {
        if numbers.count > 1 {
            return numbers.prefix(1) + ":" + numbers.dropFirst()
        }
        return numbers
    }
    
    private func validateTime(_ numbers: String) {
        guard numbers.count == 3 else {
            errorMessage = nil
            showSubmitButton = false
            return
        }
        
        let minutes = Int(numbers.prefix(1)) ?? 0
        let seconds = Int(numbers.suffix(2)) ?? 0
        
        if minutes == maxTime && seconds == 0 {
            errorMessage = nil
            showSubmitButton = true
        } else if minutes < maxTime {
            errorMessage = nil
            showSubmitButton = true
        } else {
            errorMessage = "Maximum time: \(maxTime) minute\(maxTime > 1 ? "s" : "")"
            showSubmitButton = false
        }
    }
    
    private func disableSwipeToDismiss() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let viewController = window.rootViewController?.presentedViewController else {
            return
        }
        viewController.isModalInPresentation = true
    }
}

//struct TimePickerView: View {
//    let maxTime: Int // Maximum time in minutes
//    @Binding var timeString: String
//    let onSubmit: () -> Void
//    let onCancel: () -> Void
//    
//    @State private var errorMessage: String?
//    @State private var showSubmitButton: Bool = false
//    @FocusState private var isFocused: Bool
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            
//            Text("Enter Time")
//                .font(.title)
//                .bold()
//            
//            HStack(spacing: 5) {
//                TextField("", text: $timeString)
//                    .keyboardType(.numberPad)
//                    .multilineTextAlignment(.center)
//                    .focused($isFocused)
//                    .onChange(of: timeString) { _, newValue in
//                        validateAndFormatInput(newValue)
//                    }
//            }
//            .font(.largeTitle)
//            .frame(width: 150)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(errorMessage != nil ? Color.red : Color.gray, lineWidth: 2)
//            )
//            .background(
//                errorMessage != nil ?
//                    RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.1)) :
//                    nil
//            )
//            
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//            }
//            
//            Spacer()
//            
//            if showSubmitButton {
//                Button("Submit") {
//                    onSubmit()
//                    presentationMode.wrappedValue.dismiss()
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onAppear {
//            isFocused = true
//            disableSwipeToDismiss()
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button("Cancel") {
//                    onCancel()
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//        }
//    }
//    
//    private func validateAndFormatInput(_ input: String) {
//        let numbers = input.filter { $0.isNumber }
//        var validatedNumbers = ""
//        
//        for (index, char) in numbers.enumerated() {
//            if index == 0 {
//                if let digit = Int(String(char)), digit <= maxTime {
//                    validatedNumbers.append(char)
//                }
//            } else if index == 1 {
//                if let firstDigit = Int(String(validatedNumbers.first!)),
//                   let secondDigit = Int(String(char)) {
//                    if firstDigit == maxTime {
//                        if secondDigit == 0 {
//                            validatedNumbers.append(char)
//                        }
//                    } else if secondDigit <= 5 {
//                        validatedNumbers.append(char)
//                    }
//                }
//            } else if index == 2 {
//                if let firstDigit = Int(String(validatedNumbers.first!)),
//                   let lastTwoDigits = Int(validatedNumbers.dropFirst() + String(char)) {
//                    if firstDigit == maxTime {
//                        if lastTwoDigits == 0 {
//                            validatedNumbers.append(char)
//                        }
//                    } else if lastTwoDigits <= 59 {
//                        validatedNumbers.append(char)
//                    }
//                }
//            }
//            
//            if validatedNumbers.count == 3 {
//                break
//            }
//        }
//        
//        timeString = formatTimeString(validatedNumbers)
//        validateTime(validatedNumbers)
//    }
//    
//    private func formatTimeString(_ numbers: String) -> String {
//        if numbers.count > 1 {
//            return numbers.prefix(1) + ":" + numbers.dropFirst()
//        }
//        return numbers
//    }
//    
//    private func validateTime(_ numbers: String) {
//        guard numbers.count == 3 else {
//            errorMessage = nil
//            showSubmitButton = false
//            return
//        }
//        
//        let minutes = Int(numbers.prefix(1)) ?? 0
//        let seconds = Int(numbers.suffix(2)) ?? 0
//        
//        if minutes == maxTime && seconds == 0 {
//            errorMessage = nil
//            showSubmitButton = true
//        } else if minutes < maxTime {
//            errorMessage = nil
//            showSubmitButton = true
//        } else {
//            errorMessage = "Maximum time: \(maxTime) minute\(maxTime > 1 ? "s" : "")"
//            showSubmitButton = false
//        }
//    }
//    
//    private func disableSwipeToDismiss() {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let viewController = window.rootViewController?.presentedViewController else {
//            return
//        }
//        viewController.isModalInPresentation = true
//    }
//}

struct TimePickerView_Preview: PreviewProvider {
    @State static var isPresented = true
    @State static var timeString: String = ""
    static var previews: some View {
        TimePickerView(maxTime: 8, isPresented: $isPresented, timeString: $timeString)
            .environmentObject(FirebaseManager())
    }
}
