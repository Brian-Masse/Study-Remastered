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
    @EnvironmentObject var authHandler: AuthenticatorViewModel
    
    @StateObject var utilities = RealmManager.shared
    
    @State var currentTab: StudyRemasteredViewModel.CurrentTab = .files

    var body: some View {
        
        ZStack {
    
            if let _ = utilities.realm {
                if authHandler.userLoaded {
                   
                    VStack {
                        switch currentTab {
                        case .home: HomeView()
                                .environmentObject(authHandler.activeUser.user)
                                .environmentObject(utilities)
                            
                        case .files:
                            FileView(url: mainDirectory)
                                .environmentObject(FileManager.shared)
                        }
                        Spacer()
                        TabBar(currentTab: $currentTab)
                    }
                
                }else { Authenticator() }
            }
        }.task {
            await utilities.loadRealm()
            AuthenticatorViewModel.shared.setupFireBaseHandler()
        }
    }
}

struct TabBar: View {
    
    @Binding var currentTab: StudyRemasteredViewModel.CurrentTab
    
    var body: some View {
            
        HStack {
            Spacer()
            NamedButton("Home", and: "doc.plaintext", oriented: .vertical).onTapGesture { currentTab = .home }
            Spacer()
            NamedButton("Files", and: "folder", oriented: .vertical).onTapGesture { currentTab = .files }
            Spacer()
        }
        .padding(.vertical, 3)
        .padding(.horizontal)
        .background( RoundedRectangle(cornerRadius: 8 ).stroke() )
        .padding(.horizontal)
    }
}
