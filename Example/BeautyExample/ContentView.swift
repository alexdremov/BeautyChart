//
//  ContentView.swift
//  BeautyExample
//
//  Created by Александр Дремов on 15.08.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import BeautyChart

struct ContentView: View {
    
    @State var points:[CGPoint] = [CGPoint(x: 0, y: 17),
                                   CGPoint(x: 1, y: 23),]
    
    @State var style:LineViewStyle = LineViewStyle().mode2()
    var body: some View {
        self.style.darkTheme.bezierStepMode = false
        self.style.lightTheme.bezierStepMode = false
        return ScrollView{ VStack{
            ChartSmoothView(points: points, title: "So volatile", caption: "Random points", style: self.style)
            
            ChartSmoothView(points: [
                CGPoint(x: 0, y: 17),
                CGPoint(x: 1, y: 23),
                CGPoint(x: 2, y: 60),
                CGPoint(x: 3, y: 32),
                CGPoint(x: 4, y: 12),
                CGPoint(x: 5, y: 37),
                CGPoint(x: 6, y: 0),
                CGPoint(x: 7, y: 23),
                CGPoint(x: 8, y: 60),
            ], title: "This one is sMoOtH", style: LineViewStyle())
            HStack{
                ChangeBarView(changePercent: 0.3, title: "Style")
                ChangeBarView(changePercent: -0.73233, title: "Beauty")
            }
            ChangeBarView(changePercent: 0.9333, title: "Appreciation", caption: "Based on poll")
            Spacer()
            }.padding()
        }.onAppear(){
                self.points = []
                for i in 0...30{
                    self.points.append(CGPoint(x:i*100,y:Int(arc4random()%100)))
                }
                
                self.style.lightTheme.bezierStepMode = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
