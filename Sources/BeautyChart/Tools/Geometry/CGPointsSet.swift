import Foundation
import SwiftUI

struct PointsArray<Element: Plottable> {
    public typealias Limits = (x: (min:CGFloat, max:CGFloat), y:(min:CGFloat, max:CGFloat))
    private let storage: [Element]
    public let limits: Limits
    public let ranges: (x: CGFloat, y: CGFloat)
    
    public var count : Int {
        storage.count
    }
    
    public var isEmpty : Bool {
        storage.isEmpty
    }
    
    public init(storage: [Element]) {
        self.storage = storage
        self.limits = Self.limitsCalc(from: storage)
        self.ranges = Self.rangeForLimits(lims: self.limits)
    }
    
    static private func limitsCalc(from storage: [Element]) -> Limits {
        let maxx = CGFloat(
            storage.reduce(-Double.greatestFiniteMagnitude){Swift.max($0, $1.point.x)}
        )
        let maxy = CGFloat(
            storage.reduce(-Double.greatestFiniteMagnitude){Swift.max($0, $1.point.y)}
        )
        let minx = CGFloat(
            storage.reduce(Double.greatestFiniteMagnitude){Swift.min($0, $1.point.x)}
        )
        let miny = CGFloat(
            storage.reduce(Double.greatestFiniteMagnitude){Swift.min($0, $1.point.y)}
        )
        return ((minx, maxx), (miny, maxy))
    }

    static private func rangeForLimits(lims: Limits) -> (x: CGFloat, y: CGFloat) {
        ((lims.x.max-lims.x.min), (lims.y.max-lims.y.min))
    }

    public func affineTransformed(width: Float, height: Float, vMirrored: Bool = true) -> [CGPoint] {
        var res: [CGPoint] = []
        for i in 0..<count {
            let newPoint = affineTransformed(i: i, width: width, height: height)
            res.append(newPoint)
        }
        return res
    }

    public func affineTransformed(i: Int, width: Float, height: Float, vMirrored: Bool = true) -> CGPoint {
        affineTransformed(point: storage[i].point, width: width, height: height, vMirrored: vMirrored)
    }
    
    public func affineTransformed(point: CGPoint, width: Float, height: Float, vMirrored: Bool = true) -> CGPoint {
        guard count > 1, width > 0, height > 0 else {
            return CGPoint(x: 0, y: 0)
        }
        let limitsCache = limits
        let rangeCache = ranges
        
        let newX = (point.x - limitsCache.x.min) / rangeCache.x * CGFloat(width)
        var newY = (point.y - limitsCache.y.min) / rangeCache.y * CGFloat(height)
        
        if vMirrored {
            newY = CGFloat(height) - newY
        }
        
        return CGPoint(x: newX, y: newY)
    }

    public func reverseAffine(_ point: CGPoint, width: Float, height: Float, vMirrored: Bool = true) -> CGPoint {
        let limitsCache = limits
        let rangeCache = ranges

        var newX = point.x
        var newY = point.y

        if vMirrored {
            newY = CGFloat(height) - newY
        }

        newX = (newX) * rangeCache.x / CGFloat(width) + limitsCache.x.min
        newY = (newY) * rangeCache.y / CGFloat(height) + limitsCache.y.min

        return CGPoint(x: newX, y: newY)
    }

    public func closestPoint(_ refPoint: CGPoint, axes: [Axis] = [.horizontal, .vertical]) -> CGPoint {
        guard !isEmpty else {
            return CGPoint(x: 0, y: 0)
        }
        var point = storage[0].point
        for i in 1..<count {
            switch axes {
            case let x where x.count == 0:
                 return refPoint
            case let x where x.count == 2:
                if refPoint.dist(to: point) > refPoint.dist(to: storage[i].point) {
                    point = storage[i].point
                }
            case let x where x[0] == .horizontal:
                if abs(refPoint.x - point.x) > abs(refPoint.x - storage[i].point.x) {
                    point = storage[i].point
                }
            case let x where x[0] == .vertical:
                if abs(refPoint.x - point.x) > abs(refPoint.x - storage[i].point.x) {
                    point = storage[i].point
                }
            default:
                return refPoint
            }

        }
        return point
    }
}
