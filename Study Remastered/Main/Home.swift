//
//  Home.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject var user: User
    
    @State var showingSet = false
    @State var activeSet: Int = 0
    
    @State var showingProfile = false
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 0) {
                Text( user.getFormattedName() )
                    .onTapGesture { showingProfile = true }
            }
            
            Spacer()
            
            ForEach( user.sets.indices, id: \.self) { index in
                SetPreviewView()
                    .environmentObject( user.sets[index] )
                    .padding(.horizontal)
                    .onTapGesture {
                        activeSet = index
                        showingSet = true
                    }
            }
            
            NamedButton("Create New Set", and: "plus.rectangle.on.rectangle", oriented: .horizontal)
                .onTapGesture {
                    user.addNewSet()
                    activeSet = user.sets.count - 1
                }
            
            NamedButton("Save User", and: "person.badge.key", oriented: .horizontal)
                .onTapGesture {
                    user.userData.save(withUpdateToUser: true)
                }
            
        }
        .onChange(of: activeSet ) { _ in showingSet = true }
        .fullScreenCover(isPresented: $showingSet) { SetView(viewModel: user.sets[activeSet]) }
        .fullScreenCover(isPresented: $showingProfile) { ProfileView().environmentObject( user ) }
    }

}
