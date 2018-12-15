//
//  SceneViewController.swift
//  MetalRTX
//
//  Created by Florian Schut on 14/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

import UIKit

class MySceneViewController: MetalViewController, MetalViewControllerDelegate {
    
    var cameraMatrix = Matrix4()
    var objectToDraw: Cube!
	let panSensivity: Float = 5.0
	var lastPanLocation: CGPoint!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraMatrix.translate(0.0, y: 0.0, z: -3.0)
        self.cameraMatrix.rotateAroundX(Matrix4.degrees(toRad: 25.0), y: 0.0, z: 0.0)
		objectToDraw = Cube(device: device, commandQueue: self.commandQueue)
        self.metalViewControllerDelegate = self;
		
		setupGestures()
    }
    
    func renderObjects(drawable: CAMetalDrawable) {
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, viewMatrix: cameraMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
    }
	
	func setupGestures(){
		let pan = UIPanGestureRecognizer(target: self, action: #selector(MySceneViewController.pan))
		self.view.addGestureRecognizer(pan)
	}
	
	@objc func pan(panGesture: UIPanGestureRecognizer){
		if panGesture.state == UIGestureRecognizer.State.changed{
			let pointInView = panGesture.location(in: self.view)
			let xDelta = Float(lastPanLocation.x - pointInView.x) / Float(self.view.bounds.width) * panSensivity
			let yDelta = Float(lastPanLocation.y - pointInView.y) / Float(self.view.bounds.height) * panSensivity
			
			var rotation = objectToDraw.rotationX
			
			objectToDraw.rotationX -= xDelta
			objectToDraw.rotationY -= yDelta
			lastPanLocation = pointInView
		}else if panGesture.state == UIGestureRecognizer.State.began {
			lastPanLocation = panGesture.location(in: self.view)
		}
	}
}
