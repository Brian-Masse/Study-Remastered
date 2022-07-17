//
//  FullSetEditor.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/15/22.
//

import Foundation
import SwiftUI

struct FullSetEditor: View {

    @EnvironmentObject var setViewModel: SetViewModel
    
    @State var currentCardIndex: Int
    
    static let horizontalTolerance: CGFloat = 20
    static let verticalTolerance: CGFloat = 5
    
    var body: some View {

        let swipe = DragGesture()
            .onEnded { gesture in
                
                if abs(gesture.location.x - gesture.startLocation.x) < FullSetEditor.horizontalTolerance {
                    if abs(gesture.location.y - gesture.startLocation.y) > FullSetEditor.verticalTolerance {
                        if (gesture.location.y - gesture.startLocation.y) < 0   { changeActiveCard(with: true) }
                        else                                                    { changeActiveCard(with: false) }
                    }
                }
            }

        VStack {
            HStack {
                Image(systemName: "plus.app").onTapGesture { currentCardIndex = min( currentCardIndex + 1, setViewModel.cards.count - 1) }
                Image(systemName: "minus.square").onTapGesture { currentCardIndex = max( currentCardIndex - 1, 0 ) }
            }
            
            CardView(setViewModel.cards[currentCardIndex], displayType: .single)
                .environmentObject(appViewModel)
            
//            CardUpdater( displayIndex: currentCardIndex )
//                .environmentObject(setViewModel)
            
            if currentCardIndex + 1 < setViewModel.cards.count {
//                CardUpdater(displayIndex: currentCardIndex + 1)
//                    .environmentObject(setViewModel)
                
                CardView(setViewModel.cards[currentCardIndex + 1], displayType: .single)
                    .environmentObject(appViewModel)
            }
        }.gesture(swipe)
    }
    
    private func changeActiveCard(with direction: Bool) {
//        withAnimation( .easeOut(duration: 1) ) {
            if direction { currentCardIndex = min( currentCardIndex + 1, setViewModel.cards.count - 1) }
            else { currentCardIndex = max( currentCardIndex - 1, 0 ) }
//        }
    }
    
    struct CardUpdater: View {
        
        @EnvironmentObject var setViewModel: SetViewModel
        
        let displayIndex: Int
        
        var body: some View {
            if displayIndex % 2 == 0 { createCardView(with: displayIndex) }
            else                         { createCardView(with: displayIndex) }
        }
        
        private func createCardView(with index: Int) -> some View {
            return CardView( setViewModel.cards[index] , displayType: .single)
//                .transition(.opacity)
                .environmentObject(appViewModel)
                .padding()
        }
    }
}
