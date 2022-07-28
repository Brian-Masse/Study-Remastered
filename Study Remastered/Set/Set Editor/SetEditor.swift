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
            
                HStack(spacing: 10) {
                    NamedButton("save", and: "checkmark.seal", oriented: .vertical).onTapGesture   {
                        setEditorViewModel.saveEdits()
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    NamedButton( "dicard edits", and: "trash", oriented: .vertical ).onTapGesture { presentationMode.wrappedValue.dismiss() }
                    
                    NamedButton(!quickEditor ? "Quick Set Editor" : "Full Set Editor", and: "arrow.2.squarepath", oriented: .vertical)
                        .onTapGesture { quickEditor.toggle() }
                }
                
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

struct CardScroller<someView: View, contentView: View>: View {
   
    let cards: [ CardViewModel ]
    let continuousScrolling: Bool
    let endFunction: () -> Void
    @ViewBuilder var endButton: someView
    @ViewBuilder var content: (Int) -> contentView
    
    @State var currentCardIndex = 0
    @State var gestureDirection = false
    
    private let horizontalTolerance: CGFloat = 40
    private let verticalTolerance: CGFloat = 5
    
    private func getAnimationMovement(forward: Bool) -> CGFloat {
        return (globalFrame.height ) * ( gestureDirection ? 1 : -1 ) * ( forward ? 1 : -1 )
    }
    
    private func changeActiveCard(with direction: Bool) {
        gestureDirection = direction
        withAnimation() {
            if direction {
                if currentCardIndex == cards.count - 1 { endFunction() }
                if continuousScrolling { currentCardIndex += 1 }
                if currentCardIndex < cards.count - 1 { currentCardIndex = currentCardIndex + 1 }
            } else { currentCardIndex = max( currentCardIndex - 1, 0 ) }
        }
    }

    var body: some View {
        let swipe = DragGesture()
            .onEnded { gesture in
                if abs(gesture.location.x - gesture.startLocation.x) < horizontalTolerance {
                    if abs(gesture.location.y - gesture.startLocation.y) > verticalTolerance {
                        if (gesture.location.y - gesture.startLocation.y) < 0   { changeActiveCard(with: true) }
                        else                                                    { changeActiveCard(with: false) }
                    }
                }
            }
        
        ZStack {
            content(currentCardIndex)
                .id(UUID())
                .transition( .asymmetric(insertion: .verticalSlide(offSet: getAnimationMovement(forward: true)),
                                         removal: .verticalSlide(offSet:  getAnimationMovement(forward: false)) ))
            
            VStack {
                Spacer()
                if currentCardIndex + 1 < cards.count {
                    content(currentCardIndex + 1)
                        .transition( .asymmetric(insertion: .scale, removal: .opacity) )
                        .offset(y: globalFrame.height * (7/10))
                }else { endButton }
            }
        }.gesture(swipe)
    }
}
