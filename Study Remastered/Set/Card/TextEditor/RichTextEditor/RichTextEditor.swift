//
//  RichTextEditor.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/15/22.
//

import Foundation
import SwiftUI
import UIKit
import Combine

//MARK: ViewController
class TextFieldViewController: UIViewController, UITextViewDelegate, ObservableObject {
    
    let textView = UITextView()
    
    var textViewInsertedElement: Bool = false
     
    var parentViewModel: RichTextFieldViewModel!
    var width: CGFloat = 0
    
    @Published var currentlyEditing: Bool = false
    
    var size: CGSize = .zero
    
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    init(parent: RichTextFieldViewModel, at selectedRange: NSRange) {
        super.init(nibName: nil, bundle: nil)
        self.parentViewModel = parent
        self.textView.attributedText = parent.attributedText
        self.textView.selectedRange = selectedRange
        
        print("reinit: \(parentViewModel.editing), TextView at: \( TextFieldViewController.getMemoryAdress(of: self.textView) )")
        
//        self.textView.isEditable = parentViewModel.editing
//        self.textView.isSelectable = parentViewModel.editing
//
//        self.textView.isEditable = true
//        self.textView.isSelectable = true
        
//        print( "initializing a viewController with: \( TextFieldViewController.getMemoryAdress(of: parent)) [\( self.text )]" )
    }
    
    override func viewDidAppear(_ animated: Bool) { }
    override func viewDidLayoutSubviews() { SetViewFrames() }
    
    override func viewDidLoad() {
        
        textView.delegate = self
//        textView.backgroundColor = .clear
        
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
    
        
//        textView.textColor = UIColor( Colors.UIprimaryCream )
//        textView.font = EditableTextUtilities.setFont(self, with: GlobalTextConstants.UIFontFamily, and: 30).1
        
//        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
//        view.backgroundColor = .red
        
        view.addSubview(textView)
//        SetViewFrames()
    }
    
    func SetViewFrames() {
        let fixedHeight = size.height
        
        let updatedSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight ))
        
        var newSize: CGSize = {
            if updatedSize.width >= width {
                return textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            }
            return textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight ))
        }()
    
        newSize = CGSize(width: newSize.width, height:  newSize.height)
        textView.frame.size = newSize
        size = newSize
    }
    
    func setEditability(with allowsEdits: Bool) {
        
//        if !allowsEdits { }
        textView.isUserInteractionEnabled = allowsEdits
//        textView.isSelectable = allowsEdits
//        textView.isEditable = allowsEdits
    }
    
    
    //MARK: TextView Functions
    func changeStoredText(with textView: UITextView) {
        
        //apply the current attributes to the typed text
//        if textView.text.count == self.text.count + 1 {
//            textViewInsertedElement = true
//
//            let selection = self.textView.selectedRange
//            let mutableAttributes = NSMutableAttributedString(attributedString: textView.attributedText)
//
//            let rangeSize = textView.text.count - self.text.count
//            let range = NSRange(location: selection.lowerBound - rangeSize, length: rangeSize)
//
//            mutableAttributes.setAttributes([:], range: range)
//            mutableAttributes.addAttributes(parentViewModel.activeAttributes, range: range)
//            self.textView.attributedText = mutableAttributes
//            self.textView.selectedRange = selection
//
//        }else { self.textView.attributedText = textView.attributedText }
//
//        self.text = textView.text
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        parentViewModel.selectedRange = textView.selectedRange
        if textView.text.count == parentViewModel.text.count { parentViewModel.updateAttributes() }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        parentViewModel.setAttributedText(with: textView.attributedText)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) { currentlyEditing = true }
    func textViewDidEndEditing(_ textView: UITextView) { currentlyEditing = false }
    
    func getCursorRange() -> NSRange { textView.selectedRange }
    
    
    //MARK: Attribute Functions
    
    // 0 the attribute is not entirley present in the range, 1 the attribute is entirley not present, 2 the attribute is entirley present
    private func attributeInRange( _ attribute: (NSAttributedString.Key, Any), in text: NSAttributedString ) -> Int {
        var nsRangePointer = NSRange()
        
        let value = text.attribute(attribute.0, at: 0, effectiveRange: &nsRangePointer)
        if !(text.attributedSubstring(from: nsRangePointer).string == text.string) { return 0 }
        
        if value == nil { return 1 }
        if value as! AnyHashable != attribute.1 as! AnyHashable { return 1 }
        return 2
    }
    
    func getActiveFont() -> String {
        let attributes = getAttributes()
        guard let font = attributes[.font] as? UIFont else { return GlobalTextConstants.fontFamily }
        return font.familyName
    }
    
    func setAttributedText( _ text: NSAttributedString ) {
//        let selectedRange = textView.selectedRange
//        textView.attributedText = text
//        textView.selectedRange = selectedRange
//        SetViewFrames()
    }
    
    func toggleAttributes( _ attributes: [ NSAttributedString.Key: Any ] ) {
        
        
        let range = textView.selectedRange
        if range.length == 0 { return  }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let mutableAttributedSubString = mutableAttributedString.attributedSubstring(from: range)
        
        for attribute in attributes {
            if attributeInRange(attribute, in: mutableAttributedSubString) <= 1 { mutableAttributedString.addAttributes(attributes, range: range) }
            else { mutableAttributedString.removeAttribute(attribute.key, range: range) }
        }
        
        textView.attributedText = mutableAttributedString
        textView.selectedRange = range
    }
    
    func getFont() -> UIFont? {
        if textView.text.count == 0 { return UIFont(name: GlobalTextConstants.fontFamily, size: GlobalTextConstants.fontSize ) }
        guard let font = textView.attributedText.attribute(.font, at: max(textView.selectedRange.upperBound - 1, 0), effectiveRange: nil) as? UIFont else {return nil}
        return font
    }
    
    //finds the attributes that are applied throuhgout the selectedRange
    func getAttributes() -> [ NSAttributedString.Key: Any ]  {
        
        func collectFonts(in text: NSAttributedString, start: Int) -> [UIFont] {
            var range = NSRange()
            var fonts: [UIFont] = []
            if start == text.length { return fonts }
            
            let font = text.attribute(.font, at: start, effectiveRange: &range)
            if font == nil { return fonts }
            else {
                fonts.append( font as! UIFont )
                fonts.append(contentsOf: collectFonts(in: text, start: start + range.length))
            }
            return fonts
        }
        
        var returningAttributes: [NSAttributedString.Key: Any] = [:]
        
        let attributedText: NSAttributedString? = {
            let range: NSRange? = {
//                if textView.selectedRange.length == 0 {
//                    let range = Range(textView.selectedRange, in: text)!
//                    if range.lowerBound == text.startIndex { return nil }
//                    return NSRange( text.index(before: range.lowerBound)..<range.lowerBound, in: text )
//                }
                return textView.selectedRange
            }()
            
            guard let safeRange = range else { return nil }
            return textView.attributedText.attributedSubstring(from: safeRange)
        }()
        
        guard let attributedText = attributedText else { return [:] }
    
        var fonts: [UIFont] = []
        
        for attribute in attributedText.attributes(at: 0, effectiveRange: nil) {
            if attribute.key == .font {  fonts = collectFonts(in: attributedText, start: 0)  }
            else if attributeInRange(attribute, in: attributedText) > 0 { returningAttributes[ attribute.key ] = attribute.value }
        }
        
        returningAttributes[.font] = EditableTextUtilities.consolodateFonts(fonts)
        return returningAttributes
    }
    
    static func getMemoryAdress<T: AnyObject>(of object: T) -> String { "\(Unmanaged.passRetained( object ).toOpaque())" }

    func getDesiredMemoryAdress() -> String { "\(Unmanaged.passRetained( self.view ).toOpaque())" }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
//    func copy() -> TextFieldViewController {
//        let vc = TextFieldViewController(textView.text, parent: self.parentViewModel, at: )
//        vc.setAttributedText(textView.attributedText)
//        return vc
//    }
}
