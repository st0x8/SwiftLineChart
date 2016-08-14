//
//  LineChartView.swift
//  SwiftLineChart
//
//  Created by 0x00 on 8/12/16.
//  Copyright © 2016 0x08. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
public class LineChartView: UIView {
    
    @IBInspectable public var gridColor: UIColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1) {
        willSet {
            if !gridColor.isEqual(newValue) {
                gridX.color = gridColor
                gridY.color = gridColor
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var axisColor: UIColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1) {
        willSet {
            if !axisColor.isEqual(newValue) {
                axis.color = axisColor
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var labelColor: UIColor = UIColor.blackColor() {
        willSet {
            if !labelColor.isEqual(newValue) {
                labelY.color = labelColor
                labelX.color = labelColor
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var gridHidden: Bool = false {
        willSet {
            if newValue != gridHidden {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var axisHidden: Bool = false {
        willSet {
            if newValue != axisHidden {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var labelHidden: Bool = false {
        willSet {
            if newValue != labelHidden {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var areaHidden: Bool = false {
        willSet {
            if newValue != areaHidden {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var showLineAnimation: Bool = true {
        willSet {
            if newValue != showLineAnimation {
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable public var lineAnimationDuration: CFTimeInterval = 1
    
    @IBInspectable public var chartInset: CGFloat = 18 {
        willSet {
            if newValue != chartInset {
                setNeedsDisplay()
            }
        }
    }
    
    public var xLabelTitles = [String]()
    public var yLabelValues:[CGFloat] = [0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500]
    
    private var lineValues = [[CGFloat]]()
    

    private var chartHeight: CGFloat!
    private var chartWidth : CGFloat!
    private var gridX: Grid!
    private var gridY: Grid!
    private var axis: Axis!
    private var labelX: LabelXY!
    private var labelY: LabelXY!
    private var lines: [Line] = [Line]()
    private var lineLayers = [CAShapeLayer]()
    
    convenience public init() {
        self.init(frame: CGRectZero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        #if TARGET_INTERFACE_BUILDER
            for i in 0...10 {
                xLabelTitles.append(String(i))
            }
            addLine([0, 10, 100, 120, 150, 200, 300, 400, 450, 500], color: nil, lineWidth: nil)
        #endif
        calculate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        calculate()
    }
    
    override public func drawRect(rect: CGRect) {
        calculate()
        for layer in lineLayers {
            layer.removeFromSuperlayer()
        }
        lineLayers.removeAll()
        
        if !gridHidden {
            drawGrid()
        }
        if !axisHidden {
            drawAxis()
        }
        if !labelHidden {
            drawLabels()
        }
        drawLineAndArea()
    }
    
    public func addLine(line: [CGFloat], color: UIColor?, lineWidth: CGFloat?) {
        lineValues.append(line)
        let lColor = (color != nil) ? color! : UIColor(red:0.42, green:0.63, blue:0.33, alpha:1.0)
        let width = lineWidth != nil ? lineWidth! : 2
        lines.append(Line.init(color: lColor, lineWidth: width, points: nil))
        setNeedsDisplay()
    }
    
    private func getMaxValueAndMaxCount(list: [[CGFloat]]) -> (value:CGFloat, maxCount: Int) {
        var maxValue: CGFloat = 0
        var maxCount: Int = 0
        for i in list {
            let value = i.maxElement()
            if value > maxValue {
                maxValue = value!
            }
            let count = i.count
            if count > maxCount {
                maxCount = count
            }
        }
        return (maxValue, maxCount)
    }
    
    private func getMinValue(list: [[CGFloat]]) -> CGFloat {
        var min: CGFloat = 0
        for i in list {
            let value = i.minElement()
            if value < min {
                min = value!
            }
        }
        return min
    }
    
    private func calculate() {
        let leftInset: CGFloat = 5
        chartWidth = frame.width - chartInset * 2 - leftInset
        chartHeight = frame.height - chartInset * 2
        let originX: CGFloat = chartInset + leftInset * 2
        //Y
        var gridYLines = [(CGPoint, CGPoint)]()
        var labelYRect = [CGRect]()
        let gapY = chartHeight / CGFloat(yLabelValues.count - 1)
        for (inx, _) in yLabelValues.enumerate() {
            let index = CGFloat(inx)
            gridYLines.append((CGPointMake(originX, index * gapY + chartInset), CGPointMake(chartWidth + originX, index * gapY + chartInset)))
            let rect = CGRectMake(0, index * gapY + chartInset-leftInset, originX - leftInset, 10)
            labelYRect.append(rect)
        }
        
        gridY = Grid.init(color: gridColor, lines: gridYLines)
        labelY = LabelXY.init(color: labelColor, postions: labelYRect)
        
        
        //X
        var maxCount = getMaxValueAndMaxCount(lineValues).maxCount
        if maxCount < 1 {
            maxCount = 10
        }
        var gridXLines = [(CGPoint, CGPoint)]()
        var labelXRect = [CGRect]()
        let gapX = chartWidth / CGFloat(maxCount-1)
        let bottomLabelY = chartHeight + chartInset  + 3
        for index in 0..<maxCount {
            let i = CGFloat(index)
            gridXLines.append((CGPointMake(i * gapX + originX, chartInset), CGPointMake(i * gapX + originX, chartHeight + chartInset)))
            let rect = CGRectMake(i * gapX + originX - gapX/2, bottomLabelY, gapX, 10)
            labelXRect.append(rect)
            
        }
        gridX = Grid.init(color: gridColor, lines: gridXLines)
        labelX = LabelXY.init(color: labelColor, postions: labelXRect)
        
        axis = Axis.init(color: axisColor, leftTop: CGPointMake(originX, chartInset), leftBottom: CGPointMake(originX, chartInset + chartHeight), rightEnd: CGPointMake(originX + chartWidth, chartInset + chartHeight))
        
        //Lines
        var maxYAxisValue = yLabelValues.maxElement()
        if maxYAxisValue == nil {
            maxYAxisValue = 500
        }
        
        for  (inx, values) in lineValues.enumerate() {
            var points = [CGPoint]()
            for (lInx, value) in values.enumerate() {
                let y = chartHeight - (value / maxYAxisValue! * chartHeight) + chartInset
                let point = CGPointMake(CGFloat(lInx) * gapX + originX, y)
                points.append(point)
            }
            lines[inx].points = points
        }
        
    }
    
    private func drawGrid() {
        gridX.color.setStroke()
        let path = UIBezierPath()
        path.lineWidth = 1
        for line in gridX.lines {
            path.moveToPoint(line.0)
            path.addLineToPoint(line.1)
        }
        path.stroke()
        
        gridY.color.setStroke()
        let pathY = UIBezierPath()
        pathY.lineWidth = 1
        for line in gridY.lines {
            pathY.moveToPoint(line.0)
            pathY.addLineToPoint(line.1)
        }
        pathY.stroke()
    }
    
    private func drawAxis() {
        axis.color.setStroke()
        let path = UIBezierPath()
        path.moveToPoint(axis.leftTop)
        path.addLineToPoint(axis.leftBottom)
        path.addLineToPoint(axis.rightEnd)
        path.lineWidth = 1
        path.stroke()
    }
    
    private func drawLabels() {
        
        let pointsY = labelY.postions.reverse()
        for (inx, rect) in pointsY.enumerate() {
            if inx >= yLabelValues.count {
                break
            }
            let value = yLabelValues[inx]
            let textAlign = NSMutableParagraphStyle.init()
            textAlign.alignment = .Right
            NSString.init(string: String(Int(value))).drawInRect(rect, withAttributes: [NSForegroundColorAttributeName: labelY.color, NSFontAttributeName: UIFont.systemFontOfSize(9), NSParagraphStyleAttributeName:
                textAlign])
            
        }
        
        for (inx, rect) in labelX.postions.enumerate() {
            if inx >= xLabelTitles.count {
                break
            }
            let title = xLabelTitles[inx]
            let textAlign = NSMutableParagraphStyle.init()
            textAlign.alignment = .Center
            NSString.init(string: title).drawInRect(rect, withAttributes: [NSForegroundColorAttributeName: labelY.color, NSFontAttributeName: UIFont.systemFontOfSize(9), NSParagraphStyleAttributeName:
                textAlign])
            
        }
        
    }
    
    private func drawLineAndArea() {
        for line in lines {
            if let points = line.points {
                let path = UIBezierPath()
                if let point = points.first {
                    path.moveToPoint(point)
                }
                for i in 1..<points.count {
                    path.addLineToPoint(points[i])
                }
                let layer = CAShapeLayer()
                layer.frame = self.bounds
                layer.path = path.CGPath
                layer.strokeColor = line.color.CGColor
                layer.fillColor = nil
                layer.lineWidth = line.lineWidth
                self.layer.addSublayer(layer)
                lineLayers.append(layer)
                if showLineAnimation {
                    let animate = CABasicAnimation(keyPath: "strokeEnd")
                    animate.duration = lineAnimationDuration
                    animate.fromValue = 0
                    animate.toValue = 1
                    layer.addAnimation(animate, forKey: "strokeEnd")
                }
                if let lastPoint = points.last where !areaHidden {
                    line.color.colorWithAlphaComponent(0.2).setFill()
                    let aPath = path.copy() as! UIBezierPath
                    
                    aPath.addLineToPoint(CGPointMake(lastPoint.x, chartHeight + chartInset))
                    aPath.addLineToPoint(CGPointMake(points.first!.x, chartHeight + chartInset))
                    aPath.closePath()
                    aPath.fill()
                }
            }
        }
    }
    
    private func lightenUIColor(color: UIColor) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 1.5, alpha: a)
    }
    
}

private struct Line {
    var color: UIColor
    var lineWidth: CGFloat
    var points: [CGPoint]?
}

private struct Axis {
    var color: UIColor
    var leftTop: CGPoint
    var leftBottom: CGPoint
    var rightEnd: CGPoint
}

private struct Grid {
    var color: UIColor
    var lines: [(CGPoint, CGPoint)]
}

private struct LabelXY {
    var color: UIColor
    var postions: [CGRect]
}



