//
//  FlashCardsView.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import SwiftUI


struct FlashCardView: View {
    
    @EnvironmentObject var setViewModel: SetViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            
            HStack {
                NamedButton("Back", and: "chevron.backward", oriented: .vertical).onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                
                NamedButton( "options", and: "command", oriented: .vertical )
                
            }.padding()
            
            
            CardScroller(cards: setViewModel.cards, continuousScrolling: false, endFunction: {}) {
            } content: { index in
                CardView( setViewModel.cards[index] , displayType: .singlePresentation)
                    .padding()
            }
        }
        
    }
    
}
