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
