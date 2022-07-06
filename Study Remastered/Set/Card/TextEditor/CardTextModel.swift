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
}


class CardTextViewModel: ObservableObject {
    
    @Published var model: CardTextModel
    @Published var activeViewModel: RichTextFieldViewModel!
    
    init( _ model: CardTextModel) {
        self.model = model
        self.activeViewModel = model.textFieldViewModels.first!
    }
    
    init( _ text: String) {
        self.model = CardTextModel(text)
        self.activeViewModel = model.textFieldViewModels.first!
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
    
    func updateComponentCount() { model.componentCount = textFieldViewModels.count + equationHandlers.count }
    
    func addMathEquation( at textFieldViewModel: RichTextFieldViewModel) {
        
        let index = textFieldViewModels.firstIndex(where: { $0 == textFieldViewModel })!
        
        let handlerIndex = Int(floor(Double(index / 2)))
        let text = textFieldViewModels[ handlerIndex ].viewController.text
        let attributedText = textFieldViewModels[ handlerIndex ].viewController.textView.attributedText
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
        mathMutableAttributedString.setAttributes(textFieldViewModels[ handlerIndex ].activeAttributes, range: NSRange(location: 0, length: 2))
        let viewModel = RichTextFieldViewModel(mathMutableAttributedString, editable: false, with: textFieldViewModels[ handlerIndex ].activeAttributes)
        
        let handler = EquationTextHandler( viewModel  )
    
        equationHandlers.insert(handler, at: handlerIndex)
        
    
        textFieldViewModels[ handlerIndex ].observer.cancel()
        textFieldViewModels[ handlerIndex ] = RichTextFieldViewModel( leadingText, with: textFieldViewModels[ handlerIndex ].activeAttributes )
        textFieldViewModels.insert( RichTextFieldViewModel(trailingText, with: textFieldViewModels[ handlerIndex ].activeAttributes), at: handlerIndex + 1 )
    
        for index in handlerIndex + 1...textFieldViewModels.count - 1 {
            textFieldViewModels[index].observer.cancel()
            textFieldViewModels[index] = RichTextFieldViewModel( textFieldViewModels[index].viewController.textView.attributedText, with: textFieldViewModels[index].activeAttributes )
        }
        
        for index in 0...equationHandlers.count - 1 {
            equationHandlers[index] = EquationTextHandler( RichTextFieldViewModel( equationHandlers[index].textFieldViewModel.viewController.textView.attributedText,
                                                                                   with: equationHandlers[index].textFieldViewModel.activeAttributes) )
        }
        
        updateComponentCount()
    }
    
    
    func deleteMathEquation( at handlerIndex: Int ) {
    
        let leadingText = NSMutableAttributedString( attributedString: textFieldViewModels[ handlerIndex ].viewController.textView.attributedText! )
        let trailingText = NSMutableAttributedString( attributedString: textFieldViewModels[ handlerIndex + 1 ].viewController.textView.attributedText! )
        leadingText.append( trailingText )
        
        let viewModel = RichTextFieldViewModel(leadingText, with: equationHandlers[handlerIndex].equationText.textFieldViewModel.activeAttributes)
         
        textFieldViewModels[ handlerIndex ] = viewModel
        textFieldViewModels.remove(at: handlerIndex + 1)
        equationHandlers.remove(at: handlerIndex)   
        
        updateComponentCount()
    }
    
}

