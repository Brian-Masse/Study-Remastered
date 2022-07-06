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
    
    let texts = [ "hello", "world this is a super long text", "!", "hi", "hi!", "hi.", "car", "bus", "penis", "dick" ]
    
    var body: some View {
    
        CardView( card1ViewModel )
//        GeometryReader { geo in
//            WrappedHStack(texts.count, in: geo) { i in
//                Text(texts[i])
//                    .background(Rectangle().foregroundColor(.green))
//            }
//        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}


