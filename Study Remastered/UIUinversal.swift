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

struct NamedButton: View {
    
    enum Direction {
        case horizontal
        case vertical
    }
    
    let alignment: Direction
    let text: String
    let systemImage: String
    
    init( _ text: String, and systemImage: String, oriented alignment: Direction ) {
        self.text = text
        self.systemImage = systemImage
        self.alignment = alignment
    }
    
    var body: some View {
        if alignment == .vertical {
            VStack {
                Image(systemName: systemImage)
                Text(text)
            }
        }else {
            HStack {
                Text(text)
                Image(systemName: systemImage)
            }
        }
        
        
    }
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

struct VerticalSpace: View {
    let size: CGFloat
    
    var body: some View {
        Rectangle()
            .frame(height: size)
            .foregroundColor(.clear)
    }
}

struct WrappedHStack<Content: View>: View {
    
    let itemsCount: Int
    let content: ( Int ) -> Content
    let spacing: CGFloat
    let width: CGFloat

    init( _ itemsCount: Int, in width: CGFloat, spacing: CGFloat = 10, content: @escaping (Int) -> Content ) {
        self.itemsCount = itemsCount
        self.spacing = spacing
        self.content = content
        self.width = width
    }
    
    var body: some View {
        display(in: width, itemsCount, spacing, content)
    }
    
    func display(in maxWidth: CGFloat, _ itemsCount: Int, _ spacing: CGFloat, _ content: @escaping (Int) -> Content) -> some View {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var previousRowHeight: CGFloat = 0

        return ZStack(alignment: .leading) {
            
            ForEach( 0..<itemsCount, id: \.self ) { index in
                
                content(index)
                    .alignmentGuide(HorizontalAlignment.leading) { d in
                        if abs(maxWidth + width) < d.width {
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

struct SubViewGeometryReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
