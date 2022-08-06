//
//  User.swift
//  
//
//  Created by Brian Masse on 8/1/22.
//

import Foundation
import SwiftUI

class User: ObservableObject, Codable {
    

    var userData: UserData!
    
    var sets: [ SetViewModel ] = [ setViewModel ]
    
    init( userData: UserData ) {
        self.userData = userData
    }
    
    func getFormattedName() -> String { userData.getFormattedName() }
    
    //MARK: Sets
    func addNewSet() {
        let newCardViewModel = CardViewModel(CardTextViewModel("Click Here to Edit Text :)"), CardTextViewModel("Click Here to Edit the Back Text :0"))
        let number = sets.count + 1
        let newName = "New Set \(number)"
        let newSet = SetViewModel([ newCardViewModel ], name: newName, description: "")
        sets.append(newSet)
    }
    
    //MARK: Serialization
    
    enum CodingKeys: String, CodingKey {
        case sets
    }
    
    func encode(to encoder: Encoder) throws {
        Utilities.shared.encodeData(sets, using: encoder, with: CodingKeys.sets)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        sets = Utilities.shared.decodeData(in: values, with: CodingKeys.sets, defaultValue: [ setViewModel ])!
    }
}
