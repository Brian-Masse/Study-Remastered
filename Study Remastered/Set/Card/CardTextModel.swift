//
//  CardTextModel.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/1/22.
//

import Foundation
import SwiftUI

struct CardTextModel {

    var equationHandlers: [ EquationTextHandler ] = []
    var textFieldViewModels: [ RichTextFieldViewModel ] = []
    
    var componentCount: Int = 1
    
    init( _ text: String ) {
        textFieldViewModels.append( RichTextFieldViewModel(text) )
    }
    
    init( textFieldViewModels: [ RichTextFieldViewModel ], equationHandlers: [ EquationTextHandler ] ) {
        self.equationHandlers = equationHandlers
        self.textFieldViewModels = textFieldViewModels
    }
}


class CardTextViewModel: ObservableObject {
    
    @Published var model: CardTextModel
    @Published var activeViewModel: RichTextFieldViewModel!
    
    @Published var handlerIndex = 0
    @Published var viewModelIndex = 0
    
    @Published var editingEquation = false
    @Published var editing = false
    
    let width: CGFloat
    
    init( _ model: CardTextModel, in width: CGFloat) {
        self.width = width
        self.model = model
        self.activeViewModel = model.textFieldViewModels.first!
    }
    
    init( _ text: String, in width: CGFloat) {
        self.width = width
        self.model = CardTextModel(text)
        self.activeViewModel = model.textFieldViewModels.first!
    }
    
    init( textFieldViewModels: [ RichTextFieldViewModel ], equationHandlers: [ EquationTextHandler ], in width: CGFloat ) {
        self.width = width
        self.model = CardTextModel(textFieldViewModels: textFieldViewModels, equationHandlers: equationHandlers)
        self.activeViewModel = textFieldViewModels.first!
    }
    
    var equationHandlers: [EquationTextHandler] {
        get { model.equationHandlers }
        set { model.equationHandlers = newValue }
    }
    
    var textFieldViewModels: [RichTextFieldViewModel] {
        get { model.textFieldViewModels }
        set { model.textFieldViewModels = newValue }
    }
    
    var componentCount: Int { model.componentCount }

    
    //MARK: Math equation functions
    func hasMathEquation() -> Bool { return !equationHandlers.isEmpty }
    
    func returnContentsAsString(withMathEquation includeMathEquation: Bool = true) -> String {
        var returningString: String = ""
        for index in 0..<componentCount {
            if index % 2 == 0 { returningString += textFieldViewModels[index].viewController.text }
            else {
                if includeMathEquation { returningString += equationHandlers[index].returnDisplayabledText() }
                else { returningString += " " }
            }
        }
        return returningString
        
    }
    
    func addMathEquation( at textFieldViewModel: RichTextFieldViewModel) {
        if editingEquation { return }
        
        let index = viewModelIndex
        let text = textFieldViewModel.viewController.text
        let attributedText = textFieldViewModels[ index ].viewController.textView.attributedText
        guard let range = Range( textFieldViewModel.viewController.getCursorRange(), in: text ) else { return }
        
        let leadingText: NSAttributedString = {
            if text.startIndex == range.lowerBound { return .init(string: "") }
            
            let nsRange = NSRange(text.startIndex..<range.lowerBound, in: text)
            guard let attributedTextString = attributedText?.attributedSubstring(from: nsRange ) else { return .init(string: "") }
            return attributedTextString
        }()
        
        let trailingText: NSAttributedString = {
            if text.count == 0 { return .init(string: "") }
            if text.index(before: text.endIndex) == range.upperBound { return .init(string: "") }
            
            let nsRange = NSRange(range.upperBound..<text.endIndex, in: text)
            guard let attributedTextString =  attributedText?.attributedSubstring(from: nsRange ) else { return .init(string: "") }
            return attributedTextString
        }()
        
        let mathMutableAttributedString = NSMutableAttributedString(string: "MT")
        mathMutableAttributedString.setAttributes(textFieldViewModels[ index ].activeAttributes, range: NSRange(location: 0, length: 2))
        let viewModel = RichTextFieldViewModel(mathMutableAttributedString, with: textFieldViewModels[ index ].activeAttributes, in: 100)
        
        let handler = EquationTextHandler( viewModel  )
    
        equationHandlers.insert(handler, at: index)
        
    
        textFieldViewModels[ index ].observer.cancel()
        textFieldViewModels[ index ] = RichTextFieldViewModel( leadingText, with: textFieldViewModels[ index ].activeAttributes, in: width )
        textFieldViewModels.insert( RichTextFieldViewModel(trailingText, with: textFieldViewModels[ index ].activeAttributes, in: width), at: index + 1 )
    
        for index in index + 1...textFieldViewModels.count - 1 {
            textFieldViewModels[index].observer.cancel()
            textFieldViewModels[index] = RichTextFieldViewModel( textFieldViewModels[index].viewController.textView.attributedText, with: textFieldViewModels[index].activeAttributes, in: width )
        }
        
        for index in 0...equationHandlers.count - 1 {
            equationHandlers[index] = EquationTextHandler( RichTextFieldViewModel( equationHandlers[index].textFieldViewModel.viewController.textView.attributedText,
                                                                                   with: equationHandlers[index].textFieldViewModel.activeAttributes, in: width) )
        }
        
        handlerIndex = index
        editingEquation = true
        updateComponentCount()
    }
    
    
    func deleteMathEquation( at handlerIndex: Int ) {
    
        let leadingText = NSMutableAttributedString( attributedString: textFieldViewModels[ handlerIndex ].viewController.textView.attributedText! )
        let trailingText = NSMutableAttributedString( attributedString: textFieldViewModels[ handlerIndex + 1 ].viewController.textView.attributedText! )
        leadingText.append( trailingText )
        
        let viewModel = RichTextFieldViewModel(leadingText, with: equationHandlers[handlerIndex].equationText.textFieldViewModel.activeAttributes, in: 350)
         
        textFieldViewModels[ handlerIndex ] = viewModel
        textFieldViewModels.remove(at: handlerIndex + 1)
        equationHandlers.remove(at: handlerIndex)   
        
        updateComponentCount()
    }
    
    //MARK: editing + serializing
    func beginEditing() {
        toggleViewEditability(with: true)
    }
    
    func saveCard() {
        toggleViewEditability(with: false)
        
    }
    
    private func toggleViewEditability(with newValue: Bool ) {
        editing = newValue
        for viewModel in textFieldViewModels { viewModel.viewController.setEditability(with: newValue) }
    }
    
    //MARK: UTILITY
    private func updateComponentCount() { model.componentCount = textFieldViewModels.count + equationHandlers.count }
    
    func copy(with newWidth: CGFloat? = nil) -> CardTextViewModel {
        let safeWidth = newWidth == nil ? width : newWidth!
        return CardTextViewModel(textFieldViewModels: textFieldViewModels.map( { textFieldViewModel in
            let copy = textFieldViewModel.copy()
            copy.updateWidth(safeWidth)
            return copy
        }), equationHandlers: equationHandlers.map( { equationHandler in equationHandler.copy() } ), in: safeWidth )
    }
    
}

