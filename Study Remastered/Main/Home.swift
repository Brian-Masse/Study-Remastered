//
//  Home.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import SwiftUI


class HomeViewModel: ObservableObject {
    
    let activeUser: UserData
    
    init( _ activeUser: UserData ) {
        self.activeUser = activeUser
    }
    
    func addNewSet(number: Int) {
        let newCardViewModel = CardViewModel(CardTextViewModel("Click Here to Edit Text :)"), CardTextViewModel("Click Here to Edit the Back Text :0"))
        let newName = "New Set \(number)"
        let newSet = SetViewModel([ newCardViewModel ], name: newName, description: "")
        activeUser.sets.append(newSet)
    }
    
}

struct HomeView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State var showingSet = false
    @State var activeSet: Int = 0
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 0) {
                Text( homeViewModel.activeUser.getFormattedName() )
            }
            
            Spacer()
            
            ForEach( homeViewModel.activeUser.sets.indices, id: \.self) { index in
                SetPreviewView()
                    .environmentObject( homeViewModel.activeUser.sets[index] )
                    .padding(.horizontal)
                    .onTapGesture {
                        activeSet = index
                        showingSet = true
                    }
            }
            
            NamedButton("Create New Set", and: "plus.rectangle.on.rectangle", oriented: .horizontal)
                .onTapGesture {
                    homeViewModel.addNewSet(number: homeViewModel.activeUser.sets.count)
                    activeSet = homeViewModel.activeUser.sets.count - 1
                }
            
        }
        .onChange(of: activeSet ) { _ in showingSet = true }
        .fullScreenCover(isPresented: $showingSet) { SetView(viewModel: homeViewModel.activeUser.sets[activeSet]) }
    }

}
