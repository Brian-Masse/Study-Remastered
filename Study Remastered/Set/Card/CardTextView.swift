//
//  CardTextView.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/6/22.
//

import Foundation
import SwiftUI

struct CardText: View {
    
    @State var handlerIndex = 0
    
    @EnvironmentObject var cardTextViewModel: CardTextViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack() {
                
                if cardTextViewModel.editingEquation {
                    
                    VStack {
                        Spacer()
                        let handler = cardTextViewModel.equationHandlers[handlerIndex]
                        EquationTextView(text: handler.equationText )
                        Calculator(viewModel: CalculatorViewModel( CalculatorModel( handler ) ), shouldDisplayText: false)
                    }
                }
                else { WrappedHStack(cardTextViewModel.componentCount, in: geo) { index in createStringPiece(at: index) } }
                Rectangle().foregroundColor(.clear)
            }
        }
//        .background(Rectangle().foregroundColor(.red))
    }
    
    func createStringPiece(at index: Int) -> some View {
        let handlerIndex = Int(floor(Double(index / 2)))
        if (index % 2) == 0 {

            let viewModel = cardTextViewModel.textFieldViewModels[ handlerIndex ]
            let textField = RichTextField()
            
            return AnyView(textField
                .environmentObject(viewModel)
                .onTapGesture() {
                    cardTextViewModel.activeViewModel = viewModel
                    cardTextViewModel.editingEquation = false
                })
                
        }else{
            let handler = cardTextViewModel.equationHandlers[ handlerIndex ]

            return AnyView(EquationTextView(text: handler.equationText)
                .fixedSize()
                .padding(3)
                .overlay(GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 5))
                        .foregroundColor(Colors.UIprimaryCream)
                })
                .onTapGesture() {
                    cardTextViewModel.editingEquation = true
                    self.handlerIndex = handlerIndex
                    
                    cardTextViewModel.activeViewModel = handler.textFieldViewModel
                }
                .contextMenu {
                    Button(role: .destructive) {
                        cardTextViewModel.deleteMathEquation(at: handlerIndex)
                        cardTextViewModel.editingEquation = false
                    } label: {  Label("Delete Math Equation", systemImage: "delete.backward") }
                })
        }
    }
}
