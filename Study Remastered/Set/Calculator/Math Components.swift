//
//  Math Components.swift
//  EquationEditor
//
//  Created by Brian Masse on 6/5/22.
//

import Foundation
import SwiftUI




struct EquationString: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
        if text.contains("_") { self.text.removeAll(where: {$0 == "_"}) }
    }
    
    var body: some View {
        Text( text )
    }
    
}

@ViewBuilder func component(_ index: Int, primative: EquationText) -> some View {
    EquationText.wrapEquationText(primative: primative.components[index], primatives: primative.components[index].primatives)
}


//MARK: Shapes

struct RootShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY + 3))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX - 3, y: rect.height / 1.5 ))
        path.addLine(to: CGPoint(x: rect.minX - 7, y: rect.height / 1.5 ))
        
        return path
    }
}

struct IntegralShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 5 ))
        
        path.addQuadCurve(to: CGPoint(x: rect.minX + 5, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 5 ))
        path.addLine(to: .init(x: rect.minX, y: rect.maxY - 5))
        
        path.addQuadCurve(to: CGPoint(x: rect.minX - 5, y: rect.maxY),
                          control: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

struct SigmaShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: rect.maxX, y: rect.minY + 3))
        path.addLine(to: .init(x: rect.maxX, y: rect.minY))
        path.addLine(to: .init(x: rect.minX, y: rect.minY))
        path.addLine(to: .init(x: rect.maxX - 5, y: rect.height / 2))
        path.addLine(to: .init(x: rect.minX, y: rect.maxY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY - 3))
        return path
    }
}


//MARK: functions

protocol MathComponent {
    var primative: EquationText {get set}
    var primatives: [EquationText] {get set}
}

struct Root: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack(spacing: 0) {
            Text("  ")
            component(0, primative: primative)
                .padding(3)
                .overlay(GeometryReader { geo in
                    RootShape()
                        .stroke()
            })
        }
    }
}

struct AdvancedRoot: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack(spacing: 0) {
            Text("  ")
            component(0, primative: primative)
                .minimumScaleFactor(0.5)
                .padding(.bottom, 10)
                .padding(.trailing, 2)
                .scaleEffect(x: 0.8, y: 0.8, anchor: .leading)
            component(1, primative: primative)
                .padding(3)
                .overlay(GeometryReader { geo in
                    RootShape()
                        .stroke()
            })
        }
    }
}

struct Fraction: View, MathComponent {
    
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        VStack(spacing: 0) {
            component(0, primative: primative)
                .padding(2)
                .overlay(GeometryReader { geo in
                    VStack {
                        Spacer()
                        Rectangle()
                            .offset(y: 1)
                            .frame(height: 1)
                    }
                })
            
            component(1, primative: primative)
                .padding(3)
                .overlay(GeometryReader { geo in
                    VStack {
                        Rectangle()
                            .frame(height: 1)
                        Spacer()
                    }
                })
        }
    }
}

struct Exponent: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack(spacing: 0) {
            component(0, primative: primative)
                
            VStack {
                component(1, primative: primative)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 10)
                    .scaleEffect(x: 0.8, y: 0.8, anchor: .leading)
            }
        }
    }
}

struct Log: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack(spacing: 0) {
            
            Text("log(")
            VStack {
                component(0, primative: primative)
                    .minimumScaleFactor(0.5)
                    .padding(.top, 10)
                    .scaleEffect(x: 0.8, y: 0.8, anchor: .leading)
            }
            component(1, primative: primative)
            Text(")")
        }
    }
}

struct ln: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack(spacing: 0) {
            Text("ln(")
            component(0, primative: primative)
            Text(")")
        }
    }
}

struct Trig: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    var function: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text( function + "(" )
            component(0, primative: primative)
            Text(")")
        }
    }
}

struct InvsereTrig: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    var function: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text( function + "(" )
            Text("-1")
                .minimumScaleFactor(0.5)
                .padding(.bottom, 10)
                .scaleEffect(x: 0.8, y: 0.8, anchor: .leading)
            component(0, primative: primative)
            Text(")")
        }
    }
}

struct ABS: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        component(0, primative: primative)
            .padding(3)
            .overlay(GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle().frame(width: 1)
                    Spacer()
                    Rectangle().frame(width: 1)
                }
            })
    }
}

struct limit: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack {
            VStack(spacing: 0 ) {
                Text("lim")
                HStack(spacing: 0) {
                    component(0, primative: primative)
                    Text("→")
                    component(1, primative: primative)
                }
            }
            component(2, primative: primative)
        }
    }
}

struct Derivative: View, MathComponent {
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("d")
                component(0, primative: primative)
                    .padding(3)
                    .overlay(GeometryReader { geo in
                        VStack {
                            Spacer()
                            Rectangle()
                                .offset(y: 1)
                                .frame(height: 1)
                        }
                    })
            }
            HStack(spacing: 0) {
                Text("d")
                component(1, primative: primative)
                    .padding(3)
                    .overlay(GeometryReader { geo in
                        VStack {
                            Rectangle()
                                .frame(height: 1)
                            Spacer()
                        }
                    })
            }
        }
    }
}

struct Integral: View, MathComponent {
    
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack {
            VStack {
                component(0, primative: primative)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 10)
                    .offset(y: -3)
                component(1, primative: primative)
                    .minimumScaleFactor(0.5)
                    .padding(.top, 10)
            }
            component(2, primative: primative)
        }
        .padding(2)
        .overlay(GeometryReader { geo in
            IntegralShape()
                .stroke()
        })
    }
}

struct Summation: View, MathComponent {
    
    var primative: EquationText
    var primatives: [EquationText] = []
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                component(0, primative: primative)
                SigmaShape()
                    .stroke()
                    .frame(maxWidth: 15, maxHeight: 20)
                HStack(spacing: 0) {
                    component(1, primative: primative)
                    Text("=")
                    component(2, primative: primative)
                }
            }
            component(3, primative: primative)
        }
    }
}



