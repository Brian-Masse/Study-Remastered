//
//  Animations.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/28/22.
//

import Foundation
import SwiftUI


struct VerticalSlide: AnimatableModifier {
    
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
    }
}

extension AnyTransition {
    
    static func verticalSlide(offSet: CGFloat) -> AnyTransition {
        return AnyTransition.modifier(active: VerticalSlide(offset: offSet), identity:  VerticalSlide(offset: 0))
    }
}

