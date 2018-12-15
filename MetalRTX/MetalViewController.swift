//
//  ViewController.swift
//  MetalRTX
//
//  Created by Florian Schut on 04/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import simd


protocol MetalViewControllerDelegate : class{
    func updateLogic(timeSinceLastUpdate: CFTimeInterval)
    func renderObjects(drawable: CAMetalDrawable)
}

class MetalViewController: UIViewController {

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    
    var timer: CADisplayLink!
    
    var lastFrameTimeStamp: CFTimeInterval = 0.0
    
    var projectionMatrix: Matrix4!
    
    weak var metalViewControllerDelegate: MetalViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true

        
        view.layer.addSublayer(metalLayer)

        setupTrianglePSO()
        
        timer = CADisplayLink(target: self, selector: #selector(MetalViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: .default)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let window = view.window{
			let scale = window.screen.nativeScale
			let layerSize = view.bounds.size
			
			view.contentScaleFactor = scale
			
			metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
			metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
			
			projectionMatrix = Matrix4.makePerspectiveViewAngle(90.0, aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
		}
	}
    
    func setupTrianglePSO()
    {        
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment_shader")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex_shader")
        
        let pipelineStateDesc = MTLRenderPipelineDescriptor()
        pipelineStateDesc.vertexFunction = vertexProgram
        pipelineStateDesc.fragmentFunction = fragmentProgram
        pipelineStateDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDesc)
    }
    
    func render(){
        guard let drawable = metalLayer?.nextDrawable() else {return}
        self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
    }
    
    @objc func newFrame(displayLink: CADisplayLink){
        if lastFrameTimeStamp == 0.0{
            lastFrameTimeStamp = displayLink.timestamp
        }
        
        let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimeStamp
        lastFrameTimeStamp = displayLink.timestamp
        
        gameloop(timeSinceLastUpdate: elapsed)
    }
    
    func gameloop(timeSinceLastUpdate: CFTimeInterval){
        self.metalViewControllerDelegate?.updateLogic(timeSinceLastUpdate: timeSinceLastUpdate)
        
        autoreleasepool{
            self.render()
        }
    }
}
