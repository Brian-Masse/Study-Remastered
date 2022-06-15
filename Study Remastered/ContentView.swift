//
//  ContentView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import SwiftUI


let setViewModel = SetViewModel(SetModel())

struct ContentView: View {
    var body: some View {
        
        SetView(viewModel: setViewModel)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
