//
//  QuickSetEditor.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/14/22.
//

import Foundation
import SwiftUI

//manages the copying and merging when editing tex tin the QuickSetEditor
class QuickSetEditorViewModel: ObservableObject {
    
    let setModel: SetViewModel
    @Published var currentCards: [ CardViewModel ] = []
    
    init( _ model: SetViewModel, in width: CGFloat ) {
        self.setModel = model
        
        currentCards = model.cards.map({ card in card.copy(in: width) })
    }

    
    func saveEdits() {
        //update all the new values
        for index in currentCards.indices {
            if index <= setModel.cards.count - 1 {
                setModel.cards[index].frontTextViewModel = currentCards[index].frontTextViewModel
                setModel.cards[index].backTextViewModel = currentCards[index].backTextViewModel
            }
        }
    }
}

struct QuickSetEditorView: View {

    @ObservedObject var editorViewModel: QuickSetEditorViewModel
    
    init(_ set: SetViewModel) {
        editorViewModel = QuickSetEditorViewModel( set , in: globalFrame.width * 0.45 )
    }
    
    @State var showing: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                CardEditor(cardCopy: editorViewModel.currentCards.first! , geo: geo)
                Spacer()
                Text("save edits")
                    .onTapGesture {
                        editorViewModel.saveEdits()
                    }
                Text("show card")
                    .onTapGesture {
                        showing.toggle()
                    }
                
                if showing {
                    
                    CardView(card1ViewModel)
                    
                }
            }
        }
    }
    
    struct CardEditor: View {
        let cardCopy: CardViewModel
        let geo: GeometryProxy
        
        var body: some View {
            HStack {
                editablePiece("front", cardCopy.frontTextViewModel)
                editablePiece("back", cardCopy.backTextViewModel)
            }.padding()
        }
        
        func editablePiece(_ label: String, _ model: CardTextViewModel) -> some View {
            return VStack(alignment: .leading, spacing: 2) {
//                RichTextField()
//                    .environmentObject( RichTextFieldViewModel("temp", in: geo.size.width * 0.45) )
                
                CardTextView(geo: geo)
                    .environmentObject( model )
                
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: 2)
                Text( label )
            }
        }
    }
}
