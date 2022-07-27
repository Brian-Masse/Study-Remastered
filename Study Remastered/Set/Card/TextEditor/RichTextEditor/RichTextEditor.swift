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
     
    var parentViewModel: RichTextFieldViewModel!
    var width: CGFloat = 0
    var size: CGSize = .zero
    
    init() { super.init(nibName: nil, bundle: nil) }
    
    init(parent: RichTextFieldViewModel, at selectedRange: NSRange) {
        super.init(nibName: nil, bundle: nil)
        self.parentViewModel = parent
        
        self.textView.attributedText = parent.attributedText
        self.textView.selectedRange = selectedRange
    
    }
    
    override func viewDidAppear(_ animated: Bool) { }
    override func viewDidLayoutSubviews() { SetViewFrames() }
    
    override func viewDidLoad() {
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(textView)
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
    
    func setEditability(with allowsEdits: Bool) { textView.isUserInteractionEnabled = allowsEdits }
    
    
    //MARK: TextView Functions

    func textViewDidChangeSelection(_ textView: UITextView) {
        parentViewModel.selectedRange = textView.selectedRange
        if textView.text.count == parentViewModel.text.count { parentViewModel.updateAttributes() }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        parentViewModel.setAttributedText(with: textView.attributedText)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) { }
    func textViewDidEndEditing(_ textView: UITextView) { }
    
    //MARK: Utility functions
    
    static func getMemoryAdress<T: AnyObject>(of object: T) -> String { "\(Unmanaged.passRetained( object ).toOpaque())" }

    func getDesiredMemoryAdress() -> String { "\(Unmanaged.passRetained( self.view ).toOpaque())" }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
