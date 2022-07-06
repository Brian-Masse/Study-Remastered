//
//  UIUinversal.swift
//  Study Remastered
//
//  Created by Brian Masse on 7/6/22.
//

import Foundation
import SwiftUI


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
                        let offset = height
                        if index == itemsCount - 1 { height = 0 }
                        return offset
                    }
                }
            }
    }

}
