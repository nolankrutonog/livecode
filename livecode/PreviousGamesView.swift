//
//  PreviousGamesView.swift
//  livecode
//
//  Created by Nolan Krutonog on 8/17/24.
//

import SwiftUI

struct PreviousGamesView: View {
    var body: some View {
        VStack {
            Text("Previous Games")
                .font(.largeTitle)
                .padding()

            // Add your UI elements for displaying previous games here
            // For example, a list of past games
            
            Spacer()
        }
        .navigationTitle("Previous Games")
        .padding()
    }
}

struct PreviousGamesView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousGamesView()
    }
}
