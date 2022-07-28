//
//  QuickSetEditor.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/14/22.
//

import Foundation
import SwiftUI

//manages the copying and merging when editing tex tin the QuickSetEditor


struct QuickSetEditorView: View {

    @EnvironmentObject var editorViewModel: SetEditorViewModel
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ForEach( 0..<editorViewModel.currentCards.count, id: \.self ) { index in
                    CardEditor(cardCopy: editorViewModel.currentCards[index], width: geo.size.width * 0.45)
                }

                Text("Add new Card")
                    .onTapGesture {
                        editorViewModel.addNewCard()
                    }
                
                Spacer()
            }
        }
    }
    
    struct CardEditor: View {
        let cardCopy: CardViewModel
        let width: CGFloat
        
        var body: some View {
            VStack {
                HStack(alignment: .bottom) {
                    EditablePiece(width: width, model: cardCopy.frontTextViewModel, label: "front")
                    EditablePiece(width: width, model: cardCopy.backTextViewModel, label: "back")
                }.padding()
            }
        }
        
        struct EditablePiece: View {
            
            @State var size: CGSize = .zero
            let width: CGFloat
            let model: CardTextViewModel
            let label: String
            
            var body: some View {
                VStack(alignment: .leading, spacing: 2) {
                    ScrollView(.vertical) {
                        CardTextView(size: $size, width: width)
                            .environmentObject( model )
                    }.frame(height: min( 75, size.height ))
                    
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(height: 2)
                        .background(.purple)
                    Text( label )
                }
            }
        }
    }
}
