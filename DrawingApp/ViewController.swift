//
//  ViewController.swift
//  DrawingApp
//
//  Created by 17 on 9/18/19.
//  Copyright © 2019 17. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBOutlet weak var canvasView: CustomUIView!
    @IBOutlet var colourButtonArray: [UIButton]!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var moveButton: UIButton!
    var panGesture: UIPanGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!

    func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: canvasView, action: #selector(CustomUIView.handlePanGesture(gesture:)))
        tapGesture = UITapGestureRecognizer(target: canvasView, action: #selector(CustomUIView.handleTap(gesture:)))
        canvasView.addGestureRecognizer(panGesture)
        canvasView.addGestureRecognizer(tapGesture)
        panGesture.isEnabled = false
        tapGesture.isEnabled = false
    }
    
    @IBAction func clearCanvas(_ sender: UIButton) {
        canvasView.clear()
        panGesture.isEnabled = false
        tapGesture.isEnabled = false
    }
    
    @IBAction func undoBtuttonTap(_ sender: UIButton) {
        canvasView.undo()
    }
    
    @IBAction func redoButtonTap(_ sender: UIButton) {
        canvasView.redo()
    }
    
    @IBAction func eraserButtonTap(_ sender: UIButton) {
        canvasView.mode = .eraser
        tapGesture.isEnabled = true
        panGesture.isEnabled = false
    }
    
    @IBAction func brushButtonTap(_ sender: UIButton) {
        canvasView.mode = .brush
        panGesture.isEnabled = false
    }
    
    @IBAction func markerPenButtonTap(_ sender: UIButton) {
        canvasView.mode = .marker
        panGesture.isEnabled = false
    }
    
    @IBAction func moveButtonTap(_ sender: UIButton) {
        canvasView.mode = .move
        tapGesture.isEnabled = false
        panGesture.isEnabled = true
    }
        
    @IBAction func colourButtonTap(_ sender: UIButton) {
        if let newColour = sender.backgroundColor {
            canvasView.strokeColour = newColour
        }
    }
    
    @IBAction func changeStrokeSize(_ sender: UISlider) {
        canvasView.strokeSize = Int(sender.value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.clipsToBounds = true
        setupGestures()
    }

    override func loadView() {
        super.loadView()
        if let undoButtonImage = UIImage(named: "undo") {
            undoButton.setImage(resizeImage(image: undoButtonImage, targetSize: CGSize(width: 30, height: 30)), for: .normal)
        }
        
        if let redoButtonImage = UIImage(named: "redo") {
            redoButton.setImage(resizeImage(image: redoButtonImage, targetSize: CGSize(width: 30, height: 30)), for: .normal)
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
}

