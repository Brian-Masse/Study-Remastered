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
    
    @Published var viewController: TextFieldViewController { didSet {
        defineObserver()
        viewController.parentViewModel = self
    } }
    
    @Published var activeAttributes: [NSAttributedString.Key: Any] = [:] { didSet {
        let name = NSNotification.Name(RichTextFieldViewModel.attributeDidChangeKey)
        NotificationCenter.default.post(name: name, object: nil)
    } }
    
    @Published var activeFont: String = GlobalTextConstants.fontFamily
    @Published var activeFontSize: CGFloat = GlobalTextConstants.fontSize
    
    var observer: AnyCancellable!
    var setActiveViewModel: ((RichTextFieldViewModel) -> Void)?
    
    init( _ text: String, with activeAttributes: [NSAttributedString.Key: Any]? = nil ) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        viewController = .init()
        viewController = TextFieldViewController(text, parent: self)
        defineObserver()
    }
    
    init( _ attributedText: NSAttributedString, with activeAttributes: [NSAttributedString.Key: Any]? = nil, setActiveViewModel: ((RichTextFieldViewModel) -> Void)? = nil) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        self.viewController = .init()
        self.setActiveViewModel = setActiveViewModel
    
        viewController = TextFieldViewController(attributedText.string, parent: self)
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
    
    func copy() -> RichTextFieldViewModel {
        return RichTextFieldViewModel(self.viewController.textView.attributedText, with: self.activeAttributes, setActiveViewModel: setActiveViewModel)
    }
}



struct RichTextField: View {
    
    @EnvironmentObject var viewModel: RichTextFieldViewModel
    
    let width: CGFloat
    
    init(in width: CGFloat = 350) {
        self.width = width
    }
    
    var body: some View {
        VStack {
            VCRep() { vc in viewModel.viewController = vc }
            .environmentObject( returnViewController() )
            .frame(width: viewModel.viewController.size.width, height: viewModel.viewController.size.height)
            .padding(.horizontal, -4)
            .padding(.vertical, -7)
//            .background(Rectangle().foregroundColor(.red))
        }
    }
    
    func returnViewController() -> TextFieldViewController {
        viewModel.viewController.width = width
        return viewModel.viewController
    }
}

//MARK: VCREP
struct VCRep: UIViewControllerRepresentable {
    
    @EnvironmentObject var viewController: TextFieldViewController
    
    var updateVC: (TextFieldViewController) -> Void
    
    func makeUIViewController(context: Context) -> TextFieldViewController { viewController }
    
    func updateUIViewController(_ vc: TextFieldViewController, context: Context) {
        if TextFieldViewController.getMemoryAdress(of: vc) != TextFieldViewController.getMemoryAdress(of: self.viewController) {
            viewController.textView.text = viewController.text
            vc.changeStoredText(with: viewController.textView)
            updateVC(vc)
            vc.SetViewFrames()
        }
    }

    typealias UIViewControllerType = TextFieldViewController
}

