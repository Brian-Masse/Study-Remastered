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

class AuthenticatorViewModel: ObservableObject {
    
//    @Published private(set) var authenticatorModel = AuthenticatorModel()
    
    var email = ""
    var password = ""
    var firstName = ""
    var lastName = ""
    var userName = ""
    
    var handler: AuthStateDidChangeListenerHandle?
    
    var accessToken: String {
        get {
            guard let user = Auth.auth().currentUser else { return "" }
            return user.uid
        }
    }
    
    @Published var isSignedin: Bool = false
    @Published var activeUser: UserData = UserData()
    @Published var userLoaded: Bool = false // comes shortly after sign in, to ensure it has a valid User attatched to it
    
    static let shared = AuthenticatorViewModel()
    
    func setupFireBaseHandler() {
        FirebaseApp.configure()
        
//        signout()
        handler = Auth.auth().addStateDidChangeListener() { auth, user in
            
            if let _ = user {
                self.changeActiveUser()
            } else {
                self.isSignedin = false
                self.userLoaded = false
            }
        }
    }
    
    private func validateEmail( _ email: String ) -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}")
        return emailTest.evaluate(with: email)
    }
    
    private func validateFields() -> String? {
        if self.email == "" || self.email == "" { return "Please Fill in All Fields" }
        if !validateEmail( self.email ) {  return "Please Enter a valid email" }
    
        return nil
    }
    
    private func cleanFields( _ email: String, _ password: String ) -> String?  {
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
                Task.init {
//                    THIS SHOULD BE THE TOKEN, but that requires some formatting / reading what a token even us
                    let token = content.user.uid
                
                    await RealmManager.shared.updatUserDataSubscriptions(with: token)
                    
                    let user = UserData()
                    user.create(accessToken: token , self.firstName, self.lastName, self.email, self.userName)
                    
                    self.changeActiveUser()
                }
            }
        }
    }
    
    func signout() {
        activeUser.unload()
        do {
            try Auth.auth().signOut()
        } catch { print(error.localizedDescription) }
    }
    
    func delete() {
        activeUser.unload()
        isSignedin = false
        userLoaded = false
        
        let accessToken = self.accessToken
        
        activeUser = UserData()
        activeUser.delete()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let _ : UserData? = RealmManager.shared.removeDataFromRealm(key: accessToken)
        }
    }
    
    //called whenever there is a sign in
    func changeActiveUser() {
        
        Task.init {
            
            await RealmManager.shared.updatUserDataSubscriptions(with: accessToken)
            
            DispatchQueue.main.async{
                if let user: UserData = RealmManager.shared.locateDataInRealm(key: self.accessToken) {
                    user.load()
                    self.activeUser = user
                    self.userLoaded = true
                    self.isSignedin = true
                }
            }
        }
//        else { signout() }
    }
}
