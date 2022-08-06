//
//  File.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import RealmSwift
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


class CardViewModel: ObservableObject, Codable {

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
    
    //MARK: Serialization
    
    enum CodingKeys: String, CodingKey {
        case frontModel
        case backModel
    }
    
    func encode(to encoder: Encoder) throws {
        Utilities.shared.encodeData(frontTextViewModel, using: encoder, with: CodingKeys.frontModel)
        Utilities.shared.encodeData(backTextViewModel, using: encoder, with: CodingKeys.backModel)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        let frontModel: CardTextViewModel = Utilities.shared.decodeData(in: values, with: CodingKeys.frontModel)!
        let backModel:  CardTextViewModel = Utilities.shared.decodeData(in: values, with: CodingKeys.backModel)!
        
        model =  CardModel(frontModel, backModel)
    }
}






