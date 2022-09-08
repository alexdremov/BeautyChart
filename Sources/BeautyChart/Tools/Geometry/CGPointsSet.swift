import Foundation
import SwiftUI

extension Array where Element: Plottable {
    var limits: (x: (min:CGFloat, max:CGFloat), y:(min:CGFloat, max:CGFloat)) {
        let maxx = CGFloat(
            self.reduce(-Double.greatestFiniteMagnitude){Swift.max($0, $1.point.x)}
        )
        let maxy = CGFloat(
            self.reduce(-Double.greatestFiniteMagnitude){Swift.max($0, $1.point.y)}
        )
        let minx = CGFloat(
            self.reduce(Double.greatestFiniteMagnitude){Swift.min($0, $1.point.x)}
        )
        let miny = CGFloat(
            self.reduce(Double.greatestFiniteMagnitude){Swift.min($0, $1.point.y)}
        )
        return ((minx, maxx), (miny, maxy))
    }

    var ranges: (x: CGFloat, y: CGFloat) {
        rangeForLimits(lims: self.limits)
    }

    func rangeForLimits(lims: (x: (min: CGFloat, max: CGFloat), y: (min: CGFloat, max: CGFloat))) -> (x: CGFloat, y: CGFloat) {
        ((lims.0.1-lims.0.0), (lims.1.1-lims.1.0))
    }

    func affineTransformed(width: Float, height: Float, vMirrored: Bool = true) -> [CGPoint] {
        var res: [CGPoint] = []
        for i in 0..<count {
            let newPoint = affineTransformed(i: i, width: width, height: height)
            res.append(newPoint)
        }
        return res
    }

    func affineTransformed(i: Int, width: Float, height: Float, vMirrored: Bool = true) -> CGPoint {
        guard count > 1 else {
            return CGPoint(x: 0, y: 0)
        }
        
        let point = self[i].point
        let limitsCache = limits
        let rangeCache = rangeForLimits(lims: limitsCache)
        
        let newX = (point.x - limitsCache.x.min) / rangeCache.x * CGFloat(width)
        var newY = (point.y - limitsCache.y.min) / rangeCache.y * CGFloat(height)

        if vMirrored {
            newY = CGFloat(height) - newY
        }

        return CGPoint(x: newX, y: newY)
    }

    func reverseAffine(_ point: CGPoint, width: Float, height: Float, vMirrored: Bool = true) -> CGPoint {
        let limitsCache = limits
        let rangeCache = rangeForLimits(lims: limitsCache)

        var newX = point.x
        var newY = point.y

        if vMirrored {
            newY = CGFloat(height) - newY
        }

        newX = (newX) * rangeCache.x / CGFloat(width) + limitsCache.x.min
        newY = (newY) * rangeCache.y / CGFloat(height) + limitsCache.y.min

        return CGPoint(x: newX, y: newY)
    }

    func closestPoint(_ refPoint: CGPoint, axes: [Axis] = [.horizontal, .vertical]) -> CGPoint {
        guard !isEmpty else {
            return CGPoint(x: 0, y: 0)
        }
        var point = self[0].point
        for i in 1..<count {
            switch axes {
            case let x where x.count == 0:
                 return refPoint
            case let x where x.count == 2:
                if refPoint.dist(to: point) > refPoint.dist(to: self[i].point) {
                    point = self[i].point
                }
            case let x where x[0] == .horizontal:
                if abs(refPoint.x - point.x) > abs(refPoint.x - self[i].point.x) {
                    point = self[i].point
                }
            case let x where x[0] == .vertical:
                if abs(refPoint.x - point.x) > abs(refPoint.x - self[i].point.x) {
                    point = self[i].point
                }
            default:
                return refPoint
            }

        }
        return point
    }
}
