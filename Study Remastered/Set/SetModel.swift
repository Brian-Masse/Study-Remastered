//
//  SetModel\.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI


struct SetModel {
    
    static let nameCharachterLimit = 50
    static let descriptionCharachterLimit = 500
    
    var cards: [ CardViewModel ] = []
    
    init( _ cards: [CardViewModel] ) {
        self.cards = cards
    }
    
    var name: String = "New Set"
    var description: String = ""
}

class SetViewModel: ObservableObject {
    
    @Published private (set) var model: SetModel
    
    lazy var editorViewModel: SetEditorViewModel = SetEditorViewModel( self, in: globalFrame.width * 0.45)
    
    var name: String {
        get { model.name }
        set { model.name = newValue }
    }
    
    var description: String {
        get { model.description }
        set { model.description = newValue }
    }
    
    var cards: [ CardViewModel ] {
        get { model.cards }
        set { model.cards = newValue }
    }
    
    init( _ cards: [ CardViewModel ] ) {
        let model = SetModel(cards)
        self.model = model
    }
    
    init( _ cards: [ CardViewModel ], name: String, description: String ) {
        let model = SetModel(cards)
        self.model = model
        self.model.name = name
        self.model.description = description
    }
    
    init( model: SetModel ) {
        self.model = model
    }
    
    func addCard(with card: CardViewModel) {
        cards.append(card)
    }
}
