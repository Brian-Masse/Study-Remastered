//
//  File.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI


struct CardModel {
    
    enum MatchType {
        
        case perfect
        case assumedCorrect
        case incorrect
        
    }
    
    let frontContent: String
    let backContent: String
    
    init( _ frontContent: String, _ backContent: String ) {
        
        self.frontContent = frontContent
        self.backContent = backContent
    }
    
    
}


class CardViewModel: ObservableObject {

    @Published var model: CardModel
    
    init( _ model: CardModel) {
        self.model = model
    }
    
    var frontContent: String { model.frontContent }
    var backContent: String { model.backContent }
    
    
    func checkMatch() {
        
    
        
//        if frontContent == backContent {  }
        
        
    }
    
}





