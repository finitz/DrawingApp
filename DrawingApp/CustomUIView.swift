//
//  CustomUIView.swift
//  DrawingApp
//
//  Created by 17 on 9/18/19.
//  Copyright © 2019 17. All rights reserved.
//

import UIKit

class CustomUIView: UIView {
    
    struct PathWithColour {
        let line: UIBezierPath
        var colour: UIColor
    }
    
    enum Mode {
        case brush
        case eraser
        case move
    }
    
    
    var strokeColour = #colorLiteral(red: 0.8889197335, green: 0.78421344, blue: 0.1864610223, alpha: 1)
    var eraserColour = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var strokeSize = 15
    var mode = Mode.brush
    var path = UIBezierPath()

    var pathArray = [PathWithColour]()
    
    let drawingView = UIImageView()
    var layerArray = [UIImageView]()
    var redoLayerArray = [UIImageView]()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        drawingView.frame = bounds
        self.addSubview(drawingView)
    }
    
    func setupPath() {
        path = UIBezierPath()
        path.lineWidth = CGFloat(strokeSize)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move {
            let touch = touches.first!
            setupPath()
            path.move(to: touch.location(in: self))
            updateImageView()
        }
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move {
            let touch = touches.first!
            path.addLine(to: touch.location(in: self))
            updateImageView()
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move {
            let touch = touches.first!
            endTouches(at: touch.location(in: self))

            if mode == .brush {
                pathArray.append(PathWithColour(line: path, colour: strokeColour))
            }

            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
            if mode == .eraser {
                eraserColour.setStroke()
            } else {
                strokeColour.setStroke()
            }
            path.stroke(with: .normal, alpha: 1.0)
            let newLayerImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let newLayer = UIImageView(image: newLayerImage)


            layerArray.append(newLayer)
            self.addSubview(newLayer)
            self.bringSubviewToFront(drawingView)

            redoLayerArray.removeAll()
        }

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move {
            let touch = touches.first!
            endTouches(at: touch.location(in: self))
        }
    }

    func endTouches(at point: CGPoint) {
        path.addLine(to: point)
        updateImageView()
    }
    
    func updateImageView() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        if mode == .eraser {
            eraserColour.setStroke()
        } else {
            strokeColour.setStroke()
        }
        path.stroke(with: .normal, alpha: 1.0)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        drawingView.image = img

        setNeedsDisplay()
    }
    
    func clear() {
        drawingView.image = nil
        drawingView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        layerArray.removeAll()
        pathArray.removeAll()
        redoLayerArray.removeAll()
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.addSubview(drawingView)
        mode = .brush
    }
    
    func undo() {
        drawingView.image = nil
        
        if !layerArray.isEmpty {
            if let redoLayer = layerArray.popLast() {
                redoLayerArray.append(redoLayer)
                redoLayer.removeFromSuperview()
                print("removed from superview")
            }
        }
    }

    func redo() {
        if let redo = redoLayerArray.popLast() {
            self.addSubview(redo)
            layerArray.append(redo)
        }
        self.bringSubviewToFront(drawingView)
    }
    
//    func pointInNewSystem(_ point: CGPoint, _ layerIndex: Int) -> CGPoint {
//        return CGPoint(x: point.x - (self.bounds.minX - self.subviews[layerIndex].frame.minX),
//                       y: point.y - (self.bounds.minY - self.subviews[layerIndex].frame.minY))
//    }
    
    var moveLayerIndex: Int?
        
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            
            drawingView.image = nil
            for (i, view) in self.subviews.enumerated() {
                if view.toImageView().alphaAtPoint(point: gesture.location(in: view)) != 0.0 {
                        moveLayerIndex = i
                        print("IF 2")
                    }
            }

        case .changed:
            let translation = gesture.translation(in: gesture.view)
            guard let index = moveLayerIndex else {return}
            self.subviews[index].center = CGPoint(x: self.subviews[index].center.x + translation.x, y: self.subviews[index].center.y + translation.y)
            
            gesture.setTranslation(CGPoint.zero, in: gesture.view)
            
        case .ended:
            print("ended")
            moveLayerIndex = nil

        default:
            break
        }
        }
    
}

extension UIImageView {
    
    func alphaAtPoint(point: CGPoint) -> CGFloat {
        
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo) else {
            return 0
        }
        
        context.translateBy(x: -point.x, y: -point.y);
        
        layer.render(in: context)
        
        let floatAlpha = CGFloat(pixel[3])
        
        return floatAlpha
    }
    
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {

        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension UIView {
    func toImageView() -> UIImageView {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return UIImageView(image: image)
    }
}

extension CGPoint {
    func distance(from b: CGPoint) -> CGFloat {
        let xDist = self.x - b.x
        let yDist = self.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}
