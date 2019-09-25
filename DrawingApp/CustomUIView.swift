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
    
    struct PathWithContext {
        let line: UIBezierPath
        let colour: UIColor
    }
    
    enum Mode {
        case brush
        case eraser
    }
    
    var strokeColour = #colorLiteral(red: 0.8889197335, green: 0.78421344, blue: 0.1864610223, alpha: 1)
    var eraserColour = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var strokeSize = 20
    var mode = Mode.brush
    var path = UIBezierPath()

    var undoPathArray = [PathWithContext]()
    var redoPath: PathWithContext? = nil
    
    let imageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    func setupPath() {
        path = UIBezierPath()
        path.lineWidth = CGFloat(strokeSize)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        setupPath()
        path.move(to: touch.location(in: self))
        updateImageView()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        path.addLine(to: touch.location(in: self))
        updateImageView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        endTouches(at: touch.location(in: self))
        
        if mode == .brush {
            undoPathArray.append(PathWithContext(line: path, colour: strokeColour))
        }
        canUndo = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        endTouches(at: touch.location(in: self))
    }
    
    func endTouches(at point: CGPoint) {
        path.addLine(to: point)
        updateImageView()
    }
    
    func updateImageView() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        imageView.image?.draw(in: bounds)
       
        if mode == .eraser {
            eraserColour.setStroke()
        } else {
            strokeColour.setStroke()
        }
        path.stroke(with: .normal, alpha: 1.0)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        imageView.image = img
        
        setNeedsDisplay()
    }
    
    func clear() {
        imageView.image = nil

        undoPathArray.removeAll()
        redoPath = nil
    }
    
    var canUndo = false
    var canRedo = false
    
    func undo() {        
        if !undoPathArray.isEmpty, canUndo {
            if let redoPath = undoPathArray.popLast() {
                self.redoPath = redoPath
                UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
                for path in undoPathArray {
                    path.colour.setStroke()
                    path.line.stroke(with: .normal, alpha: 1.0)
                }
                let img = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                imageView.image = img
                setNeedsDisplay()
                
                canRedo = true
            }
        }
    }

    func redo() {
        if let redoPath = self.redoPath, canRedo {
            canUndo = false
            
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
            imageView.image?.draw(in: bounds)
            
            redoPath.colour.setStroke()
            redoPath.line.stroke()
            
            undoPathArray.append(redoPath)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imageView.image = img
            setNeedsDisplay()
            
            canRedo = false
        }
    }
}
