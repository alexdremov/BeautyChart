//
//  SwiftUIView.swift
//  
//
//  Created by Alex Dremov on 08.09.2022.
//

import SwiftUI

struct PressWindow: View {
    @Binding
    var pressPosition: CGPoint
    @Binding
    var indicatorPoint: CGPoint
    @Binding
    var text: String
    
    var style: LineViewStyle
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                Color.clear
                IndicatorPoint(style: style)
                    .position(indicatorPoint)
                VStack {
                    Text(text)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(idealWidth: .zero, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(style.movingRectColor, lineWidth: 2)
                        .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6 )
                        .opacity(0.5)
                )
                .position(x: pressPosition.x, y:proxy.size.height / 2)
            }
        }
    }
}

struct IndicatorPoint: View {
    var style: LineViewStyle
    
    var body: some View {
        ZStack {
            Circle()
                .fill(style.movingPointColor)
            Circle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4))
        }
        .frame(width: 14, height: 14)
        .shadow(color: Colors.LegendColor, radius: 6, x: 0, y: 6)
    }
}
