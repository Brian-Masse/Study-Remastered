//
//  SetModel\.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI
import RealmSwift

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

class SetViewModel: ObservableObject, Codable, Equatable {
    
    @Published private (set) var model: SetModel
    private let id = UUID()
    
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
//        super.init()
        self.model.name = name
        self.model.description = description
    }
    
    init( model: SetModel ) {
        self.model = model
    }
    
    func addCard(with card: CardViewModel) {
        cards.append(card)
    }
    
    //MARK: Serialization
    
    enum CodingKeys: String, CodingKey {
        case cards
        case name
        case description
    }
    
    func encode(to encoder: Encoder) throws {
        Utilities.shared.encodeData(name, using: encoder, with: CodingKeys.name)
        Utilities.shared.encodeData(description, using: encoder, with: CodingKeys.description)
        Utilities.shared.encodeData(cards, using: encoder, with: CodingKeys.cards)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        model =  SetModel([])
        name =          Utilities.shared.decodeData(in: values, with: CodingKeys.name, defaultValue: "")!
        description =   Utilities.shared.decodeData(in: values, with: CodingKeys.description, defaultValue: "")!
        cards =         Utilities.shared.decodeData(in: values, with: CodingKeys.cards, defaultValue: [])!
    }
    
    //MARK: Utilities
    
    static func == (lhs: SetViewModel, rhs: SetViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
