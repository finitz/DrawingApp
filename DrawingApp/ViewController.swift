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
    
    @IBAction func clearCanvas(_ sender: UIButton) {
        canvasView.clear()
    }
    
    @IBAction func undoBtuttonTap(_ sender: UIButton) {
        canvasView.undo()
    }
    
    @IBAction func redoButtonTap(_ sender: UIButton) {
        canvasView.redo()
    }
    
    @IBAction func eraserMode(_ sender: UIButton) {
        canvasView.mode = .eraser
    }
    
    @IBAction func brushMode(_ sender: UIButton) {
        canvasView.mode = .brush
        if let panGestr = panGestr {
            canvasView.removeGestureRecognizer(panGestr)
        }
    }
    
    var panGestr: UIPanGestureRecognizer?
    
        
    @IBAction func moveLayer(_ sender: UIButton) {
        canvasView.mode = .move
        panGestr = UIPanGestureRecognizer(target: canvasView, action: #selector(CustomUIView.handlePanGesture(gesture:)))

        canvasView.addGestureRecognizer(panGestr!)
    }
    
    @IBAction func fillBUttonTap(_ sender: UIButton) {
        
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

