//
//  SetEditor.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/27/22.
//

import Foundation
import SwiftUI


class SetEditorViewModel: ObservableObject {
    
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
                if currentCards[index].frontTextViewModel.returnContentsAsString() != SetEditorViewModel.defaultCreationString &&
                    currentCards[index].backTextViewModel.returnContentsAsString() != SetEditorViewModel.defaultCreationString {
                    setViewModel!.addCard(with: currentCards[index].copy())
                }
            }
        }
    }
    
    func addNewCard() {
        let newCard = CardViewModel(CardTextViewModel(SetEditorViewModel.defaultCreationString), CardTextViewModel(SetEditorViewModel.defaultCreationString))
        newCard.beginEditing()
        currentCards.append(newCard)
    }
}

struct SetEditorView: View {
    
    @EnvironmentObject var setEditorViewModel: SetEditorViewModel
    @EnvironmentObject var setViewModel: SetViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var quickEditor: Bool = false
    
    var body: some View {
        
        ZStack {
            VStack {
            
                HStack {
                    Button("Dismiss Modal") { presentationMode.wrappedValue.dismiss() }
                    Button( "save" ) {
                        setEditorViewModel.saveEdits()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                Text( !quickEditor ? "Quick Set Editor" : "Full Set Editor" )
                    .onTapGesture { quickEditor.toggle() }
                
                if quickEditor {
                    QuickSetEditorView().environmentObject( setEditorViewModel )
                }else {
                    FullSetEditor()
                        .environmentObject( setEditorViewModel )
                        .environmentObject( setViewModel )
                }
            }
            
            Calculator(shouldDisplayText: false)
                .environmentObject( appViewModel )
        }
        
    }
    
}
