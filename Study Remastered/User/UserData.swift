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
    
    @Persisted(primaryKey: true) var _id = "test"
    @Persisted var accessToken: String = ""
    
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    
    @Persisted var userName: String = ""
    @Persisted var email: String = ""
    
    var user: User!
    
    @Persisted var userData: Data!
    
    var fireBaseUser: FirebaseAuth.User? {
        get { Auth.auth().currentUser }
    }
    
    func load() {
        if let _  = userData {
            do { self.user = try JSONDecoder().decode(User.self, from: userData as Data) }
            catch { self.user = User(userData: self) }
        } else { self.user = User(userData: self) }
        user.setUser(with: self)
    }
    
    //this needs to do some of the work of init because Realm is silly
    func create(accessToken: String, _ firstName: String, _ lastName: String, _ email: String, _ userName: String) {
        self._id = accessToken
        self.accessToken = accessToken

        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userName = userName
        
        // you have already been added to the FireBase server (via the authetnication managaer)
        
        // add to the realm server
        self.save()
        
        // make sure that you have some user object attatched, if none was found in the realm DB
        self.load()
    }
    
    func save(withUpdateToUser encodeData: Bool = false) {
    
        if encodeData {
            do { try RealmManager.shared.realm.write { userData = try JSONEncoder().encode( user ) } }
            catch { print("error encoding User into NSData: \(error.localizedDescription)") }
        }
        
        RealmManager.shared.saveDataToRealm(self)
    }
    
    func delete() {
    
        if let user = self.fireBaseUser {
            
            //deletes from the FireBase server
        
            user.delete() { err in
                if err != nil { print( "There was an error deleting the user" ); return }
            }
            // deletes user from the Realm server (handled by Authentication Manager)
        }
    }
    
    //MARK: Convienience Functions:
    
    func getFormattedName() -> String { "\(firstName) \(String(lastName.first!))." }
}
