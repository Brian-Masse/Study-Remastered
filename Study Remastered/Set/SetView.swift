//
//  SetView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI


struct SetView: View {
    
    @ObservedObject var viewModel: SetViewModel
    
    @State var showingCardCreator = false
    
    var body: some View {
        VStack {
            ForEach( Array(viewModel.model.cards.enumerated()), id: \.offset ) { enumeration in
                
                CardView( enumeration.element )
            }
            
            Text( "Create a new Card" )
                .padding(10)
                .background {
                    Rectangle()
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                }
                .onTapGesture { showingCardCreator = true }
//                .sheet(isPresented: $showingCardCreator) {
//                    
////                    CardView(viewModel.createNewCard(), editing: true ) { string in
//                        
//                        
//                    }
//                }
        }
        
        
    }
}
