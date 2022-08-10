//
//  ProfileView.swift
//  
//
//  Created by Brian Masse on 8/1/22.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var user: User
    @StateObject var authenticationHandler = AuthenticatorViewModel.shared
    
    @State var firstName = ""
    @State var lastName = ""
    @State var userName = ""
    @State var email = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            
            ZStack {
                HStack {
                    NamedButton("back", and: "chevron.left", oriented: .horizontal, reversed: true)
                        .onTapGesture { presentationMode.wrappedValue.dismiss() }
                    Spacer()
                }
                Text( user.getFormattedName() )
            }
            .padding(.horizontal)
            Spacer()
            
        
            
            HStack {
                Text("firstName: ")
                TextField(user.firstName, text: $firstName)
            }
            HStack {
                Text("lastName: ")
                TextField(user.lastName, text: $lastName)
            }
            HStack {
                Text("userName: ")
                TextField(user.userName, text: $userName)
            }
            HStack {
                Text("email: ")
                TextField(user.email, text: $email)
            }
            
            NamedButton("Save", and: "checkmark.seal", oriented: .vertical)
                .onTapGesture {
                    user.updateCredentials(firstName: firstName, lastName: lastName, userName: userName, email: email)
                }
            
            
            
            HStack {
                NamedButton("sign out", and: "rectangle.portrait.and.arrow.right", oriented: .vertical)
                    .onTapGesture { AuthenticatorViewModel.shared.signout() }
                
                NamedButton("delete user", and: "trash", oriented: .vertical)
                    .foregroundColor(.red)
                    .onTapGesture {
                        AuthenticatorViewModel.shared.delete()
                    }
            }
            
            Spacer()
        }
        
    }
}
