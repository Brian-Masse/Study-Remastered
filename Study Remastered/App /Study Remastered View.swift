//
//  Study Remastered View.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/14/22.
//

import Foundation
import SwiftUI

let card1ViewModel = CardViewModel(CardTextViewModel("this is one piece of tex"), CardTextViewModel("this is the back!") )
let card2ViewModel = CardViewModel(CardTextViewModel("front2"), CardTextViewModel("back2") )

let setViewModel = SetViewModel([ card1ViewModel, card2ViewModel ])

struct StudyRemasteredView: View {
    
    @EnvironmentObject var viewModel: StudyRemasteredViewModel

    var body: some View {
        
        ZStack {
            
//            CardView(card1ViewModel, displayType: .single  )
//                .environmentObject(viewModel)
        
//            SetView(viewModel: setViewModel)
            
            FullSetEditor( currentCardIndex: 0 )
                .environmentObject( setViewModel )
        
            
            
            
            Calculator(shouldDisplayText: false)
                .environmentObject( viewModel )
        }
        
    }
    
}
