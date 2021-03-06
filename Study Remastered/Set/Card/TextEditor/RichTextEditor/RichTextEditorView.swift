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
    @EnvironmentObject var cardTextViewModel: CardTextViewModel
    
    let geo: GeometryProxy
    let aspectRatio = 0.29354839
    
    var body: some View {
        ZStack { if cardTextViewModel.editing {
            Rectangle()
                .foregroundColor(Colors.UIprimaryGrey)
                .cornerRadius(15)
                .shadow(color: Colors.shadow, radius: 10, x: 0, y: 4)
            VStack {
                HStack {
    //                ToggleAttributeButton(name: "highlight", key: .foregroundColor, value: UIColor.green)
    //                    .environmentObject( activeTextFieldViewModel )
                    
                    ToggleAttributeButton(name: "b", key: .font, value: UIFontDescriptor.SymbolicTraits.traitBold)
                        .environmentObject( activeTextFieldViewModel )
                    ToggleAttributeButton(name: "i", key: .font, value: UIFontDescriptor.SymbolicTraits.traitItalic)
                        .environmentObject( activeTextFieldViewModel )
                    ToggleAttributeButton(name: "u", key: .underlineStyle, value: NSUnderlineStyle(Text.LineStyle(pattern: .solid, color: .white)).rawValue)
                        .environmentObject( activeTextFieldViewModel )
                    ToggleAttributeButton(name: "x", key: .strikethroughStyle, value: 2)
                        .environmentObject( activeTextFieldViewModel )
                    
                    FontSelector()
                        .environmentObject(activeTextFieldViewModel)
                    
                    FontSizeSelector()
                        .environmentObject(activeTextFieldViewModel)
                }
                .padding(.bottom, 5)
                
                StyledUIText("Insert Math Equation", symbol: "function", fgColor: cardTextViewModel.editingEquation ? Colors.UIprimaryGreyedGrey : Colors.UIprimaryCream)
                    .frame(width: geo.size.width * 0.85, height: 30)
                    .onTapGesture { cardTextViewModel.addMathEquation(at: activeTextFieldViewModel) }
            }
            .onChange(of: activeTextFieldViewModel.viewController.selectedRange) { _ in
                activeTextFieldViewModel.setAttributes( activeTextFieldViewModel.viewController.getAttributes() )
                activeTextFieldViewModel.activeFont = activeTextFieldViewModel.viewController.getActiveFont()
                activeTextFieldViewModel.activeFontSize = activeTextFieldViewModel.viewController.getFont()!.pointSize
            }
        }}.frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9 * aspectRatio, alignment: .center)
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
            UIToggle(name, aspectRatio: 1, isActive: checkValueMatch) { setAttribute(key: key, value: value ) }
                .frame(width: 30, height: 30)
        }
    }
    
    struct FontSizeSelector: View {
        
        @EnvironmentObject var viewModel: RichTextFieldViewModel
        
        func setFontSize(with size: CGFloat) {
            let result = EditableTextUtilities.setFont(viewModel.viewController, and: size)
            viewModel.viewController.setAttributedText( result.0 )
            viewModel.activeFontSize = size
            viewModel.activeAttributes[.font] = result.1
        }
        
        var body: some View {
            
            HStack {
                StyledUIText( "\(Int(viewModel.activeFontSize))" )
                    .frame(width: 34, height: 30)
                
                VStack(spacing: 0) {
                    StyledUIText(symbol: "chevron.up")
                        .frame(width: 30, height: 15).onTapGesture { setFontSize(with: min(viewModel.activeFontSize + 1, 99) ) }
                    Spacer()
                    StyledUIText(symbol: "chevron.down")
                        .frame(width: 30, height: 15).onTapGesture { setFontSize(with: max( viewModel.activeFontSize - 1, 2 )) }
                }.frame(height: 30)
            }
            
        }
        
    }
    
    struct FontSelector: View {
        
        @EnvironmentObject var viewModel: RichTextFieldViewModel
        
        let fonts = [ "helvetica", "Goku", "Arial" ]
        
        var body: some View {
            Menu {
                ForEach( fonts, id: \.self ) { font in
                    Button {
                        let result = EditableTextUtilities.setFont(viewModel.viewController, with: font)
                        viewModel.viewController.setAttributedText( result.0 )
                        viewModel.activeFont = font
                        viewModel.activeAttributes[.font] = result.1
                    } label : {
                        HStack {
                            Text(font)
                            if viewModel.activeFont == font { Image(systemName: "checkmark") }
                        }
                    }
                }
            } label: {
                StyledUIText( viewModel.activeFont, symbol: "chevron.up.chevron.down", aspectRatio: 10 )
                    .frame(width: 100, height: 30)
                
            }
        }
    }
}

struct richTextEditorSerializeControls: View {
    
    let geo: GeometryProxy
    
    @EnvironmentObject var cardTextViewModel: CardTextViewModel
    @Binding var side: Bool
    
    var body: some View {
        
        HStack {

            StyledUIText(cardTextViewModel.editing ? "save" : "edit", symbol: cardTextViewModel.editing ? "checkmark.square" : "pencil")
                .onTapGesture {
                    if cardTextViewModel.editing { cardTextViewModel.saveCard() }
                    else if !cardTextViewModel.editing { cardTextViewModel.beginEditing() }
                }
            
            StyledUIText("flip card", symbol: "arrow.2.squarepath")
                .onTapGesture {
                    cardTextViewModel.saveCard()
                    side.toggle()
                }            
        }.frame(height: 30)
        
    }
    
}
