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
    var redoLayer = UIImageView()
    
    
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
    
//    func addPanGestureRecognizer(to view: UIImageView) {
////        view.isUserInteractionEnabled = true
//
//    }
//
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {

//        swit ges case gesture.

        print("pan action")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if mode != .move {
            let touch = touches.first!
            setupPath()
            path.move(to: touch.location(in: self))
            updateImageView()
//        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if mode != .move {
            let touch = touches.first!
            path.addLine(to: touch.location(in: self))
            updateImageView()
//        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if mode != .move {
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
            //        addPanGestureRecognizer(to: newLayer)
            layerArray.append(newLayer)
            self.addSubview(newLayer)
            self.bringSubviewToFront(drawingView)
            
            redoLayerArray.removeAll()
//        }
        
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
