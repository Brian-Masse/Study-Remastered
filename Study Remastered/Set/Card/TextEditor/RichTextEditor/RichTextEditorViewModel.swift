//
//  RichTextEditorViewmodel.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/5/22.
//

import Foundation
import SwiftUI
import Combine

//MARK: RichTextFieldViewModel
class RichTextFieldViewModel: ObservableObject, Equatable {

    static let attributeDidChangeKey: String = "Masse.Brian.attributeDidChange"

    @Published var attributedText: NSAttributedString
    
    var selectedRange: NSRange = .init()
    
    @Published var editing: Bool = false
    
    
    var text: String { attributedText.string }
    
    let belongsToHandler: Bool
    
    @Published var activeAttributes: [NSAttributedString.Key: Any] = [:] { didSet {
    } }
    
    var activeFont: UIFont {
        guard let font = activeAttributes[.font] as? UIFont else { return UIFont(name: GlobalTextConstants.fontFamily, size: GlobalTextConstants.fontSize)! }
        return font
    }
    
//    @Published var activeFont:  String = GlobalTextConstants.fontFamily
//    @Published var activeFontSize: CGFloat = GlobalTextConstants.fontSize
    
    var setActiveViewModel: ((RichTextFieldViewModel) -> Void)?
    
    init( _ text: String, with activeAttributes: [NSAttributedString.Key: Any]? = nil ) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        self.attributedText = NSAttributedString(string: text)
        self.belongsToHandler = false
    }
    
    init( _ attributedText: NSAttributedString, with activeAttributes: [NSAttributedString.Key: Any]? = nil, setActiveViewModel: ((RichTextFieldViewModel) -> Void)? = nil, belongsToHandler: Bool = false) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        self.setActiveViewModel = setActiveViewModel
        self.attributedText = attributedText
        self.belongsToHandler = belongsToHandler
        self.selectedRange = NSRange(location: 0, length: text.count)
        
    }
    
    
    //MARK: Attribute Functions
    
    //when the textView gets inputed in
    func setAttributedText(with attributedString: NSAttributedString) {
        // apply the current attributes to the text
        if attributedString.string.count == text.count + 1 {
            let mutableAttributes = NSMutableAttributedString(attributedString: attributedString)

            let rangeSize = attributedString.string.count - text.count
            let range = NSRange(location: selectedRange.lowerBound - rangeSize, length: rangeSize)

            mutableAttributes.setAttributes(activeAttributes, range: range)
            attributedText = mutableAttributes
        }else {
            attributedText = attributedString
        }
        updateAttributes()
    }
    
    func postAttributeChange() {
        if !belongsToHandler { return }
        let name = NSNotification.Name(RichTextFieldViewModel.attributeDidChangeKey)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    //when the cursor changes selection
    func updateAttributes() {
        activeAttributes = getAttributes()
//        activeAttributes[.font] = getFont()
    }
    
    private func getFont() -> UIFont? {
        if text.count == 0 { return UIFont(name: GlobalTextConstants.fontFamily, size: GlobalTextConstants.fontSize ) }
        guard let font = attributedText.attribute(.font, at: max(selectedRange.upperBound - 1, 0), effectiveRange: nil) as? UIFont else {return nil}
        return font
    }
    
    private func getAttributes() -> [ NSAttributedString.Key: Any ]  {
        
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
    
        let range: NSRange? = {
            if selectedRange.length == 0 {
                let range = Range(selectedRange, in: text)!
                if range.lowerBound == text.startIndex { return nil }
                return NSRange( text.index(before: range.lowerBound)..<range.lowerBound, in: text )
            }
            return selectedRange
        }()
        
        guard let safeRange = range else { return [:] }
        let selectedText = attributedText.attributedSubstring(from: safeRange)
        
        print("\n \(selectedText) \n")
    
        var fonts: [UIFont] = []
        for attribute in selectedText.attributes(at: 0, effectiveRange: nil) {
            
            let result = attributeInRange(attribute, in: selectedText)
            print(attribute, result)
            if attribute.key == .font {  fonts = collectFonts(in: selectedText, start: 0)  }
            else if result > 0 { returningAttributes[ attribute.key ] = attribute.value }
        }
        
        returningAttributes[.font] = EditableTextUtilities.consolodateFonts(fonts)
        
        print("function finished: \(returningAttributes)")
        
        return returningAttributes
    }
    
    func toggleActiveAttributes( _ attributes: [ NSAttributedString.Key : Any ] ) {
        for attribute in attributes {
            if activeAttributes[ attribute.key ] == nil { activeAttributes[ attribute.key ] = attribute.value; break }
            if activeAttributes[ attribute.key ] as! AnyHashable != attribute.value as! AnyHashable { activeAttributes[ attribute.key ] = attribute.value; break }
            else { activeAttributes[ attribute.key ] = nil; break }
        }
        toggleAttributedTextAttributes(attributes)
        updateAttributes()
        print("\n")
    }
    
    func toggleFont( _ trait: UIFontDescriptor.SymbolicTraits ) {
        if let currentFont = self.activeAttributes.first(where: { (key: NSAttributedString.Key, value: Any) in key == .font })?.value as? UIFont {
            let font = currentFont.hasTrait(trait) ? currentFont.withoutTraits(trait) : currentFont.withTraits(trait)
            self.activeAttributes[.font] = font
        }
    }
    
    //actually updates the attributes in the text
    private func toggleAttributedTextAttributes( _ attributes: [ NSAttributedString.Key : Any ]) {
        if selectedRange.length == 0 { return  }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        let mutableAttributedSubString = mutableAttributedString.attributedSubstring(from: selectedRange)
        
        for attribute in attributes {
            if attributeInRange(attribute, in: mutableAttributedSubString) <= 1 { mutableAttributedString.addAttributes(attributes, range: selectedRange) }
            else { mutableAttributedString.removeAttribute(attribute.key, range: selectedRange) }
        }
        
        print("FROM VIEWMODEL: \(mutableAttributedString), \(attributes)")
        attributedText = mutableAttributedString
    }

    
    
    //MARK: utility functions
    
    // 0 the attribute is not entirley present in the range, 1 the attribute is entirley not present, 2 the attribute is entirley present
    private func attributeInRange( _ attribute: (NSAttributedString.Key, Any), in text: NSAttributedString ) -> Int {
        var nsRangePointer = NSRange()
        
        let fullRange = NSRange(location: 0, length: text.length)
        let value = text.attribute(attribute.0, at: 0, longestEffectiveRange: &nsRangePointer, in: fullRange)
        
        if !(text.attributedSubstring(from: nsRangePointer).string == text.string) { return 0 }
        
        if value == nil { return 1 }
        if value as! AnyHashable != attribute.1 as! AnyHashable { return 1 }
        return 2
    }
    
    static func == (lhs: RichTextFieldViewModel, rhs: RichTextFieldViewModel) -> Bool {
        TextFieldViewController.getMemoryAdress(of: lhs) == TextFieldViewController.getMemoryAdress(of: rhs)
    }
    
    func copy() -> RichTextFieldViewModel {
        return RichTextFieldViewModel(self.attributedText, with: self.activeAttributes, setActiveViewModel: setActiveViewModel)
    }
}


//MARK: RichTextField
struct RichTextField: View {
    
    @EnvironmentObject var viewModel: RichTextFieldViewModel
    
    let width: CGFloat
    
    @State var size: CGSize = .zero
    
    init(in width: CGFloat = 350) {
        self.width = width
    }
    
    var body: some View {
        VStack {
//            VCRep(uuid: viewModel.uuid ) { vc in viewModel.viewController = vc }
            VCRep( size: $size, viewController: returnViewController()    )
//            .environmentObject( returnViewController() )
            .frame(width: size.width, height: size.height)
            .padding(.horizontal, -4)
            .padding(.vertical, -7)
            .background(.green)
        }
    }
    
    func returnViewController() -> TextFieldViewController {
        let viewController = TextFieldViewController(parent: viewModel, at: viewModel.selectedRange)
        viewController.width = width
        return viewController
    }
}

//MARK: VCREP
struct VCRep: UIViewControllerRepresentable {
    
//    @EnvironmentObject var viewController: TextFieldViewController
    @Binding var size: CGSize

    let viewController: TextFieldViewController
    
//    var updateVC: (TextFieldViewController) -> Void
    
    func makeUIViewController(context: Context) -> TextFieldViewController { viewController }
    
    func updateUIViewController(_ vc: TextFieldViewController, context: Context) {
        
        DispatchQueue.main.async { vc.SetViewFrames(); size = vc.size }
        
//        print( vc.parentViewModel.editing, viewController.parentViewModel.editing )
        
//        vc.textView.isSelectable = vc.parentViewModel.editing
//        vc.textView.isEditable = vc.parentViewModel.editing
        
        vc.setEditability(with: vc.parentViewModel.editing)
        
//        if vc.parentViewModel.editing != viewController.parentViewModel.editing {
//            vc.setEditability(with: viewController.parentViewModel.editing)
//            print("rung") }
        
//        if TextFieldViewController.getMemoryAdress(of: vc) != TextFieldViewController.getMemoryAdress(of: self.viewController) {
        if vc.textView.attributedText != viewController.textView.attributedText {
            
            
//            print( viewController.textView.text, vc.textView.text )
//            print( TextFieldViewController.getMemoryAdress(of: viewController.parentViewModel), TextFieldViewController.getMemoryAdress(of: vc.parentViewModel) )
//            print( viewController.parentViewModel.uuid, vc.parentViewModel.uuid )
//
            vc.textView.attributedText = viewController.textView.attributedText
            vc.textView.selectedRange = viewController.textView.selectedRange
            vc.parentViewModel = viewController.parentViewModel
            
            vc.textView.isSelectable = viewController.parentViewModel.editing
            vc.textView.isEditable = viewController.parentViewModel.editing
            
//            viewController.textView.text = viewController.text
//            vc.changeStoredText(with: viewController.textView)
////            updateVC(vc)
//            vc.SetViewFrames()
        }
    }
    
    typealias UIViewControllerType = TextFieldViewController
}

