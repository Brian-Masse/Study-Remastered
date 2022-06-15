//
//  CalculatorModelExtension.swift
//  EquationEditor
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation

extension CalculatorModel {
    
    static let primaryFunctions: [ ( String, CalculatorModel.FunctionType, String?, Int? ) ] = [
        ("x", .char, nil, nil), ("T", .char, nil, nil), ("n", .char, nil, nil), ("θ", .char, nil, nil), ("π", .char, nil, nil),
        ("ABS", .funct, "abs", 1), ("LIM", .funct, "lim", 3), ( "dy/dx", .funct, "deriv", 2 ), ("∫", .funct, "integ", 3), ("∑", .funct, "sum", 4),
        ("√", .funct, "root", 1), ("SIN", .funct, "sin", 1), ("COS", .funct, "cos", 1), ("TAN", .funct, "tan", 1), ("^", .funct, "exp", 2),
        ("x√", .funct, "advRoot", 2), ("CSC", .funct, "csc", 1), ("SEC", .funct, "sec", 1), ("COT", .funct, "cot", 1), ("/", .funct, "frac", 2),
        ("log", .funct, "log", 2),  ("9", .char, nil, nil),  ("8", .char, nil, nil),  ("7", .char, nil, nil), (" • ", .char, nil, nil),
        ("ln", .funct, "ln", 1),  ("6", .char, nil, nil),  ("5", .char, nil, nil),  ("4", .char, nil, nil), (" - ", .char, nil, nil),
        ("=", .char, nil, nil),  ("3", .char, nil, nil),  ("2", .char, nil, nil),  ("1", .char, nil, nil), (" + ", .char, nil, nil),
        ("-", .char, nil, nil),  ("0", .char, nil, nil),  (".", .char, nil, nil),  ("(", .parenthesis, nil, nil), (")", .parenthesis, nil, nil)
    ]
    
    static let shiftFunctions: [ ( String, CalculatorModel.FunctionType, String?, Int? )? ] = [
        nil, nil, nil, nil, nil,
        nil, nil, ("d", .char, nil, nil), ("∫", .char, nil, nil), ("∑", .char, nil, nil),
        ("x^2", .char, "#<exp>[\\[_]\\[2]]", nil), ("ARCSIN", .funct, "Asin", 1), ("ARCCOS", .funct, "Acos", 1), ("ARCTAN", .funct,  "Atan", 1), nil,
        ("x^-1", .char, "#<exp>[\\[_]\\[-1]]", nil), ("ARCCSC", .funct, "Acsc", 1), ("ARCSEC", .funct, "Asec", 1), ("ARCCOT", .funct, "Acot", 1), nil,
        ("10^x", .char, "#<exp>[\\[10]\\[_]]", nil), ("u", .char, nil, nil), ("v", .char, nil, nil), ("w", .char, nil, nil), nil,
        ("e^x", .char, "#<exp>[\\[e]\\[_]]", nil), nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
    ]
    
    static let alphaFunctions: [ ( String, CalculatorModel.FunctionType, String?, Int? )? ] = [
        ("A", .char, nil, nil), ("B", .char, nil, nil), ("C", .char, nil, nil), ("D", .char, nil, nil), ("E", .char, nil, nil),
        ("F", .char, nil, nil), ("G", .char, nil, nil), ("H", .char, nil, nil), ("I", .char, nil, nil), ("J", .char, nil, nil),
        ("K", .char, nil, nil), ("L", .char, nil, nil), ("M", .char, nil, nil), ("N", .char, nil, nil), ("O", .char, nil, nil),
        ("P", .char, nil, nil), ("Q", .char, nil, nil), ("R", .char, nil, nil), ("S", .char, nil, nil), ("T", .char, nil, nil),
        ("U", .char, nil, nil), ("V", .char, nil, nil), ("W", .char, nil, nil), ("X", .char, nil, nil), ("Y", .char, nil, nil),
        ("Z", .char, nil, nil), nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil,
    ]
    
}
