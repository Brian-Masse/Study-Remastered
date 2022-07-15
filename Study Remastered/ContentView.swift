//
//  ContentView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        StudyRemasteredView()
            .environmentObject(appViewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}


