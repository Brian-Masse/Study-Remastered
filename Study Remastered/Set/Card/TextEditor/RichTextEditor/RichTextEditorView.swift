//
//  RichTextEditorView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/30/22.
//

import Foundation
import SwiftUI


struct RichTextEditorControls: View {
    
    @EnvironmentObject var activeTextFieldViewModel: RichTextFieldViewModel
    
    var body: some View {
        
        HStack {
            ToggleAttributeButton(name: "highlight", key: .foregroundColor, value: UIColor.green)
                .environmentObject( activeTextFieldViewModel )
            
            ToggleAttributeButton(name: "bold", key: .font, value: UIFontDescriptor.SymbolicTraits.traitBold)
                .environmentObject( activeTextFieldViewModel )
            
            ToggleAttributeButton(name: "Italics", key: .font, value: UIFontDescriptor.SymbolicTraits.traitItalic)
                .environmentObject( activeTextFieldViewModel )
        }
        .onChange(of: activeTextFieldViewModel.viewController.selectedRange) { _ in
            activeTextFieldViewModel.setAttributes( activeTextFieldViewModel.viewController.getAttributes() )
        }
    }
    
    struct ToggleAttributeButton: View {
        
        @EnvironmentObject var activeTextFieldViewModel: RichTextFieldViewModel
        
        let name: String
        
        let key: NSAttributedString.Key
        let value: Any
        
        func setAttribute( key: NSAttributedString.Key, value: Any ) {
            if let trait = value as? UIFontDescriptor.SymbolicTraits {
                activeTextFieldViewModel.viewController.setAttributedText(EditableTextUtilities.addTraitTo(activeTextFieldViewModel.viewController, with: trait))
                activeTextFieldViewModel.toggleFont(trait)
            }else {
                activeTextFieldViewModel.viewController.toggleAttributes([ key: value ])
                activeTextFieldViewModel.toggleAttributes([ key: value ])
            }
        }
        
        func checkValueMatch() -> Bool {
            if let trait = value as? UIFontDescriptor.SymbolicTraits {
                return activeTextFieldViewModel.activeAttributes.contains(where: { element in
                    guard let font = element.value as? UIFont else {return false}
                    
                    return element.key == key && font.hasTrait(trait)
                })
            } else {
                return activeTextFieldViewModel.activeAttributes.contains(where: { element in
                    element.key == key && element.value as! AnyHashable == value as! AnyHashable
                })
            }
        }
        
        var body: some View {
            Text( name )
                .onTapGesture {
                    setAttribute(key: key, value: value )
                }
                .background(GeometryReader { geo in
                    
                    if checkValueMatch() {
                    
                        Rectangle()
                            .foregroundColor(.blue)
                    }else {
                        Rectangle()
                            .foregroundColor(.gray)
                    }
                })
        }
    }
}
