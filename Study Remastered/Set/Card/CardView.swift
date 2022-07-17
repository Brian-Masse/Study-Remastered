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
    
    enum DisplayType {
        case single
        case double
    }
    
    @EnvironmentObject var appViewModel: StudyRemasteredViewModel
    @ObservedObject var viewModel: CardViewModel
    
    @State var side: Bool = true
    @State var displayType: DisplayType
    
    init( _ viewModel: CardViewModel, displayType: DisplayType ) {
        self.viewModel = viewModel
        self.displayType = displayType
    }
    
    var body: some View {
        
        VStack {
            switch displayType {
            case .single:
                if side { Side(side: $side, showSerializationControls: true).environmentObject( viewModel.frontTextViewModel ) }
                else { Side(side: $side, showSerializationControls: true).environmentObject( viewModel.backTextViewModel ) }
                
            case .double:
                HStack() {
                    Side(side: $side, showSerializationControls: false)
                        .environmentObject(viewModel.frontTextViewModel)
                    Side(side: $side, showSerializationControls: false)
                        .environmentObject(viewModel.backTextViewModel)
                }.padding(.horizontal)
            }
        }
        .environmentObject(appViewModel)
        .environmentObject( viewModel )
    }
    
    struct Side: View {
        
        @EnvironmentObject var appViewModel: StudyRemasteredViewModel
        @EnvironmentObject var cardViewModel: CardViewModel
        @EnvironmentObject var cardTextViewModel: CardTextViewModel
        
        @Binding var side: Bool
        @State var size: CGSize = .zero
        
        let showSerializationControls: Bool
        
        static let cornerRadius: CGFloat = 30
        static let aspectRatio: CGFloat = 1.6475033738191633
        
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    TextureFill().cornerRadius(CardView.Side.cornerRadius)
                    RoundedRectangle(cornerRadius: CardView.Side.cornerRadius)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Colors.UIprimaryCream)

//                    VStack {
//                        RichTextEditorControls(geo: geo)
//                            .environmentObject( cardTextViewModel.activeViewModel )
//                            .offset(y: -CardView.Side.cornerRadius)
//                        Spacer()
//                        if showSerializationControls {
//                            richTextEditorSerializeControls(geo: geo, side: $side)
//                                .environmentObject( cardTextViewModel )
//                        }
//                    }
                
                    CardTextView(size: $size, width: geo.size.width)
                        .environmentObject(appViewModel)
                        .environmentObject( cardTextViewModel )
                        .frame(maxHeight: geo.size.height * 0.6)
                }
                .frame(width: geo.size.width, height: geo.size.width * CardView.Side.aspectRatio)
                .onAppear { appViewModel.activeCardText = cardTextViewModel  }
            }
            .aspectRatio(1 / CardView.Side.aspectRatio, contentMode: .fit)
        }
            
    }
}
