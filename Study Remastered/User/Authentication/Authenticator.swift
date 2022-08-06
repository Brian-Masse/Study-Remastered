//
//  Authenticator.swift
//  Study - Remastered
//
//  Created by Brian Masse on 3/10/22.
//

import Foundation
import SwiftUI


struct Authenticator: View {
    
    @State var email = ""
    @State var password = ""
    
    @State var firstName = ""
    @State var lastName = ""
    @State var userName = ""
    
    @StateObject var handler = AuthenticatorViewModel.shared
    
    var body: some View {
        VStack {
            Form {
                TextField(text: $email, prompt: Text("email")) {
                    Text("Email")
                }
                SecureField(text: $password, prompt: Text("password")) {
                    Text("Password")
                }
                
                TextField(text: $firstName, prompt: Text("First Name")) {
                    Text("First Name")
                }
                TextField(text: $lastName, prompt: Text("Last Name")) {
                    Text("Last Name")
                }
                TextField(text: $userName, prompt: Text("UserName")) {
                    Text("UserName")
                }
            }
            
            HStack {
                Button(action: { handler.signup(email, password, firstName, lastName, userName) }) {
                    Text( "SIGNUP" )
                }
                
                Button(action: { handler.login(email, password) }) {
                    Text( "LOGIN" )
                }
            }
        }
    }
}
