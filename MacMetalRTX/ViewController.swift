//
//  ViewController.swift
//  MacMetalRTX
//
//  Created by Florian Schut on 20/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
	var renderer: MetalRenderer!
	var mtkView: MTKView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let mtkView = self.view as? MTKView else{
			print("View attatched is not a MTKView")
			return
		}
		
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else{
			print("Current device does not support Metal")
			return
		}
		
		mtkView.device = defaultDevice
		
		guard let newRenderer = MetalRenderer(metalKitView: mtkView) else {
			print("Renderer cannot be initalized")
			return
		}
		
		renderer = newRenderer
		
		renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
		objectToDraw = Cube(device: defaultDevice, commandQueue: renderer.commandQueue)
		mtkView.delegate = renderer
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

