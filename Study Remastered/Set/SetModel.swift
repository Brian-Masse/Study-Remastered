//
//  SetModel\.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI


class SetViewModel: ObservableObject, Identifiable, Codable, WrappedRealmObject {

    static let nameCharachterLimit = 50
    static let descriptionCharachterLimit = 500
    
    var id: String = ""
    var owner: String = ""
    
    @Published var cards: [ CardViewModel ] = []

    @Published var name: String = "New Set"
    @Published var description: String = ""
    
    lazy var editorViewModel: SetEditorViewModel = SetEditorViewModel( self, in: globalFrame.width * 0.45)
    
    init( _ cards: [ CardViewModel ] ) {
        self.cards = cards
        
        self.setOwnership(AuthenticatorViewModel.shared.accessToken, UUID().uuidString )
    }
    
    init( _ cards: [ CardViewModel ], name: String, description: String ) {
        self.cards = cards
        self.name = name
        self.description = description
        
        self.setOwnership(AuthenticatorViewModel.shared.accessToken, UUID().uuidString )
    }
    
    func setOwnership(_ owner: String, _ id: String) {
        self.owner = owner
        self.id = id
    }
    
    func addCard(with card: CardViewModel) {
        cards.append(card)
    }
    
    //MARK: Serialization
    
    func save() {
        let _ = RealmObjectWrapper(self, type: RealmObjectWrapperKeys.setViewModelKey)
    }
    
//    func decodeCards() {
//
//        do { cards = try JSONDecoder().decode( [ CardViewModel ].self, from: self.cardData) }
//        catch { print( "error decoding cards for set: \(name): \( error.localizedDescription )" ) }
//
//    }
    
    
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

        name =          Utilities.shared.decodeData(in: values, with: CodingKeys.name, defaultValue: "")!
        description =   Utilities.shared.decodeData(in: values, with: CodingKeys.description, defaultValue: "")!
        cards =         Utilities.shared.decodeData(in: values, with: CodingKeys.cards, defaultValue: [])!
    }
//
    //MARK: Utilities
    
    static func == (lhs: SetViewModel, rhs: SetViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
