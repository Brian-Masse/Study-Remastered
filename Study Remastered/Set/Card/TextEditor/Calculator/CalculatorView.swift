//
//  CalculatorView.swift
//  EquationEditor
//
//  Created by Brian Masse on 6/12/22.
//

import SwiftUI


struct Calculator: View {
    
    @EnvironmentObject var appViewModel: StudyRemasteredViewModel
    
    let shouldDisplayText: Bool
    
    var body: some View {
            
        let calculatorViewModel = CalculatorViewModel(CalculatorModel( appViewModel.activeCalculatorHandler ))
        let cardTextViewModel = appViewModel.activeCardText
        
        if appViewModel.calculatorIsActive {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    
                    if shouldDisplayText {
                        EquationTextView(text: calculatorViewModel.handler.equationText)
                            .padding()
                            .frame(height: geo.size.height / 3 )
                    }
                    
                    StyledUIText("done", symbol: "checkmark.rectangle").onTapGesture { cardTextViewModel.endEditingEquation() }
                        .frame(width: geo.size.width - 10, height: 20)
                
                    HStack {
                        ForEach( Array(calculatorViewModel.primaryFunctions.enumerated()), id: \.offset ) { enumeration in
                            PrimaryCalculatorButton(function: enumeration.element)
                                .environmentObject(calculatorViewModel)
                        }
                    }
                    let width = (geo.size.width - ( 6 * 6)) / 5
                
                    LazyVGrid(columns: [ GridItem(.adaptive(minimum: width, maximum: width), spacing: 5) ], spacing: 2 ) {
                        ForEach( Array(calculatorViewModel.functions.enumerated()), id: \.offset ) { enumeration in
                            CalculatorButton(function: enumeration.element!, shiftFunction: calculatorViewModel.shiftFuntions[enumeration.offset] ?? enumeration.element!, alphaFunction: calculatorViewModel.alphaFunctions[enumeration.offset] ?? enumeration.element! )
                                .environmentObject(calculatorViewModel)
                        }
                    }
                }
            }
        }
    }
}

struct CalculatorButton: View {
    
    @EnvironmentObject var viewModel: CalculatorViewModel
    
    let function: CalculatorFunction
    let shiftFunction: CalculatorFunction
    let alphaFunction: CalculatorFunction
    
    func returnMode() -> CalculatorFunction {
        if viewModel.model.shift { return shiftFunction }
        else if viewModel.model.alpha { return alphaFunction }
        return function
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if function.name != shiftFunction.name { Text(shiftFunction.name).minimumScaleFactor(0.5) }
                Spacer()
                if function.name != alphaFunction.name { Text(alphaFunction.name).minimumScaleFactor(0.5) }
            }
            .padding([.leading, .trailing], 3)
            .frame(height: 10)
            ZStack {
                Rectangle()
                    .frame(height: 35)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                Text( returnMode().name )
                    .padding(7)
                    .foregroundColor(.white)
                    .lineLimit(0)
                    .minimumScaleFactor(0.5)
            }.onTapGesture {
                viewModel.callButtonFunction( returnMode() )
                viewModel.handler.equationText.setup()
            }
        }
    }
}


struct PrimaryCalculatorButton: View {
    
    @EnvironmentObject var viewModel: CalculatorViewModel
    
    let function: CalculatorFunction
    
    var body: some View {
        Text( function.name )
            .padding()
            .foregroundColor(.white)
            .background {
                Rectangle()
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .onTapGesture {
                viewModel.callButtonFunction( function )
                viewModel.handler.equationText.setup()
            }
    }
}
