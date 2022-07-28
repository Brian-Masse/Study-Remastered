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
    
    lazy var editorViewModel: SetEditorViewModel = SetEditorViewModel( self, in: globalFrame.width * 0.45)
    
    var cards: [ CardViewModel ] {
        get { model.cards }
        set { model.cards = newValue }
    }
    
    init( _ cards: [ CardViewModel ] ) {
        let model = SetModel(cards)
        self.model = model
    }
    
    func addCard(with card: CardViewModel) {
        cards.append(card)
    }
}
