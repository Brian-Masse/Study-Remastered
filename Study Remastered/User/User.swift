//
//  User.swift
//  
//
//  Created by Brian Masse on 8/1/22.
//

import Foundation
import SwiftUI

class User: ObservableObject, Codable {
    

    private var userData: UserData!
    
    @Published var sets: [ SetViewModel ] = [ setViewModel ]
    
    var firstName: String { userData.firstName }
    var lastName: String { userData.lastName }
    var userName: String { userData.userName }
    
    var email: String { userData.email }
    
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
    
    func deleteSet(with setViewModel: SetViewModel) {
        
        guard let index = sets.firstIndex(where: { passedModel in
            return passedModel == setViewModel
            
        }) else { return }
        sets.remove(at: index)
        
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
    
    //MARK: Convinience
    
    func save(withUpdateToUser: Bool = false) {
        userData.save(withUpdateToUser: withUpdateToUser)
    }
    
    func setUser(with user: UserData) {
        self.userData = user
    }
    
    func updateCredentials(firstName: String, lastName: String, userName: String, email: String) {
        userData.updateCredentials(firstName: firstName, lastName: lastName, userName: userName, email: email)
    }
}
