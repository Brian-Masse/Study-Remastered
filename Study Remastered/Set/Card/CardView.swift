//
//  CardView.swift
//  Study Remastered
//
//  Created by Brian Masse on 6/12/22.
//

import Foundation
import SwiftUI
//import Introspect


struct CardView: View {
    
    enum DisplayType {
        case single
        case singlePresentation
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
            case let x where x == .single || x == .singlePresentation :
                 Side(side: $side, displayType: displayType).environmentObject( side ? viewModel.frontTextViewModel : viewModel.backTextViewModel )
            case .double:
                HStack() {
                    Side(side: $side,  displayType: displayType)
                        .environmentObject(viewModel.frontTextViewModel)
                    Side(side: $side,  displayType: displayType)
                        .environmentObject(viewModel.backTextViewModel)
                }.padding(.horizontal)
            default : Text("")
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
        
        @State var rotation: CGFloat = 0
        
        let displayType: CardView.DisplayType
        
        static let cornerRadius: CGFloat = 30
        static let aspectRatio: CGFloat = 1.6475033738191633
        static let flipTime: CGFloat = 0.7
        
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    ZStack {
                        TextureFill().cornerRadius(CardView.Side.cornerRadius)
                        RoundedRectangle(cornerRadius: CardView.Side.cornerRadius)
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Colors.UIprimaryCream)

    //                    ScrollView(.vertical) {
                        CardTextView(size: $size, width: geo.size.width)
                            .environmentObject(appViewModel)
                            .environmentObject( cardTextViewModel )
    //                    }
                        .frame(maxHeight: geo.size.height * 0.6)
                    }.rotation3DEffect(Angle(degrees: rotation), axis: (x: 0, y: 1, z: 0))
                    
                    VStack {
                        RichTextEditorControls(geo: geo)
                            .environmentObject( cardTextViewModel.activeViewModel )
                            .offset(y: -CardView.Side.cornerRadius)
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                        Spacer()
                        if displayType == .single {
                            richTextEditorSerializeControls(geo: geo) { flipCard() }
                                .environmentObject( cardTextViewModel )
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width * CardView.Side.aspectRatio)
                .onAppear { appViewModel.activeCardText = cardTextViewModel  }
            }
            .aspectRatio(1 / CardView.Side.aspectRatio, contentMode: .fit)
            .onTapGesture { if displayType == .singlePresentation { flipCard() } }
        }
        private func flipCard() {
            withAnimation(.easeIn(duration: Side.flipTime / 2)) { rotation = 91 }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + (Side.flipTime / 2)) { side.toggle() }
            
            withAnimation(.easeIn(duration: 0.00000000000000000001).delay(Side.flipTime / 2)) { rotation = -91 }
            withAnimation(.easeOut(duration: Side.flipTime / 2).delay( Side.flipTime / 2)) { rotation = 0 }
        }
    }
}
