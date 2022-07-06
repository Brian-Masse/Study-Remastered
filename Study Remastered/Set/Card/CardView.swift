//
//  CardView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI
import Introspect


var globalCounter = 0

struct CardView: View {
    
    @ObservedObject var viewModel: CardViewModel
    @State var editingText: String = ""
    
    let commitEdits: (String) -> Void
    let editing: Bool
    
    init( _ viewModel: CardViewModel, editing: Bool = false, commitEdits: @escaping (String) -> Void = { text in } ) {
        self.viewModel = viewModel
        self.editing = editing
        self.commitEdits = commitEdits
    }
    
    var body: some View {
        CardText()
            .environmentObject(viewModel)
            .environmentObject(viewModel.frontTextViewModel)
    }
    
    struct CardText: View {
        
        @State var editingEquation = false
        @State var handlerIndex = 0
        
        @EnvironmentObject var cardViewModel: CardViewModel
        @EnvironmentObject var cardTextViewModel: CardTextViewModel
        
        var body: some View {
            GeometryReader { geo in
                VStack {
                    
                    RichTextEditorControls()
                        .environmentObject( cardTextViewModel.activeViewModel )
                    
                    
    //                HStack(spacing: 0)
    //                LazyVGrid(columns: [ GridItem(.adaptive(minimum: width, maximum: width), spacing: 5) ], spacing: 2 )
//                    LazyVGrid(columns: [ GridItem(.adaptive(minimum: 5, maximum: geo.size.width), spacing: 5) ], alignment: .leading, spacing: 2 ) {
//                    HStack {
//
//                        Text("hello")
////                            .alignmentGuide(.trailing, computeValue: { _ in  50 })

//                        ForEach( 0..<cardTextViewModel.componentCount, id: \.self ) { index in
                            
                    WrappedHStack(cardTextViewModel.componentCount, in: geo) { index in
                                
                               createStringPiece(at: index)
//                    }
//                        }
                    }
//                    .background(Rectangle().foregroundColor( .blue ))
                    
                    Text( "add Math Equation" )
                        .background {
                            Rectangle()
                                .foregroundColor(.green)
                        }
                        .onTapGesture { cardTextViewModel.addMathEquation(at: cardTextViewModel.activeViewModel ) }
                    
                    if editingEquation {
                        Calculator(viewModel: CalculatorViewModel( CalculatorModel( cardTextViewModel.equationHandlers[handlerIndex] ) ), shouldDisplayText: false)
                    }
                    
                    
                }
            }
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
                        editingEquation = false
                    })
                    
            }else{
                let handler = cardTextViewModel.equationHandlers[ handlerIndex ]

                return AnyView(EquationTextView(text: handler.equationText)
                    .fixedSize()
                    .padding(3)
                    .overlay(GeometryReader { geo in
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 2,
                                                       lineCap: .round,
                                                       lineJoin: .round,
                                                       miterLimit: 5))

                    })
                    .onTapGesture() {
                        editingEquation = true
                        self.handlerIndex = handlerIndex
                        
                        cardTextViewModel.activeViewModel = handler.textFieldViewModel
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            cardTextViewModel.deleteMathEquation(at: handlerIndex)
                            editingEquation = false
                        } label: {  Label("Delete Math Equation", systemImage: "delete.backward") }
                    })
            }
        }
    }
    
    struct Side: View {
        
        @EnvironmentObject var viewModel: CardViewModel
        var text: String
        
        var body: some View {
            ZStack(alignment: .center) {
                
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .frame(width: globalFrame.width * 0.4, height: globalFrame.height * 0.4)
                
                VStack {
                    Text( text )
                    
                    Text("Check Match")
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            Rectangle()
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    
                    .onTapGesture {
                        viewModel.checkMatch()
                    }
                }
            }
        }
    }
}
