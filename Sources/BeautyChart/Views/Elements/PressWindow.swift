//
//  SwiftUIView.swift
//  
//
//  Created by Alex Dremov on 08.09.2022.
//

import SwiftUI

struct PressWindow: View {
    var pressPosition: Binding<CGPoint>
    var indicatorPoint: Binding<CGPoint>
    var text: Binding<String>
    
    var style: LineViewStyle
    
    var body: some View {
        ZStack {
            IndicatorPoint(style: style)
                .position(indicatorPoint.wrappedValue)
            Group {
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(self.style.movingRectColor, lineWidth: 2)
                        .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6 )
                        .opacity(0.5)
                        .frame(width: 60, height: proxy.size.height)
                        .position(x: self.pressPosition.wrappedValue.x, y: proxy.size.height / 2)
                }
            }
            Text(text.wrappedValue)
                .fontWeight(.semibold)
                .position(x: pressPosition.wrappedValue.x, y: 20)
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
