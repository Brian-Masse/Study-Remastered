//
//  FullSetEditor.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/15/22.
//

import Foundation
import SwiftUI

struct FullSetEditor: View {

    @EnvironmentObject var setEditorViewModel: SetEditorViewModel
    
    @State var currentCardIndex: Int = 0
    
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
            ZStack {
                CardView(setEditorViewModel.currentCards[currentCardIndex], displayType: .single)
                    .environmentObject(appViewModel)
                    .padding()
                
                VStack {
                    Spacer()
                    if currentCardIndex + 1 < setEditorViewModel.currentCards.count {
                        CardView(setEditorViewModel.currentCards[currentCardIndex + 1], displayType: .single)
                            .environmentObject(appViewModel)
                            .padding()
                            .offset(y: globalFrame.height * (7/10))
                    }else {
                        HStack {
                            Text("Add New Card")
                            Image(systemName: "plus.app")
                        }
                    }
                }
                
            }
        }.gesture(swipe)
    }
    
    private func changeActiveCard(with direction: Bool) {
        if direction {
            if currentCardIndex == setEditorViewModel.currentCards.count - 1 { setEditorViewModel.addNewCard() }
            currentCardIndex = currentCardIndex + 1
            
        }
        else { currentCardIndex = max( currentCardIndex - 1, 0 ) }
    }
}
