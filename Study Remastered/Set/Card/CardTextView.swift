//
//  CardTextView.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/6/22.
//

import Foundation
import SwiftUI

struct CardTextView: View {
    
    @EnvironmentObject var appViewModel: StudyRemasteredViewModel
    @EnvironmentObject var cardTextViewModel: CardTextViewModel
    
    @Binding var size: CGSize
    
    let width: CGFloat
    
    var body: some View {
        VStack {
            SubViewGeometryReader(size: $size) {
                WrappedHStack(cardTextViewModel.componentCount, in: width) { index in createStringPiece(at: index) }
            }
        }
    }
    
    func createStringPiece(at index: Int) -> some View {
        let handlerIndex = Int(floor(Double(index / 2)))
        if (index % 2) == 0 {
    
            if !cardTextViewModel.editingEquation {
                let viewModel = cardTextViewModel.textFieldViewModels[ handlerIndex ]
                
                return AnyView(
                    VStack {
//                        Text(viewModel.attributedText.string)
                        RichTextField(in: width)
                        .environmentObject(viewModel)
                        .onTapGesture() { if cardTextViewModel.editing {
                            cardTextViewModel.activeViewModel = viewModel
                            cardTextViewModel.viewModelIndex = handlerIndex
                            cardTextViewModel.endEditingEquation()
                        }}
                    })
            }
        }else{
            if !cardTextViewModel.editingEquation || cardTextViewModel.handlerIndex == handlerIndex {
                let handler = cardTextViewModel.equationHandlers[ handlerIndex ]

                return AnyView(
                    VStack {
                        EquationTextView(text: handler.equationText)
                            .fixedSize()
                            .padding(3)
//                            .padding(.top, cardTextViewModel.editingEquation ? 15 : 0)
                            .overlay(GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 5))
                                    .foregroundColor(Colors.UIprimaryCream)
                            })
                            .onTapGesture() { cardTextViewModel.beginEditingEquation(at: handlerIndex) }
                            .contextMenu {
                                Button(role: .destructive) { if cardTextViewModel.editing {
                                    cardTextViewModel.deleteMathEquation(at: handlerIndex)
                                    cardTextViewModel.editingEquation = false
                                }} label: {  Label("Delete Math Equation", systemImage: "delete.backward") }
                            }
                        if cardTextViewModel.editingEquation { Spacer() }
                    })
            }
        }
        return AnyView(Text(""))
    }
}
