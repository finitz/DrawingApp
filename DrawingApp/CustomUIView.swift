//
//  CustomUIView.swift
//  DrawingApp
//
//  Created by 17 on 9/18/19.
//  Copyright © 2019 17. All rights reserved.
//

import UIKit

class CustomUIView: UIView {

    enum Mode {
        case brush
        case marker
        case eraser
        case move
    }
    
    var strokeColour = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
    var strokeSize = 15
    var mode = Mode.brush
    var drawingPath = UIBezierPath()
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
        drawingPath = UIBezierPath()
        drawingPath.lineWidth = CGFloat(strokeSize)
        if mode == .brush {
            drawingPath.lineCapStyle = .round
        } else {
            drawingPath.lineCapStyle = .square
        }
        drawingPath.lineJoinStyle = .round
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move && mode != .eraser {
            let touch = touches.first!
            setupPath()
            drawingPath.move(to: touch.location(in: self))
            updateImageView()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move && mode != .eraser {
            let touch = touches.first!
            drawingPath.addLine(to: touch.location(in: self))
            updateImageView()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move && mode != .eraser {
            let touch = touches.first!
            endTouches(at: touch.location(in: self))

            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
            strokeColour.setStroke()
            if mode == .brush {
                drawingPath.stroke(with: .normal, alpha: 1.0)
            } else {
                drawingPath.stroke(with: .normal, alpha: 0.5)
            }
            
            let newLayerImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let newLayer = UIImageView(image: newLayerImage)


            layerArray.append(newLayer)
            self.addSubview(newLayer)
            self.bringSubviewToFront(drawingView)
            drawingView.image = nil

            redoLayerArray.removeAll()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode != .move && mode != .eraser {
            let touch = touches.first!
            endTouches(at: touch.location(in: self))
        }
    }

    func endTouches(at point: CGPoint) {
        drawingPath.addLine(to: point)
        updateImageView()
    }
    
    func updateImageView() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        strokeColour.setStroke()
        if mode == .brush {
            drawingPath.stroke(with: .normal, alpha: 1.0)
        } else {
            drawingPath.stroke(with: .normal, alpha: 0.5)
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        drawingView.image = img

        setNeedsDisplay()
    }
    
    func clear() {
        drawingView.image = nil
        drawingView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        layerArray.removeAll()
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
        
    var moveLayerIndex: Int?
        
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            
            for (i, view) in self.subviews.enumerated() {
                if view.toImageView().alphaAtPoint(point: gesture.location(in: view)) != 0.0 {
                        moveLayerIndex = i
                    }
            }

        case .changed:
            let translation = gesture.translation(in: gesture.view)
            guard let index = moveLayerIndex else {return}
            self.subviews[index].center = CGPoint(x: self.subviews[index].center.x + translation.x, y: self.subviews[index].center.y + translation.y)
            
            gesture.setTranslation(CGPoint.zero, in: gesture.view)
            
        case .ended:
            moveLayerIndex = nil

        default:
            break
        }
    }
    
    var indexOfViewToBeRemoved: Int?
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        guard gesture.view != nil, self.subviews.count != 1 else { return }
        
        if gesture.state == .ended {
            for (i, view) in self.subviews.enumerated() {
                if view.toImageView().alphaAtPoint(point: gesture.location(in: view)) != 0.0 {
                    indexOfViewToBeRemoved = i
                }
            }
            
            if let index = indexOfViewToBeRemoved, self.subviews.count != 1 {
                self.subviews[index].removeFromSuperview()
            }
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

extension UIView {
    func toImageView() -> UIImageView {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return UIImageView(image: image)
    }
}

