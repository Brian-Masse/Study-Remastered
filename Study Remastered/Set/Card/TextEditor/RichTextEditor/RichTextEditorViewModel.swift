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
    
//    @Published var viewController: TextFieldViewController { didSet {
//        defineObserver()
//        viewController.parentViewModel = self
//    } }
    
    @Published var attributedText: NSAttributedString
    
    var text: String { attributedText.string }
    
    @Published var activeAttributes: [NSAttributedString.Key: Any] = [:] { didSet {
        let name = NSNotification.Name(RichTextFieldViewModel.attributeDidChangeKey)
        NotificationCenter.default.post(name: name, object: nil)
    } }
    
    var activeSelectedRange: NSRange = .init()
    @Published var activeFont: String = GlobalTextConstants.fontFamily
    @Published var activeFontSize: CGFloat = GlobalTextConstants.fontSize
    
    var observer: AnyCancellable!
    var setActiveViewModel: ((RichTextFieldViewModel) -> Void)?
    
    let uuid: UUID
    
    init( _ text: String, with activeAttributes: [NSAttributedString.Key: Any]? = nil ) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
        uuid = UUID()
        
        
        self.attributedText = NSAttributedString(string: text)
        
        print( "initializing a viewModel with: \( TextFieldViewController.getMemoryAdress(of: self) ) [\(self.text)]" )
        
//        viewController = .init()
//        viewController = TextFieldViewController(text, parent: self)
//        defineObserver()

    }
    
    init( _ attributedText: NSAttributedString, with activeAttributes: [NSAttributedString.Key: Any]? = nil, setActiveViewModel: ((RichTextFieldViewModel) -> Void)? = nil) {
        if let safeAttributes = activeAttributes { self.activeAttributes = safeAttributes }
//        self.viewController = .init()
        self.setActiveViewModel = setActiveViewModel
    
        uuid = UUID()
        self.attributedText = attributedText
        
        print( "initializing a viewModel with: \( TextFieldViewController.getMemoryAdress(of: self) ) [\(self.text)]" )
//        viewController = TextFieldViewController(attributedText.string, parent: self)
//        viewController.textView.attributedText = attributedText
//        defineObserver()
    }
    
//    func defineObserver() { observer = viewController.objectWillChange.sink() { self.objectWillChange.send() } }
    
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
//        if let currentFont = self.activeAttributes.first(where: { (key: NSAttributedString.Key, value: Any) in key == .font })?.value as? UIFont {
//            let font = currentFont.hasTrait(trait) ? currentFont.withoutTraits(trait) : currentFont.withTraits(trait)
//            self.activeAttributes[.font] = font
//        }else {
//            let font = viewController.getFont()!.withTraits(trait)
//            self.activeAttributes[.font] = font
//        }
    }
    
    static func == (lhs: RichTextFieldViewModel, rhs: RichTextFieldViewModel) -> Bool {
        TextFieldViewController.getMemoryAdress(of: lhs) == TextFieldViewController.getMemoryAdress(of: rhs)
    }
    
    func copy() -> RichTextFieldViewModel {
        return RichTextFieldViewModel(self.attributedText, with: self.activeAttributes, setActiveViewModel: setActiveViewModel)
    }
}



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
        let viewController = TextFieldViewController(parent: viewModel, at: viewModel.activeSelectedRange)
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
        
//        if TextFieldViewController.getMemoryAdress(of: vc) != TextFieldViewController.getMemoryAdress(of: self.viewController) {
        if vc.textView.text != viewController.textView.text {
            
            
//            print( viewController.textView.text, vc.textView.text )
//            print( TextFieldViewController.getMemoryAdress(of: viewController.parentViewModel), TextFieldViewController.getMemoryAdress(of: vc.parentViewModel) )
//            print( viewController.parentViewModel.uuid, vc.parentViewModel.uuid )
//            
            vc.textView.attributedText = viewController.textView.attributedText
            vc.parentViewModel = viewController.parentViewModel
            
//            viewController.textView.text = viewController.text
//            vc.changeStoredText(with: viewController.textView)
////            updateVC(vc)
//            vc.SetViewFrames()
        }
    }
    
    typealias UIViewControllerType = TextFieldViewController
}

