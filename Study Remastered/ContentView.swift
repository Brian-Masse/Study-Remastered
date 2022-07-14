//
//  ContentView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import SwiftUI


let card1ViewModel = CardViewModel(CardTextViewModel("this is one piece of tex", in: 350), CardTextViewModel("this is the back!", in: 350) )

struct ContentView: View {
    
    static var calculator = Calculator(viewModel: CalculatorViewModel(CalculatorModel(EquationTextHandler(RichTextFieldViewModel("")))), shouldDisplayText: false)
    static var calculatorIsActive = false
    
    let texts = [ "hello", "world this is a super long text", "!", "hi", "hi!", "hi.", "car", "bus", "penis", "dick" ]
    
    var body: some View {
    
        ZStack {
            CardView( card1ViewModel )
//            .background(GeometryReader { _ in
//                TextureFill().ignoresSafeArea()
//            })

//        QuickSetEditorView(SetViewModel( [card1ViewModel] ))
            
            ContentView.calculator
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
    }
}


