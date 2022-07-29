//
//  UserData.swift
//  Study - Remastered
//
//  Created by Brian Masse on 3/11/22.
//

import Foundation
import RealmSwift
import FirebaseAuth

class UserData: Object {
    
    //MARK: Authentication Properties
    @objc dynamic var accessToken: String = ""
    
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    
    @objc dynamic var email: String = ""
    
    var handler: AuthenticatorViewModel!
    
    var fireBaseUser: FirebaseAuth.User? {
        get { Auth.auth().currentUser }
    }
    
    //MARK: App Properties
    
    var sets: [ SetViewModel ] = [ setViewModel ]
    
    override static func primaryKey() -> String? {
        return "accessToken"
    }
    
    //this needs to do some of the work of init because Realm is silly
    func create(accessToken: String, _ firstName: String, _ lastName: String, _ email: String ) {
        self.accessToken = accessToken
        self.handler = authenticatorHandler

        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        
        // you have already been added to the FireBase server (via the authetnication managaer)
        
        // add to the realm server
        self.save()
    }
    
    func save() {
        util.saveToDataToRealm(self)
    }
    
    func delete() {
        
        if let user = self.fireBaseUser {
            
            //deletes from the FireBase server
        
            user.delete() { err in
                if err != nil { print( "There was an error deleting the user" ); return }
            }
            
            // deletes user from the Realm server
            
            util.removeDataFromRealm(key: accessToken)
        }
    }
    
    //MARK: Convienience Functions:
    
    func getFormattedName() -> String { "\(firstName) \(String(lastName.first!))." }
}
