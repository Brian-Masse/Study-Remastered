//
//  CardView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI
import Introspect


struct CardView: View {
    
    @ObservedObject var viewModel: CardViewModel
    
    @State var side: Bool = true
    
    init( _ viewModel: CardViewModel ) { self.viewModel = viewModel }
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                HStack {
                    Spacer()
                    
                    if side {
                        Side(geo: geo, side: $side)
                            .environmentObject( viewModel )
                            .environmentObject( viewModel.frontTextViewModel )
                    }else {
                        Side(geo: geo, side: $side)
                            .environmentObject( viewModel )
                            .environmentObject( viewModel.backTextViewModel )
                    }

                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    struct Side: View {
        
        @EnvironmentObject var cardViewModel: CardViewModel
        @EnvironmentObject var cardTextViewModel: CardTextViewModel
        
        let geo: GeometryProxy
        
        @Binding var side: Bool
        
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
                    richTextEditorSerializeControls(geo: geo, side: $side)
                        .environmentObject( cardTextViewModel )
                }
                
                GeometryReader { geo2 in
                    CardTextView(geo: geo2)
                        .environmentObject( cardTextViewModel )
                        .frame(maxHeight: geo.size.height * 0.6)
                }
            }
            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.8)
            .padding(.top)
            
            if cardTextViewModel.editingEquation {
                VStack {
                    Spacer()
                    let handler = cardTextViewModel.equationHandlers[cardTextViewModel.handlerIndex]
                    StyledUIText("done", symbol: "checkmark.rectangle").onTapGesture { cardTextViewModel.editingEquation = false }
                        .frame(width: geo.size.width - 10, height: 20)
//                    Calculator(viewModel: CalculatorViewModel( CalculatorModel( handler ) ), shouldDisplayText: false, geo: geo)
                }.frame(width: globalFrame.width, height: globalFrame.height)
            }
        }
    }
}
