//
//  CardView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI
import Introspect


class CardTextModel {
    
    var texts: [ Binding<String> ] = []
    
    func addMathEquation( at index: String.Index, in string: String ) {
        
        
        
    }
    
}

struct CardView: View {
    
    @ObservedObject var viewModel: CardViewModel
    
    @State var editingText: String = ""
    
    
    let commitEdits: (String) -> Void
    let editing: Bool
    
    init( _ viewModel: CardViewModel, editing: Bool = false, commitEdits: @escaping (String) -> Void = { text in } ) {
        self.viewModel = viewModel
        self.editing = editing
        self.commitEdits = commitEdits
    }
    
    var body: some View {
        
        CardText(commitEdits: commitEdits, editingText: $editingText )
        
        HStack {
            Side(text: viewModel.frontContent)
            Side(text: viewModel.backContent)
        }.environmentObject(viewModel)
        
    }
    
    struct CardText: View {
        
        let commitEdits: (String) -> Void
        
        @Binding var editingText: String
        
        var body: some View {
            
            TextField("edit text here", text: $editingText) {
                commitEdits(editingText)
            }
            
        }
    }
    
    struct Side: View {
        
        @EnvironmentObject var viewModel: CardViewModel
        var text: String
        
        var body: some View {
            ZStack(alignment: .center) {
                
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .frame(width: globalFrame.width * 0.4, height: globalFrame.height * 0.4)
                
                VStack {
                    Text( text )
                    
                    Text("Check Match")
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            Rectangle()
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    
                    .onTapGesture {
                        viewModel.checkMatch()
                    }
                }
            }
        }
    }
}
