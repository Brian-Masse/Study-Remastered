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
    
    @State var showingEditor = false
    @State var showingFlashCards = false
    
    var body: some View {
        
        VStack {
            
            HStack(spacing: 10) {
                NamedButton("edit", and: "square.and.pencil", oriented: .vertical)
                    .onTapGesture {
                        viewModel.editorViewModel.getCopyOfCurrentCards()
                        showingEditor = true
                    }
                
                NamedButton("Flashcards", and: "doc.on.doc", oriented: .vertical).onTapGesture { showingFlashCards = true }
                
                NamedButton("Study", and: "graduationcap", oriented: .vertical)
                
                NamedButton("Write", and: "pencil", oriented: .vertical)
                
                NamedButton("listen", and: "beats.headphones", oriented: .vertical)
            }
            
            ScrollView(.vertical, showsIndicators: true) {
                ForEach( Array(viewModel.model.cards.enumerated()), id: \.offset ) { enumeration in
                    CardView( enumeration.element, displayType: .double )
                }
            }
        
        } .fullScreenCover(isPresented: $showingEditor) {
            SetEditorView()
                .environmentObject(viewModel.editorViewModel)
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $showingFlashCards) {
            FlashCardView()
                .environmentObject(viewModel)
//                .environmentObject(viewModel)
        }
    }
}


