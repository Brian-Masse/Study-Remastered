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
    
    var cards: [ CardViewModel ] {
        get { model.cards }
        set { model.cards = newValue }
    }
    
    init( _ cards: [ CardViewModel ] ) {
        self.model = SetModel(cards)
    }    
}
