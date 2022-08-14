//
//  SetView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI

struct SetView: View {
    
    @EnvironmentObject var viewModel: SetViewModel
    
    @State var showingEditor = false
    @State var showingFlashCards = false
    @State var showingSettings = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            
            HStack {
                NamedButton("Back", and: "chevron.backward", oriented: .horizontal, reversed: true).onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
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
            
            NamedButton( "Set Settings", and: "command.square", oriented: .horizontal ).onTapGesture { showingSettings = true }
            
            Text( viewModel.description )
            
            ScrollView(.vertical, showsIndicators: true) {
                ForEach( Array(viewModel.cards.enumerated()), id: \.offset ) { enumeration in
                    CardView( displayType: .double )
                        .environmentObject( enumeration.element )
                }
            }
        
        }
        .fullScreenCover(isPresented: $showingEditor) {
            SetEditorView()
                .environmentObject(viewModel.editorViewModel)
        }
        .fullScreenCover(isPresented: $showingFlashCards) {
            FlashCardView()
        }
        .fullScreenCover(isPresented: $showingSettings) {
            SetSettingsView() { presentationMode.wrappedValue.dismiss() }
        }
    }
}

struct SetPreviewView: View {
    
    @EnvironmentObject var setViewModel: SetViewModel
    @EnvironmentObject var user: User
    
    @State var showingSet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text( setViewModel.name )
                if setViewModel.description != "" {
                    Text( setViewModel.description )
                        .padding(.bottom)
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
        .background(Color(red: 1, green: 1, blue: 1, opacity: 1))
        .onTapGesture {
            showingSet = true
        }
        .fullScreenCover(isPresented: $showingSet) { SetView() }
    }
}

struct SetSettingsView: View {
    
    @EnvironmentObject var setViewModel: SetViewModel
    @EnvironmentObject var user: User
    
    @Environment(\.presentationMode) var presentationMode
    let toggleSetView: () -> Void
    
    var body: some View {
        
        VStack {
            HStack {
                NamedButton("Back", and: "chevron.backward", oriented: .horizontal, reversed: true).onTapGesture { presentationMode.wrappedValue.dismiss() }
                Spacer()
            }.padding()
            
            Text( setViewModel.name )
            
            Spacer()
            
            NamedButton("Delete", and: "trash", oriented: .horizontal)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                    toggleSetView()
                    user.deleteSet(with: setViewModel)
                }
        }
        
    }
    
}

