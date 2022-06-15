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
    
    
}

class SetViewModel: ObservableObject {
    
    @Published var model: SetModel
    
    init( _ model: SetModel ) {
        self.model = model
    }
    
    func createNewCard() -> CardViewModel {
        
        let newCardViewModel = CardViewModel(CardModel("term", "definition"))
        
//        model.cards.append(newCardViewModel)
        print("creating new card")
        return newCardViewModel
        
    }
    
}
