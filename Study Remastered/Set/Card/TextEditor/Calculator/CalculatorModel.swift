//
//  CalculatorModel.swift
//  EquationEditor
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation

struct CalculatorModel {
    
    enum FunctionType {
        case parenthesis
        case funct
        case char
        case delete
        case move
        case shift
        case alpha
    }
    static let collectingFunctions = [ "frac", "exp" ]
    
    var handler: EquationTextHandler

    var primaryFunctions: [ CalculatorFunction ]
    var functions:       [ CalculatorFunction? ]
    var shiftFunctions: [ CalculatorFunction? ]
    var alphaFunctions: [ CalculatorFunction? ]
    
    var shift: Bool = false
    var alpha: Bool = false
    
    init( _ handler: EquationTextHandler ) {
        
        self.handler = handler
        
        let shift = CalculatorFunction( "2CND", type: .shift )
        let alpha = CalculatorFunction( "ALPHA", type: .alpha )
        let moveLeft = CalculatorFunction("< ", type: .move)
        let moveRight = CalculatorFunction(" >", type: .move)
        let delete = CalculatorFunction("delete", type: .delete)
        
        primaryFunctions =  [ shift, alpha, moveLeft, moveRight, delete ]
        functions = CalculatorModel.createFunctionList( CalculatorModel.primaryFunctions )
        shiftFunctions = CalculatorModel.createFunctionList( CalculatorModel.shiftFunctions )
        alphaFunctions = CalculatorModel.createFunctionList( CalculatorModel.alphaFunctions )
    }
    
    static func createFunctionList(_ list: [ (String, CalculatorModel.FunctionType, String?, Int?)? ]) -> [CalculatorFunction?] {
        
        var returningList: [CalculatorFunction?] = []
        for enumeration in list.enumerated() {
            if enumeration.element == nil { returningList.append(nil) }
            else {
                let value = enumeration.element!.2 == nil ? enumeration.element!.0 : enumeration.element!.2
                let element = enumeration.element!
                let function = CalculatorFunction(element.0, type: element.1, value: value, componentsCount: element.3)
                returningList.append(function)
            }
        }
        return returningList
        
    }
}



class CalculatorViewModel: ObservableObject {
    
    @Published var model: CalculatorModel
    
    var handler: EquationTextHandler {
        get { model.handler }
    }
    
    var primaryFunctions: [CalculatorFunction] { model.primaryFunctions }
    var functions: [CalculatorFunction?] { model.functions }
    var shiftFuntions: [CalculatorFunction?] { model.shiftFunctions }
    var alphaFunctions: [CalculatorFunction?] { model.alphaFunctions }

    
    init(_ model: CalculatorModel) {
        self.model = model
    }
    
    func callButtonFunction( _ function: CalculatorFunction ) {
        switch function.functionType {
        case .funct         : model.handler.addFunc(type: function.value!, componentCount: function.componentCount!)
        case .char          : model.handler.addString(function.value!)
        case .delete        : model.handler.delete()
        case .move          : if function.name == "< " { model.handler.moveCursor(direction: .left) } else { model.handler.moveCursor(direction: .right) }
        case .parenthesis   : model.handler.insertParenthesis(function.name)
        case .shift         : toggleShift()
        case .alpha         : toggleAlpha()
        }
    }
    
    func toggleShift() {
        model.shift.toggle()
        if model.shift { model.alpha = false }
    }
    
    func toggleAlpha() {
        model.alpha.toggle()
        if model.alpha { model.shift = false }
    }
}



class CalculatorFunction {
    
    let name: String
    let functionType: CalculatorModel.FunctionType
    
    let value: String?
    let componentCount: Int?
    
    init(_ name: String, type: CalculatorModel.FunctionType, value: String? = nil,       componentsCount: Int? = nil) {
        self.name = name
        self.functionType = type
        
        self.value = value
        self.componentCount = componentsCount
    }
}
