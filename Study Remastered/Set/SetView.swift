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
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            
            HStack {
                NamedButton("Back", and: "chevron.backward", oriented: .horizontal, reversed: true).onTapGesture { presentationMode.wrappedValue.dismiss() }
                Spacer()
                NamedButton(viewModel.name, and: "rectangle.on.rectangle", oriented: .horizontal)
            }.padding()
            
            HStack(spacing: 10) {
                NamedButton("edit", and: "square.and.pencil", oriented: .vertical)
                    .onTapGesture {
                        viewModel.editorViewModel.getCopy()
                        showingEditor = true
                    }
                
                NamedButton("Flashcards", and: "doc.on.doc", oriented: .vertical).onTapGesture { showingFlashCards = true }
                
                NamedButton("Study", and: "graduationcap", oriented: .vertical)
                
                NamedButton("Write", and: "pencil", oriented: .vertical)
                
                NamedButton("listen", and: "beats.headphones", oriented: .vertical)
            }
            
            Text( viewModel.description )
            
            ScrollView(.vertical, showsIndicators: true) {
                ForEach( Array(viewModel.model.cards.enumerated()), id: \.offset ) { enumeration in
                    CardView( enumeration.element, displayType: .double )
                }
            }
        
        }
        .fullScreenCover(isPresented: $showingEditor) {
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

struct SetPreviewView: View {
    
    @EnvironmentObject var setViewModel: SetViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text( setViewModel.model.name )
                if setViewModel.description != "" {
                    Text( setViewModel.model.description )
                        .padding(.bottom)
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.01))
    }
}


