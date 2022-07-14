//
//  CardTextView.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/6/22.
//

import Foundation
import SwiftUI

struct CardTextView: View {
    
    @EnvironmentObject var cardTextViewModel: CardTextViewModel
    
    let geo: GeometryProxy
    
    var body: some View {
        WrappedHStack(cardTextViewModel.componentCount, in: geo) { index in createStringPiece(at: index) }
    }
    
    func createStringPiece(at index: Int) -> some View {
        let handlerIndex = Int(floor(Double(index / 2)))
        if (index % 2) == 0 {
            if !cardTextViewModel.editingEquation {
                let viewModel = cardTextViewModel.textFieldViewModels[ handlerIndex ]
                let textField = RichTextField()
                
                return AnyView(textField
                    .environmentObject(viewModel)
                    .onTapGesture() { if cardTextViewModel.editing {
                        cardTextViewModel.activeViewModel = viewModel
                        cardTextViewModel.viewModelIndex = handlerIndex
                        cardTextViewModel.editingEquation = false
                    }})
            }
        }else{
            if !cardTextViewModel.editingEquation || cardTextViewModel.handlerIndex == handlerIndex {
                let handler = cardTextViewModel.equationHandlers[ handlerIndex ]

                return AnyView(
                    VStack {
                        EquationTextView(text: handler.equationText)
                            .fixedSize()
                            .padding(3)
                            .padding(.top, cardTextViewModel.editingEquation ? 15 : 0)
                            .overlay(GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 5))
                                    .foregroundColor(Colors.UIprimaryCream)
                            })
                            .onTapGesture() { if cardTextViewModel.editing {
                                cardTextViewModel.editingEquation = true
                                cardTextViewModel.handlerIndex = handlerIndex
                                cardTextViewModel.activeViewModel = handler.textFieldViewModel
                                
                                ContentView.calculator.viewModel = CalculatorViewModel( CalculatorModel(handler ))
                                ContentView.calculatorIsActive = true
                            }}
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
