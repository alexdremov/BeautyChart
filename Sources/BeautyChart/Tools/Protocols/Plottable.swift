//
//  Plottable.swift
//  
//
//  Created by Alex Dremov on 04.09.2022.
//

import Foundation

public protocol Plottable {
    var point: CGPoint { get }
    var valueX: String { get }
    var valueY: String { get }
    
    static func reverseTransform(point: CGPoint) -> Self
}
