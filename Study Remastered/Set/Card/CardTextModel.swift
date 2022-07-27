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
    
    init( _ model: CardTextModel) {
        self.model = model
        self.activeViewModel = model.textFieldViewModels.first!
    }
    
    init( _ text: String) {
        self.model = CardTextModel(text)
        self.activeViewModel = model.textFieldViewModels.first!
        self.endEditing()
    }
    
    init( textFieldViewModels: [ RichTextFieldViewModel ], equationHandlers: [ EquationTextHandler ]) {
        self.model = CardTextModel(textFieldViewModels: textFieldViewModels, equationHandlers: equationHandlers)
        self.activeViewModel = textFieldViewModels.first!
        self.endEditing()
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
            if index % 2 == 0 { returningString += textFieldViewModels[index].text }
            else {
                if includeMathEquation { returningString += equationHandlers[index].returnDisplayabledText() }
                else { returningString += " " }
            }
        }
        return returningString
        
    }
    
    func addMathEquation() {
        if editingEquation { return }

        let index = viewModelIndex
        let text = activeViewModel.text
        let attributedText = textFieldViewModels[ index ].attributedText
        guard let range = Range( activeViewModel.selectedRange, in: text ) else { return }

        let leadingText: NSAttributedString = {
            if text.startIndex == range.lowerBound { return .init(string: "") }

            let nsRange = NSRange(text.startIndex..<range.lowerBound, in: text)
//            guard let attributedTextString = attributedText.attributedSubstring(from: nsRange ) else { return .init(string: "") }
            let attributedTextString = attributedText.attributedSubstring(from: nsRange )
            return attributedTextString
        }()

        let trailingText: NSAttributedString = {
            if text.count == 0 { return .init(string: "") }
            if text.index(before: text.endIndex) == range.upperBound { return .init(string: "") }

            let nsRange = NSRange(range.upperBound..<text.endIndex, in: text)
//            guard let attributedTextString =  attributedText.attributedSubstring(from: nsRange ) else { return .init(string: "") }
            let attributedTextString =  attributedText.attributedSubstring(from: nsRange )
            return attributedTextString
        }()
        
        print("\n HERE IS THE NEXT INSERTION")
        print( TextFieldViewController.getMemoryAdress(of: activeViewModel ) )
        print(text, text[ range ] )
        print( leadingText, trailingText )

        let mathMutableAttributedString = NSMutableAttributedString(string: "MT")
        mathMutableAttributedString.setAttributes(textFieldViewModels[ index ].activeAttributes, range: NSRange(location: 0, length: 2))
        let viewModel = RichTextFieldViewModel(mathMutableAttributedString, with: textFieldViewModels[ index ].activeAttributes)
        
        print( "Mat Equation ViewModel: \(TextFieldViewController.getMemoryAdress(of: viewModel))")

        let handler = EquationTextHandler( viewModel  )

        equationHandlers.insert(handler, at: index)

//        textFieldViewModels[ index ].observer.cancel()
//        textFieldViewModels[ index ] = RichTextFieldViewModel( leadingText, with: textFieldViewModels[ index ].activeAttributes)
        textFieldViewModels[index].attributedText = leadingText
        
        textFieldViewModels.insert( RichTextFieldViewModel(trailingText, with: textFieldViewModels[ index ].activeAttributes), at: index + 1 )
//
//        for index in index + 1...textFieldViewModels.count - 1 {
////            textFieldViewModels[index].observer.cancel()
//            textFieldViewModels[index] = RichTextFieldViewModel( textFieldViewModels[index].attributedText, with: textFieldViewModels[index].activeAttributes)
//        }
//
//        for index in 0...equationHandlers.count - 1 {
//            equationHandlers[index] = EquationTextHandler( RichTextFieldViewModel( equationHandlers[index].textFieldViewModel.attributedText,
//                                                                                   with: equationHandlers[index].textFieldViewModel.activeAttributes) )
//        }

        beginEditingEquation(at: index)
        beginEditing()
        updateComponentCount()
    }
    
    
    func deleteMathEquation( at handlerIndex: Int ) {
//
        let leadingText = NSMutableAttributedString( attributedString: textFieldViewModels[ handlerIndex ].attributedText )
        let trailingText = NSMutableAttributedString( attributedString: textFieldViewModels[ handlerIndex + 1 ].attributedText )
        leadingText.append( trailingText )

//        let viewModel = RichTextFieldViewModel(leadingText, with: equationHandlers[handlerIndex].equationText.textFieldViewModel.activeAttributes)

//        textFieldViewModels[ handlerIndex ].viewController.setAttributedText( leadingText )
        textFieldViewModels[handlerIndex].attributedText = leadingText

//        textFieldViewModels[ handlerIndex ] = viewModel
        textFieldViewModels.remove(at: handlerIndex + 1)
        equationHandlers.remove(at: handlerIndex)

        beginEditing()
        updateComponentCount()
    }
    
    //MARK: editing
    func beginEditing() { toggleViewEditability(with: true) }
    func endEditing() { toggleViewEditability(with: false) }
    
    func beginEditingEquation(at index: Int) {
        if editing {
            handlerIndex = index
            editingEquation = true
            appViewModel.calculatorIsActive = true
            appViewModel.activeCalculatorHandler = equationHandlers[index]
            activeViewModel = equationHandlers[index].textFieldViewModel
        }
    }
    
    func endEditingEquation() {
        editingEquation = false
        appViewModel.calculatorIsActive = false
    }
    
    //MARK: serialization
    func saveCard() {
        toggleViewEditability(with: false)
    }
    
    private func toggleViewEditability(with newValue: Bool ) {
        
        if !newValue { UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
          )  }
        editing = newValue
        for viewModel in textFieldViewModels { viewModel.editing = newValue }
    }
    
    //MARK: UTILITY
    private func updateComponentCount() { model.componentCount = textFieldViewModels.count + equationHandlers.count }
    
    func copy(with newWidth: CGFloat? = nil) -> CardTextViewModel {
        return CardTextViewModel(textFieldViewModels: textFieldViewModels.map( { textFieldViewModel in textFieldViewModel.copy()}),
                                 equationHandlers: equationHandlers.map( { equationHandler in equationHandler.copy() } ) )
    }
    
}

