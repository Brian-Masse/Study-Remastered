//
//  AuthenticationModel.swift
//  Study - Remastered
//
//  Created by Brian Masse on 3/10/22.
//

import Foundation
import FirebaseAuth

struct AuthenticatorModel {
    
    var accessToken: String {
        get {
            
            guard let user = Auth.auth().currentUser else { return "" }
            return user.uid
        }
    }
    
    var isSignedin: Bool = false
    var activeUser: UserData = UserData()
    
}
