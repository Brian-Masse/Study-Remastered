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
    
    var body: some View {
    
        CardScroller(cards: setEditorViewModel.currentCards, continuousScrolling: true, endFunction: setEditorViewModel.addNewCard) {
            NamedButton("Add New Card", and: "plus.app", oriented: .horizontal)
        } content: { index in
            CardView(displayType: .single)
                .environmentObject(setEditorViewModel.currentCards[index])
                .padding(25)
        }

            
    }
}
