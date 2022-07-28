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
                NamedButton("edit", and: "pencil.circle", oriented: .vertical)
                    .onTapGesture {
                        viewModel.editorViewModel.getCopyOfCurrentCards()
                        showingQuickSetEditor = true
                    }
                
                NamedButton("flashcards", and: "doc.on.doc", oriented: .vertical)
            }
            
            ScrollView(.vertical, showsIndicators: true) {
                ForEach( Array(viewModel.model.cards.enumerated()), id: \.offset ) { enumeration in
                    CardView( enumeration.element, displayType: .double )
                }
            }
        
        } .fullScreenCover(isPresented: $showingQuickSetEditor) {
            SetEditorView()
                .environmentObject(viewModel.editorViewModel)
                .environmentObject(viewModel)
        }
    }
}


