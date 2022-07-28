//
//  AuthetnicatorManager.swift
//  Study - Remastered
//
//  Created by Brian Masse on 3/10/22.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth


let authenticatorHandler = AuthenticatorViewModel()

class AuthenticatorViewModel: ObservableObject {
    
    @Published private(set) var authenticatorModel = AuthenticatorModel()
    
    var email = ""
    var password = ""
    
    var firstName = ""
    var lastName = ""
    var userName = ""
    
    var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        
        FirebaseApp.configure()
        
        handler = Auth.auth().addStateDidChangeListener() { auth, user in
            if let usr = user {
                self.changeActiveUser(token: usr.uid)
                self.authenticatorModel.isSignedin = true
            } else {
                self.authenticatorModel.isSignedin = false
            }
        }
    }
    
    func validateEmail( _ email: String ) -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}")
        return emailTest.evaluate(with: email)
    }
    
    func validateFields() -> String? {
        if self.email == "" || self.email == "" { return "Please Fill in All Fields" }
        if !validateEmail( self.email ) {  return "Please Enter a valid email" }
    
        return nil
    }
    
    func cleanFields( _ email: String, _ password: String ) -> String?  {
        self.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        self.password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let validation = validateFields()
        if validation != nil { return  "ERROR WITH FIELDS: \( validation! )" }
        return nil
    }
    
    
    func login(_ email: String, _ password: String) {
        
        let result = cleanFields(email, password)
        if result != nil { print( result! ); return }
        
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, err in
            if err != nil {
                print( "ERROR SIGNING IN: \( err!.localizedDescription )" )
                return
                
            }
        }

    }
    
    func signup(_ email: String, _ password: String, _ firstName: String, _ lastName: String, _ userName: String) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        
        let result = cleanFields(email, password)
        if result != nil { print( result! ); return }
        
        Auth.auth().createUser(withEmail: self.email, password: self.password) { result, err in
            
            if err != nil { print(" ERROR CREATING USER: \(err!.localizedDescription)"); return }
                                  
            if let content = result {
//                THIS SHOULD BE THE TOKEN, but that requires some formatting / reading what a token even us
                let token = content.user.uid
                
                let user = UserData()
                user.create(accessToken: token , self.firstName, self.lastName, self.userName)
            }
        }
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete() {
        signout()
        self.authenticatorModel.activeUser.delete()
    }
    
    func changeActiveUser(token: String) {
//        authenticatorModel.setToken( token )
        if let user = util.locateDataInRealm(key: authenticatorModel.accessToken) {
            authenticatorModel.activeUser = user
        }
    }
}
