//
//  Study Remastered View.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/14/22.
//

import Foundation
import SwiftUI

let card1ViewModel = CardViewModel(CardTextViewModel("this is one piece of tex"), CardTextViewModel("this is the back!") )
let card2ViewModel = CardViewModel(CardTextViewModel("front2"), CardTextViewModel("back2") )

let setViewModel = SetViewModel([ card1ViewModel, card2ViewModel ])

struct StudyRemasteredView: View {
    
    @EnvironmentObject var viewModel: StudyRemasteredViewModel
    @State var size: CGSize = .zero
    @EnvironmentObject var authHandler: AuthenticatorViewModel

    var body: some View {
        
        ZStack {
            
            if authHandler.authenticatorModel.isSignedin {
                HomeView()
                    .environmentObject(HomeViewModel(authHandler.authenticatorModel.activeUser))
//                SetView(viewModel: setViewModel)
            }else {
                Authenticator()
            }  
        }
        
    }
    
}
