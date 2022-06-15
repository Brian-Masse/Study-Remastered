//
//  CalculatorView.swift
//  EquationEditor
//
//  Created by Brian Masse on 6/12/22.
//

import SwiftUI


struct Calculator: View {
    
    @StateObject var viewModel: CalculatorViewModel
    
    var body: some View {
        
        GeometryReader { geo in
            
            VStack {
                EquationTextView(text: viewModel.handler.equationText)
                    .padding()
                    .frame(height: geo.size.height / 3 )
                
                
                HStack {
                    ForEach( Array(viewModel.primaryFunctions.enumerated()), id: \.offset ) { enumeration in
                        PrimaryCalculatorButton(function: enumeration.element)
                            .environmentObject(viewModel)
                    }
                }
                let width = (geo.size.width - ( 5 * 6)) / 5
                LazyVGrid(columns: [ GridItem(.adaptive(minimum: width, maximum: width), spacing: 5) ], spacing: 2 ) {
                    ForEach( Array(viewModel.functions.enumerated()), id: \.offset ) { enumeration in
                        CalculatorButton(function: enumeration.element!, shiftFunction: viewModel.shiftFuntions[enumeration.offset] ?? enumeration.element!, alphaFunction: viewModel.alphaFunctions[enumeration.offset] ?? enumeration.element! )
                            .environmentObject(viewModel)
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
            }
    }
}
