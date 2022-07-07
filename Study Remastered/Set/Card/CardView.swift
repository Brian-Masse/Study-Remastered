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
    
    @State var activeCardText: CardTextViewModel

    @State var editing = true
    
    init( _ viewModel: CardViewModel ) {
        self.viewModel = viewModel
        self.activeCardText = viewModel.frontTextViewModel
    }
    
    var body: some View {
        
        GeometryReader { geo in
            HStack {
                Spacer()
                Side(geo: geo)
                    .environmentObject( viewModel )
                    .environmentObject( activeCardText )
                    .offset(y: 100)
                Spacer()
            }
        }
    }
    
    struct Side: View {
        
        @EnvironmentObject var cardViewModel: CardViewModel
        @EnvironmentObject var cardTextViewModel: CardTextViewModel
        
        let geo: GeometryProxy
        
        let cornerRadius: CGFloat = 30
        
        var body: some View {
            ZStack(alignment: .center) {
                
                TextureFill().cornerRadius(cornerRadius)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Colors.UIprimaryCream)
                
                VStack {
                    RichTextEditorControls(geo: geo)
                        .environmentObject( cardTextViewModel.activeViewModel )
                        .offset(y: -cornerRadius)
                    Spacer()
                }
                
                CardText()
                    .environmentObject( cardTextViewModel )
                
            }.frame(width: geo.size.width * 0.95, height: geo.size.height * 0.8)
        }
    }
}
