//
//  ContentView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import SwiftUI


let setViewModel = SetViewModel(SetModel())



let card1ViewModel = CardViewModel(CardModel("FRONT", "BACK"), CardTextViewModel("this is one piece of tex") )

struct ContentView: View {
    var body: some View {
    
        CardView( card1ViewModel )

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
