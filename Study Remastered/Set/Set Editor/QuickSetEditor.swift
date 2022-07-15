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
    
    static let defaultCreationString = "enter text here"
    
    let setViewModel: SetViewModel?
    let width: CGFloat
    @Published var currentCards: [ CardViewModel ] = []

    init() {
        width = 0
        setViewModel = nil
    }
    
    init( _ viewModel: SetViewModel, in width: CGFloat ) {
        self.setViewModel = viewModel
        self.width = width
        self.getCopyOfCurrentCards()
    }
    
    func getCopyOfCurrentCards() {
        currentCards = setViewModel!.cards.map({ card in
            let copy = card.copy(in: width)
            copy.beginEditing()
            return copy
        })
    }

    func saveEdits() {
        //update all the new values
        for index in currentCards.indices {
            currentCards[index].endEditing()
            
            if index <= setViewModel!.cards.count - 1 {
                setViewModel!.cards[index].frontTextViewModel = currentCards[index].frontTextViewModel.copy()
                setViewModel!.cards[index].backTextViewModel = currentCards[index].backTextViewModel.copy()
            }else {
                if currentCards[index].frontTextViewModel.returnContentsAsString() != QuickSetEditorViewModel.defaultCreationString &&
                    currentCards[index].backTextViewModel.returnContentsAsString() != QuickSetEditorViewModel.defaultCreationString {
                    setViewModel!.addCard(with: currentCards[index].copy())
                }
            }
        }
    }
    
    func addNewCard() {
        let newCard = CardViewModel(CardTextViewModel(QuickSetEditorViewModel.defaultCreationString), CardTextViewModel(QuickSetEditorViewModel.defaultCreationString))
        newCard.beginEditing()
        currentCards.append(newCard)
    }
}

struct QuickSetEditorView: View {

    @EnvironmentObject var editorViewModel: QuickSetEditorViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Button("Dismiss Modal") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ForEach( 0..<editorViewModel.currentCards.count, id: \.self ) { index in
                    CardEditor(cardCopy: editorViewModel.currentCards[index], width: geo.size.width * 0.45)
                }

                Text("Add new Card")
                    .onTapGesture {
                        editorViewModel.addNewCard()
                    }
                
                Spacer()
                Text("save edits")
                    .onTapGesture {
                        editorViewModel.saveEdits()
                    }
            }
        }
    }
    
    struct CardEditor: View {
        let cardCopy: CardViewModel
        let width: CGFloat
        
        var body: some View {
            HStack(alignment: .bottom) {
                EditablePiece(width: width, model: cardCopy.frontTextViewModel, label: "front")
                EditablePiece(width: width, model: cardCopy.backTextViewModel, label: "back")
            }
            .padding()
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
