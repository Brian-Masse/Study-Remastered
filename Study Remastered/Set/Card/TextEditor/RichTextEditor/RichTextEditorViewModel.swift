//
//  RichTextEditorViewmodel.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/5/22.
//

import Foundation
import SwiftUI
import Combine

//MARK: RichTextField
class RichTextFieldViewModel: ObservableObject, Equatable {
    
    static let attributeDidChangeKey: String = "Masse.Brian.attributeDidChange"
    
    @Published var viewController: TextFieldViewController { didSet {
        defineObserver()
        viewController.parentViewModel = self
    } }
    
    @Published var activeAttributes: [NSAttributedString.Key: Any] = [:] { didSet {
        let name = NSNotification.Name(RichTextFieldViewModel.attributeDidChangeKey)
        NotificationCenter.default.post(name: name, object: nil)
    } }
    
    
    var observer: AnyCancellable!
    var setActiveViewModel: ((RichTextFieldViewModel) -> Void)?
    
    init( _ text: String, editable: Bool = true, with activeAttributes: [NSAttributedString.Key: Any]? = nil ) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        viewController = .init()
        viewController = TextFieldViewController(text, parent: self, editable: editable)
        defineObserver()
    }
    
    init( _ attributedText: NSAttributedString, editable: Bool = true, with activeAttributes: [NSAttributedString.Key: Any]? = nil, setActiveViewModel: ((RichTextFieldViewModel) -> Void)? = nil) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        self.viewController = .init()
        self.setActiveViewModel = setActiveViewModel
    
        viewController = TextFieldViewController(attributedText.string, parent: self, editable: editable)
        viewController.textView.attributedText = attributedText
        defineObserver()
    }
    
    func defineObserver() { observer = viewController.objectWillChange.sink() { self.objectWillChange.send() } }
    
    func setAttributes( _ attributes: [ NSAttributedString.Key : Any ] ) {
        activeAttributes = attributes
    }
    
    func toggleAttributes( _ attributes: [ NSAttributedString.Key : Any ] ) {
        for attribute in attributes {
            if activeAttributes[ attribute.key ] == nil { activeAttributes[ attribute.key ] = attribute.value; return }
            if activeAttributes[ attribute.key ] as! AnyHashable != attribute.value as! AnyHashable { activeAttributes[ attribute.key ] = attribute.value; return }
            else { activeAttributes[ attribute.key ] = nil; return }
        }
    }
    
    func toggleFont( _ trait: UIFontDescriptor.SymbolicTraits ) {
        if let currentFont = self.activeAttributes.first(where: { (key: NSAttributedString.Key, value: Any) in key == .font })?.value as? UIFont {
            let font = currentFont.hasTrait(trait) ? currentFont.withoutTraits(trait) : currentFont.withTraits(trait)
            self.activeAttributes[.font] = font
        }else {
            let font = viewController.getFont()!.withTraits(trait)
            self.activeAttributes[.font] = font
        }
    }
    
    static func == (lhs: RichTextFieldViewModel, rhs: RichTextFieldViewModel) -> Bool {
        TextFieldViewController.getMemoryAdress(of: lhs) == TextFieldViewController.getMemoryAdress(of: rhs)
    }
}



struct RichTextField: View {
    
    @EnvironmentObject var viewModel: RichTextFieldViewModel
    
    var body: some View {
        VStack {
            VCRep() { vc in viewModel.viewController = vc }
            .environmentObject(viewModel.viewController)
            .frame(width: viewModel.viewController.size.width, height: viewModel.viewController.size.height)
            .padding(.horizontal, -4)
            .padding(.vertical, -7)
        }
    }
}

//MARK: VCREP
struct VCRep: UIViewControllerRepresentable {
    
    @EnvironmentObject var viewController: TextFieldViewController
    
    var updateVC: (TextFieldViewController) -> Void
    
    func makeUIViewController(context: Context) -> TextFieldViewController { viewController }
    
    func updateUIViewController(_ vc: TextFieldViewController, context: Context) {
        
        if TextFieldViewController.getMemoryAdress(of: vc) != TextFieldViewController.getMemoryAdress(of: self.viewController) {
        
            vc.changeStoredText(with: viewController.textView)
            updateVC(vc)
            vc.SetViewFrames()
        }
    }

    typealias UIViewControllerType = TextFieldViewController
}

