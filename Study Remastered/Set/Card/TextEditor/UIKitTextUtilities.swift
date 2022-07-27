//
//  UIKitTextUtilities.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/15/22.
//

import Foundation
import UIKit

class EditableTextUtilities {
    
    // takes the passed fonts, finds their common traits, and returns a new single font with all of those traits
    static func consolodateFonts( _ fonts: [UIFont] ) -> UIFont {
        
        var commonTraits: [ UIFontDescriptor.SymbolicTraits ] = [ .traitBold, .traitItalic ]
        
        var fontFamily = GlobalTextConstants.fontFamily
        var fontSize: CGFloat = GlobalTextConstants.fontSize
        
        for font in fonts {
            for trait in commonTraits {
                if !font.hasTrait(trait) { commonTraits.removeAll { passedTrait in passedTrait == trait } }
            }
            if font.pointSize != fontSize && fontSize != GlobalTextConstants.fontSize { fontSize = font.pointSize }
            if font.familyName != fontFamily && fontFamily != GlobalTextConstants.fontFamily { fontFamily = font.familyName }
        }
        if fonts.isEmpty { commonTraits.removeAll() }
        
        var font = UIFont(name: fontFamily, size: fontSize)
        for trait in commonTraits { font = font?.withTraits(trait) }
        return font!
    }
    
    static func setFont( _ viewModel: RichTextFieldViewModel, with fontString: String? = nil, and fontSize: CGFloat? = nil ) -> (NSAttributedString, UIFont)  {
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: viewModel.attributedText)
        let subString = NSMutableAttributedString( attributedString: mutableAttributedString.attributedSubstring(from: viewModel.selectedRange) )
        
        let startIndex = viewModel.selectedRange.lowerBound
        var range = NSRange()
        
        var returningFont: UIFont? = nil
        
        while range.upperBound != subString.length {
            let font: UIFont = subString.attribute(.font, at: range.upperBound, effectiveRange: &range) as? UIFont ?? UIFont(name: GlobalTextConstants.fontFamily, size: GlobalTextConstants.fontSize)!
        
            returningFont = UIFont(name:  fontString == nil ? font.familyName : fontString!, size: fontSize == nil ? font.pointSize : fontSize!)!
            returningFont = returningFont!.withTraits( font.fontDescriptor.symbolicTraits )
            
            let fullRange = NSRange(location: startIndex + range.lowerBound, length: range.length)
            mutableAttributedString.addAttributes([.font: returningFont as Any ], range: fullRange)
        }

        var font = returningFont
        if returningFont == nil {
            font = UIFont(name:  fontString == nil ? viewModel.activeFont.familyName : fontString!, size: fontSize == nil ? viewModel.activeFont.pointSize : fontSize!)!
            font = font?.withTraits( viewModel.activeFont.fontDescriptor.symbolicTraits )
        }
        return (mutableAttributedString, font!)
    }
    
    static func addTraitTo( _ text: NSAttributedString, at selectedRange: NSRange, with trait: UIFontDescriptor.SymbolicTraits ) -> NSAttributedString  {
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: text)
        let subString = NSMutableAttributedString( attributedString: mutableAttributedString.attributedSubstring(from: selectedRange) )
        
        var fonts: [ (UIFont, NSRange) ] = []
        var hasTrait = true
        
        let startIndex = selectedRange.lowerBound
        var range = NSRange()
        
        while range.upperBound != subString.length {
            var font: UIFont = subString.attribute(.font, at: range.upperBound, effectiveRange: &range) as? UIFont ?? UIFont(name: GlobalTextConstants.fontFamily, size: GlobalTextConstants.fontSize)!
    
            if !font.hasTrait(trait) { hasTrait = false }
            if !hasTrait { font = font.withTraits(trait) }
            
            let fullRange = NSRange(location: startIndex + range.lowerBound, length: range.length)
            fonts.append( ( font, fullRange ) )
        }
        
        for tuple in fonts {
            let finalFont = hasTrait ? tuple.0.withoutTraits(trait) : tuple.0
            mutableAttributedString.addAttributes([.font: finalFont ], range: tuple.1)
        }

        return mutableAttributedString
    }
    
    static func applyTraitTo(_ viewController: TextFieldViewController, with trait: UIFontDescriptor.SymbolicTraits) {
        
        let content = viewController.textView
        
        var range = content.selectedRange
        
        //make sure there is text in the view
        if let text = content.attributedText {
            
            let formattedText = NSMutableAttributedString(attributedString: text)
            
            // select all if nothing is selected
            if range.lowerBound == text.length {
                range = NSRange(location: 0 , length: range.lowerBound)
            }
            
            var fonts: [ (NSRange, UIFont) ] = []
            var currentStartbound = range.lowerBound
            
        
            // This will get all the different font styles in the text,and the ranges that they are in effect on
            while currentStartbound < range.upperBound {
                
                var returningRange = NSRange()
                
                let attribute = text.attribute(NSAttributedString.Key.font, at: currentStartbound, effectiveRange: &returningRange)
    
                let endBound = min( returningRange.upperBound, range.upperBound )
                let safeRange = NSMakeRange(currentStartbound, endBound - currentStartbound)
                
                
                if let font = attribute as? UIFont {
                    fonts.append( ( safeRange, font ) )
                }
                
                currentStartbound = endBound
            }
            
            // nil if all have trait applied, int if they dont
            let notApplied: Int? = fonts.firstIndex(where: { range, font in
                if !font.hasTrait(trait) { return true }
                return false
            })
            
            // add or remove trait to all the current font schemes (based on the var above)
            for tuple in fonts {
                
                var boldFont: UIFont!
                
                //all have trait applied, remove trait
                if notApplied == nil {  boldFont = tuple.1.withoutTraits(trait)  }
                else {  boldFont = tuple.1.withTraits(trait)  }
                
                let boldAttribute = [ NSAttributedString.Key.font: boldFont ]
                
                formattedText.addAttributes(boldAttribute as [NSAttributedString.Key : Any], range: tuple.0)
            }
        
            // apply the formatted Tecxt To The Old Text
            content.attributedText = formattedText
            content.selectedRange = range
            
            viewController.SetViewFrames()
        }
    }
}



extension UIFont {

    func hasTrait( _ trait: UIFontDescriptor.SymbolicTraits ) -> Bool {
        return (trait.rawValue & fontDescriptor.symbolicTraits.rawValue) > 0
    }
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        //this perameter can be euther a list of traits, or a single trait (there is an init for a sequence of traits that apparently is automatically called)
        
        var traitList: [ UIFontDescriptor.SymbolicTraits ] = [fontDescriptor.symbolicTraits]
        
        // this tests if the current selection already has the trait that is trying to be applied
        if (traits.rawValue & fontDescriptor.symbolicTraits.rawValue) <= 0 {
            traitList.append( traits )
        }
        
        let list = UIFontDescriptor.SymbolicTraits( traitList )
    
        guard let fd = fontDescriptor.withSymbolicTraits( list ) else { return self }
        return UIFont(descriptor: fd, size: pointSize)
    }
    
    func withoutTraits( _ traits: UIFontDescriptor.SymbolicTraits ) -> UIFont {
        
        let orginalTraitsRaw = fontDescriptor.symbolicTraits.rawValue
        let newTraitsRaw = ( orginalTraitsRaw & ~traits.rawValue )
        
        let newTraits = UIFontDescriptor.SymbolicTraits(rawValue: newTraitsRaw)
        guard let fd = fontDescriptor.withSymbolicTraits( newTraits ) else { return self }
        return UIFont(descriptor: fd, size: pointSize)
        
    }
}




