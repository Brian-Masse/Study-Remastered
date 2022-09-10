//
//  Home.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import SwiftUI
import RealmSwift

struct HomeView: View {
    
    @EnvironmentObject var user: User
    @State var showingProfile = false
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                
                HStack(spacing: 0) {
                    Text( user.getFormattedName() )
                        .onTapGesture { showingProfile = true }
                }
                
                NamedButton("Save User", and: "person.badge.key", oriented: .horizontal)
                    .onTapGesture { user.save(withUpdateToUser: true) }
                
                Spacer()
                
                ScrollView(.vertical) {
                    ForEach( user.sets.indices, id: \.self) { index in
                        SetPreviewView()
                            .environmentObject( user.sets[index] )
                    }
                }
                .frame(maxHeight: geo.size.height / 2)
                .padding(5)
                .overlay( RoundedRectangle(cornerRadius: 15).stroke() )
                .padding(5)
                
                NamedButton("Create New Set", and: "plus.rectangle.on.rectangle", oriented: .horizontal)
                    .onTapGesture { user.addNewSet() }
        
            }
            .transition(.slide)
            .background( ZStack { }
                .fullScreenCover(isPresented: $showingProfile) { ProfileView() })
        }
    }

}
