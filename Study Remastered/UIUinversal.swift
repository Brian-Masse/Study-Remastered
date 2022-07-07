//
//  UIUinversal.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/6/22.
//

import Foundation
import SwiftUI


struct GlobalTextConstants {
    static let fontFamily = "Helvetica"
    static let fontSize: CGFloat = 12
    
    static let UIFontFamily = "Goku"
}

struct UIText: View {

    let text: String
    
    init( _ text: String ) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.custom(GlobalTextConstants.UIFontFamily, size: 20))
    }
}

struct UIToggle: View {
    
    let name: String
    let isActive: () -> Bool
    let function: () -> Void
    
    let aspectRatio: CGFloat?
    
    init( _ name: String, aspectRatio: CGFloat? = nil, isActive: @escaping () -> Bool, function: @escaping () -> Void) {
        self.name = name
        self.isActive = isActive
        self.function = function
        self.aspectRatio = aspectRatio
    }
    
    func correctName() -> String { name.uppercased() }
    
    var body: some View {
        StyledUIText(correctName(), aspectRatio: 1,
                     bgColor: isActive() ? Colors.UIprimaryCream : Colors.UIprimaryGrey,
                     fgColor: isActive() ? Colors.UIprimaryGrey : Colors.UIprimaryCream,
                     sColor: isActive() ? Colors.UIprimaryCream : Colors.shadow)
            .onTapGesture { function() }
    }
}

struct StyledUIText: View {
    
    let backgroundColor: Color
    let foregroundColor: Color
    let shadowColor: Color
    
    let text: String
    let aspectRatio: CGFloat?
    let symbol: String
    
    init( _ text: String = "", symbol: String = "", aspectRatio: CGFloat? = nil, bgColor: Color = Colors.UIprimaryGrey, fgColor: Color = Colors.UIprimaryCream, sColor: Color = Colors.shadow) {
        self.backgroundColor = bgColor
        self.foregroundColor = fgColor
        self.shadowColor = sColor
        
        self.text = text
        self.aspectRatio = aspectRatio
        self.symbol = symbol
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor( backgroundColor )
                .cornerRadius(7)
//                .aspectRatio(aspectRatio, contentMode: .fit)
                .shadow(color: shadowColor, radius: 3, x: 0, y: 3)
            
            HStack {
                if text != "" { UIText(text) } 
                if symbol != "" { Image(systemName: symbol).resizable().aspectRatio(contentMode: .fit).minimumScaleFactor(1) }
            }
            .padding(5)
//            .aspectRatio(aspectRatio, contentMode: .fit)  
            .foregroundColor( foregroundColor )
        }
    }
}

struct TextureFill: View {
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Colors.fillPrimaryGrey)
            Image("FillDust")
                .centerCropped()
                .opacity(0.2)
        }
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

struct WrappedHStack<Content: View>: View {
    
    let itemsCount: Int
    let geo: GeometryProxy
    let content: ( Int ) -> Content
    let spacing: CGFloat

    init( _ itemsCount: Int, in geo: GeometryProxy, spacing: CGFloat = 5,content: @escaping (Int) -> Content ) {
        self.itemsCount = itemsCount
        self.geo = geo
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        display(geo, itemsCount, spacing, content)
    }
    
    func display(_ geo: GeometryProxy, _ itemsCount: Int, _ spacing: CGFloat, _ content: @escaping (Int) -> Content) -> some View {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var previousRowHeight: CGFloat = 0

        return ZStack(alignment: .leading) {
            
            ForEach( 0..<itemsCount, id: \.self ) { index in
                
                content(index)
                    .alignmentGuide(HorizontalAlignment.leading) { d in
                        if abs(geo.size.width + width) < d.width {
                            width = 0
                            height -= (previousRowHeight + (spacing / 2))
                            previousRowHeight = 0
                        }
                        previousRowHeight = max(d.height, previousRowHeight)
                        let offSet = width
                        if index == itemsCount - 1 { width = 0 }
                        else { width -= (d.width + spacing) }

                        return offSet
                    }
                    .alignmentGuide(VerticalAlignment.center) { d in
                        let offset = height + (d.height / 2)
                        if index == itemsCount - 1 { height = 0 }
                        return offset
                    }
                }
            }
    }

}
