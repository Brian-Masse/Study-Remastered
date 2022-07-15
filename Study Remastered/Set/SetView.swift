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
    
    @State var showingQuickSetEditor = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("edit set")
                    .onTapGesture {
                        viewModel.quickSetEditorViewModel.getCopyOfCurrentCards()
                        showingQuickSetEditor = true
                    }
            }
            
            ScrollView(.vertical, showsIndicators: true) {
                ForEach( Array(viewModel.model.cards.enumerated()), id: \.offset ) { enumeration in
                    CardView( enumeration.element, displayType: .double )
                }
            }
            
            Text( "add card" )
                .onTapGesture {
                    let count = viewModel.model.cards.count
                    viewModel.model.cards.append( CardViewModel(CardTextViewModel("front \(count)"),
                                                                CardTextViewModel("back \(count)")) )
                    }
        } .fullScreenCover(isPresented: $showingQuickSetEditor) { QuickSetEditorView().environmentObject(viewModel.quickSetEditorViewModel) }
    }
}


