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
    
    let uuid: UUID = UUID()
    
    var frontTextViewModel: CardTextViewModel
    var backTextViewModel: CardTextViewModel
    
    init( _ frontTextViewModel: CardTextViewModel, _ backTextViewModel: CardTextViewModel ) {
        self.frontTextViewModel = frontTextViewModel
        self.backTextViewModel = backTextViewModel
    }   
}


class CardViewModel: ObservableObject {

    @Published var model: CardModel
    
    var frontTextViewModel: CardTextViewModel {
        get { model.frontTextViewModel }
        set { model.frontTextViewModel = newValue }
    }
    var backTextViewModel: CardTextViewModel {
        get { model.backTextViewModel }
        set { model.backTextViewModel = newValue }
    }
    
    init( _ frontTextViewModel: CardTextViewModel, _ backTextViewModel: CardTextViewModel) {
        self.model = CardModel(frontTextViewModel, backTextViewModel)
    }
    
    //MARK: Editing
    
    func beginEditing() {
        frontTextViewModel.beginEditing()
        backTextViewModel.beginEditing()
    }
    
    func endEditing() {
        frontTextViewModel.endEditing()
        backTextViewModel.endEditing()
    }
    
    
    func copy(in width: CGFloat? = nil) -> CardViewModel { CardViewModel(frontTextViewModel.copy(with: width), backTextViewModel.copy(with: width)) }
}






