    //
    //  ChartSmoothView.swift
    //
    //
    //  Created by Alex Dremov on 04.09.2022.
    //

import Foundation
import SwiftUI

public struct ChartSmoothPlot<Point: Plottable>: View {
    public typealias Zone = (ranges: (min: CGFloat, max:CGFloat), content: AnyView)
    private var data: PointsArray<Point>
    private var adaptiveBounded = true
    private var adaptiveBezierStep: CGFloat = 0.1
    private var horizontalLinesNum = 4
    private var verticalLinesNum = 4
    private var displayPoints = false
    private var zones = [Zone]()
    private var style: LineViewStyle = .standard
    
    @ObservedObject private var lookUpTable = LookUpTable(path: Path())
    @State private var path: Path = Path()
    @State private var horizontalLines = [CGFloat]()
    @State private var verticalLines = [CGFloat]()
    @State private var horizontalTicks = [String]()
    @State private var verticalTicks = [String]()
    @State private var animationPercent: CGFloat = .zero
    
    @State var pressVisible: Bool = false
    
    @State var pressText: String = ""
    @State var indicatorPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State var pressPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    public init(data: [Point]) {
        self.data = PointsArray(
            storage: data.sorted{ $0.point.x < $1.point.x }
        )
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            drawVerticalTicks()
            VStack(alignment: .leading, spacing: .zero) {
                GeometryReader { viewPort in
                    ZStack {
                        drawZones(port: viewPort)
                        drawVerticalLines(port: viewPort)
                        drawHorizontalLines(port: viewPort)
                        graphItself(port: viewPort)
                            .drawingGroup()
                        drawPoints(port: viewPort)
                        pressWindow
                    }
                    .onChange(of: viewPort.size) { newSize in
                        updateHorizontalLines(size: newSize)
                        updateVerticalLines(size: newSize)
                        updateVerticalTicks()
                        updateHorizontalTicks()
                    }
                    .onAppear {
                        updateHorizontalLines(size: viewPort.size)
                        updateVerticalLines(size: viewPort.size)
                        updateVerticalTicks()
                        updateHorizontalTicks()
                    }
                    .contentShape(Rectangle())
                    .gesture(pressWindowGesture(size: viewPort.size))
                }
                drawHorizontalTicks()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func drawZones(port viewPort: GeometryProxy) -> some View {
        ZStack(alignment: .topLeading){
            Color.clear
            ForEach(Array(zones.enumerated()), id: \.offset) { offset, element in
                element.content
                    .frame(maxWidth: .infinity)
                    .frame(height:
                            zoneHeight(
                                for: element,
                                port: viewPort
                            )
                    )
                    .clipped()
                    .offset(
                        y: zonePosition(
                            for: element,
                            port: viewPort
                        )
                    )
            }
        }
    }
    
    private func zoneHeight(for element: Zone, port: GeometryProxy) -> CGFloat {
        let pointMin = data.affineTransformed(
            point: .init(x: data.limits.x.min, y: element.ranges.min),
            width: Float(port.size.width),
            height: Float(port.size.height)
        )
        let pointMax = data.affineTransformed(
            point: .init(x: data.limits.x.min, y: element.ranges.max),
            width: Float(port.size.width),
            height: Float(port.size.height)
        )
        
        return abs(pointMax.y - pointMin.y)
    }
    
    private func zonePosition(for element: Zone, port: GeometryProxy) -> CGFloat {
        data.affineTransformed(
            point: .init(x: data.limits.x.min, y: element.ranges.max),
            width: Float(port.size.width),
            height: Float(port.size.height)
        ).y
    }
    
    private func pressWindowGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged({ value in
                guard !data.isEmpty else {
                    pressVisible = false
                    return
                }
                self.indicatorPosition = lookUpTable.getClosestPoint(fromPoint: value.location, axes: [.horizontal])
                
                self.pressPosition = value.location
                
                if value.location.x <= size.width && value.location.x >= 0 {
                    let revPoint = data.reverseAffine(
                        indicatorPosition,
                        width: Float(size.width),
                        height: Float(size.height),
                        vMirrored: true
                    )
                    
                    let closest = data.closestPoint(
                        revPoint,
                        axes: [.horizontal]
                    )
                    
                    let point = Point.reverseTransform(point: closest)
                    let text = point.valueY
                    
                    if self.pressText != text {
                        HapticFeedback.playSelection()
                    }
                    self.pressText = text
                    self.pressVisible = true
                } else {
                    self.pressVisible = false
                }
            })
            .onEnded({ _ in
                self.pressVisible = false
            })
    }
    
    @ViewBuilder
    private var pressWindow: some View {
        if pressVisible, !lookUpTable.lookupTable.isEmpty {
            PressWindow(
                pressPosition: $pressPosition,
                indicatorPoint: $indicatorPosition,
                text: $pressText,
                style: style
            )
        }
    }
    
    @ViewBuilder
    private func drawPoints(port: GeometryProxy) -> some View {
        if displayPoints {
            ForEach(0..<data.count, id: \.self) { number in
                Circle()
                    .stroke(
                        style.pointColor,
                        lineWidth: 4
                    )
                    .overlay(
                        Circle().fill(Color.white).frame(width: 6)
                    )
                    .frame(width: 8, alignment: .center)
                    .position(
                        data.affineTransformed(
                            i: number,
                            width: Float(port.size.width),
                            height: Float(port.size.height)
                        )
                    )
            }
            .animation(nil)
            .opacity(animationPercent)
            .animation(
                .easeOut(duration: 1.0),
                value: animationPercent
            )
        }
    }
    
    private func drawHorizontalLines(port: GeometryProxy) -> some View {
        ForEach(horizontalLines, id:\.magnitude) { coord in
            Path {path in
                path.move(to: CGPoint(x: 0, y: coord))
                path.addLine(
                    to: CGPoint(
                        x: port.size.width,
                        y: coord
                    )
                )
            }
            .stroke(
                Color.gray,
                style: StrokeStyle( lineWidth: 1, dash: [1])
            )
            .opacity(0.1)
        }
    }
    
    @ViewBuilder
    private func drawVerticalLines(port: GeometryProxy) -> some View {
        ForEach(verticalLines, id:\.magnitude) { coord in
            Path {path in
                path.move(to: CGPoint(x: coord, y: 0))
                path.addLine(
                    to: CGPoint(
                        x: coord,
                        y: port.size.height
                    )
                )
            }
            .stroke(
                Color.gray,
                style: StrokeStyle( lineWidth: 1, dash: [1])
            )
            .opacity(0.1)
        }
    }
    
    @ViewBuilder
    private func drawVerticalTicks() -> some View {
        ZStack(alignment: .topTrailing){
            ForEach(Array(verticalTicks.enumerated()), id:\.offset) { num, text in
                Text(text)
                    .fontWeight(.light)
                    .font(.system(size: 10))
                    .padding(.trailing, 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.secondary)
                    .offset(x:0, y: horizontalLines[num] - 8)
            }
        }
    }
    
    @ViewBuilder
    private func drawHorizontalTicks() -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(horizontalTicks.enumerated()), id:\.offset) { num, text in
                Text(text)
                    .fontWeight(.light)
                    .font(.system(size: 10))
                    .padding(.top, 5)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(30))
                    .offset(x: verticalLines[num] - 8, y: 5)
            }
        }
    }
    
    @ViewBuilder
    private func graphItself(port: GeometryProxy) -> some View {
        path
            .trim(from: 0, to: animationPercent)
            .stroke(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            style.firstGradientColor,
                            style.secondGradientColor
                        ]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .onChange(of: port.size) { newSize in
                path = pathDrawing(port: newSize)
                lookUpTable.updateWith(path)
            }
            .onAppear {
                path = pathDrawing(port: port.size)
                lookUpTable.updateWith(path)
                withAnimation(.easeInOut(duration: 1.0)) {
                    animationPercent = 1
                }
            }
    }
    
    private func createControlPoints(drawPoints: [CGPoint], size: CGSize) -> [BezierSegmentControlPoints] {
        guard !data.isEmpty else {
            return []
        }
        var controlPoints = [BezierSegmentControlPoints]()
        if !adaptiveBounded {
            let config = BezierConfiguration()
            controlPoints = config.configureControlPoints(data: drawPoints)
        } else {
            for i in 0..<(drawPoints.count-1) {
                let fPoint = CGPoint(
                    x:drawPoints[i].x + adaptiveBezierStep * size.width,
                    y: drawPoints[i].y
                )
                let sPoint = CGPoint(
                    x: drawPoints[i+1].x - adaptiveBezierStep * size.width,
                    y: drawPoints[i+1].y
                )
                let tmpControlPoint = BezierSegmentControlPoints(
                    firstControlPoint: fPoint,
                    secondControlPoint: sPoint
                )
                controlPoints.append(tmpControlPoint)
            }
        }
        
        return controlPoints
    }
    
    private func pathDrawing(port size: CGSize) -> Path {
        guard !data.isEmpty else {
            return Path()
        }
        var path = Path()
        
        let firstTransformed = data.affineTransformed(
            i: 0,
            width: Float(size.width),
            height: Float(size.height)
        )
        
        let firstOutlier = CGPoint(
            x: firstTransformed.x - 5,
            y: firstTransformed.y
        )
        
        let lastTransformed = data.affineTransformed(
            i: data.count - 1,
            width: Float(size.width),
            height: Float(size.height)
        )
        
        let lastOutlier = CGPoint(
            x: lastTransformed.x + 5,
            y: lastTransformed.y
        )
        
        let drawPoints = [firstOutlier] +
        data.affineTransformed(
            width: Float(size.width),
            height: Float(size.height)
        ) + [lastOutlier]
        
        let controlPoints = createControlPoints(
            drawPoints: drawPoints,
            size: size
        )
        
        path.move(
            to: data.affineTransformed(
                i: 0,
                width: Float(size.width),
                height: Float(size.height)
            )
        )
        
        for point in 1..<data.count {
            let graphPoint = data.affineTransformed(
                i: point,
                width: Float(size.width),
                height: Float(size.height)
            )
            path.addCurve(
                to: graphPoint,
                control1: controlPoints[point].firstControlPoint,
                control2: controlPoints[point].secondControlPoint
            )
        }
        return path
    }
    
    private func updateHorizontalLines(size: CGSize) {
        horizontalLines = []
        guard horizontalLinesNum != 0, !data.isEmpty else {
            return
        }
        let stepper = size.height / CGFloat(horizontalLinesNum)
        
        for lineNumber in 0..<(horizontalLinesNum + 1) {
            horizontalLines.append(stepper * CGFloat(lineNumber))
        }
    }
    
    private func updateVerticalLines(size: CGSize) {
        verticalLines = []
        guard verticalLinesNum != 0, !data.isEmpty else {
            return
        }
        let stepper = size.width / CGFloat(verticalLinesNum)
        for lineNumber in 0..<(verticalLinesNum + 1) {
            verticalLines.append(stepper * CGFloat(lineNumber))
        }
    }
    
    private func updateVerticalTicks() {
        verticalTicks = []
        guard horizontalLinesNum != 0, !data.isEmpty else {
            return
        }
        let limits = data.limits
        let ranges = data.ranges
        let stepper = ranges.y / CGFloat(horizontalLinesNum)
        
        for tickNumber in 0..<(horizontalLinesNum + 1) {
            let point = CGPoint(
                x: limits.x.min,
                y: limits.y.max - CGFloat(tickNumber) * stepper
            )
            let object = Point.reverseTransform(point: point)
            verticalTicks.append(object.valueY)
        }
    }
    
    private func updateHorizontalTicks() {
        horizontalTicks = []
        guard verticalLinesNum != 0, !data.isEmpty else {
            return
        }
        let limits = data.limits
        let ranges = data.ranges
        let stepper = ranges.x / CGFloat(verticalLinesNum)
        
        for tickNumber in 0..<(verticalLinesNum + 1) {
            let point = CGPoint(
                x: limits.x.min + CGFloat(tickNumber) * stepper,
                y: limits.y.min
            )
            let object = Point.reverseTransform(point: point)
            horizontalTicks.append(object.valueX)
        }
    }
    
    public func adaptive(
        bounded: Bool=false,
        step: CGFloat=0.03
    ) -> Self {
        var tmp = self
        tmp.adaptiveBounded = bounded
        tmp.adaptiveBezierStep = step
        return tmp
    }
    
    public func set(style: LineViewStyle) -> Self {
        var tmp = self
        tmp.style = style
        return tmp
    }
    
    public func points(display displayPoints: Bool) -> Self {
        var tmp = self
        tmp.displayPoints = displayPoints
        return tmp
    }
    
    public func ticks(horizontal: UInt, vertical: UInt)  -> Self {
        var tmp = self
        tmp.horizontalLinesNum = Int(vertical)
        tmp.verticalLinesNum = Int(horizontal)
        return tmp
    }
    
    public func awareBackground(
        zones: [Zone]
    )  -> Self {
        var tmp = self
        tmp.zones = zones.lazy
            .filter {
                $0.ranges.min <= data.limits.y.max &&
                $0.ranges.max >= data.limits.y.min
            }
            .map { element in
                var copy = element
                if element.ranges.max > data.limits.y.max {
                    copy.ranges.max = data.limits.y.max
                }
                if element.ranges.min < data.limits.y.min {
                    copy.ranges.min = data.limits.y.min
                }
                return copy
            }
        return tmp
    }
}

public struct ChartSmoothPlot_Previews: PreviewProvider {
    static public var previews: some View {
        ChartSmoothPlot(data: [
            CGPoint(x: 0, y: 17),
            CGPoint(x: 1, y: 23),
            CGPoint(x: 2, y: 60),
            CGPoint(x: 3, y: 32),
            CGPoint(x: 4, y: 12),
            CGPoint(x: 5, y: 37),
            CGPoint(x: 6, y: 7),
            CGPoint(x: 7, y: 23),
            CGPoint(x: 8, y: 60)
        ])
        .adaptive(bounded: true)
        .border(.red)
        .frame(width: 350, height: 230)
    }
}
