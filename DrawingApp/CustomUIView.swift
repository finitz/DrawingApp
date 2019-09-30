//
//  CustomUIView.swift
//  DrawingApp
//
//  Created by 17 on 9/18/19.
//  Copyright © 2019 17. All rights reserved.
//

import UIKit

class CustomUIView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
    var strokeSize = 8
    var mode = Mode.brush
    var path = UIBezierPath()

    var pathArray = [PathWithColour]()
    
    let drawingView = UIImageView()
    var layerArray = [UIImageView]()
    var redoLayerArray = [UIImageView]()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        addPanGestureRecognizer(to: drawingView)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        addPanGestureRecognizer(to: drawingView)

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
    
    
//    func fill(at point: CGPoint) {
//        for i in undoPathArray.indices {
//            if undoPathArray[i].line.contains(point){
//                undoPathArray[i].colour = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//                print("set colour to black")
//            }
//        }
//        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
//        for path in undoPathArray {
//            path.colour.setStroke()
//            path.line.stroke(with: .normal, alpha: 1.0)
//        }
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        imageView.image = img
//    }
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

extension UIView {
    func toImageView() -> UIImageView {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return UIImageView(image: image)
    }
}

extension UIImageView {
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if let currentImageView = gesture.view?.toImageView() {
            let tapLocation = gesture.location(in: gesture.view)
            print(currentImageView.alphaAtPoint(point: tapLocation))
        }
//        if let view = gesture.view {
////            let tapLocation = gesture.l
//            //take the last imageView, where the path contains tapLocation
//            //add a panGesture to that view
//        }
        print("tap")
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        //perform the move only if the touch begins inside the path and nowhere else
        let translation = gesture.translation(in: gesture.view)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(CGPoint.zero, in: gesture.view)
    }
    
}

