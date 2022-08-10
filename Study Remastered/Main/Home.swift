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
            }
            
            NamedButton("Create New Set", and: "plus.rectangle.on.rectangle", oriented: .horizontal)
                .onTapGesture { user.addNewSet() }
            
            NamedButton("Save User", and: "person.badge.key", oriented: .horizontal)
                .onTapGesture { user.save(withUpdateToUser: true) }
        }
        .background( ZStack { }
            .fullScreenCover(isPresented: $showingProfile) { ProfileView() }
        )
    }

}
