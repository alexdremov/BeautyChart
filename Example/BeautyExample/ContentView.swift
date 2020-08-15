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

    var body: some View {
        VStack{
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
            ], style: LineViewStyle().mode2())
            
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
            ], style: LineViewStyle())
            Spacer()
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
