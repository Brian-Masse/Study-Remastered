//
//  SetModel\.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI


struct SetModel {
    
    var cards: [ CardViewModel ] = []
    
    init( _ cards: [CardViewModel] ) {
        self.cards = cards
    }
}

class SetViewModel: ObservableObject {
    
    @Published var model: SetModel
    
    var quickSetEditorViewModel: QuickSetEditorViewModel = QuickSetEditorViewModel()
    
    var cards: [ CardViewModel ] {
        get { model.cards }
        set { model.cards = newValue }
    }
    
    init( _ cards: [ CardViewModel ] ) {
        let model = SetModel(cards)
        self.model = model 
        self.quickSetEditorViewModel = QuickSetEditorViewModel( self, in: globalFrame.width * 0.45)
    }
    
    func addCard(with card: CardViewModel) {
        cards.append(card)
    }
}
