//
//  File.swift
//  
//
//  Created by Alex Dremov on 04.09.2022.
//

import Foundation
import CoreGraphics

extension CGPoint: Plottable {
    public static func reverseTransform(point: CGPoint) -> CGPoint {
        point
    }
    
    public var point: CGPoint {
        self
    }
    
    public var valueX: String {
        "\((x * 100).rounded() / 100)"
    }
    
    public var valueY: String {
        "\((y * 100).rounded() / 100)"
    }
}
