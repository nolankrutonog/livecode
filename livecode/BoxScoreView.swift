//
//  BoxScoreView.swift
//  livecode
//
//  Created by Nolan Krutonog on 9/6/24.
//

import SwiftUI

struct BoxScoreView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        VStack {
            
        }
    }
}

struct BoxScoreView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BoxScoreView()
                .environmentObject(FirebaseManager())
        }
    }
}
