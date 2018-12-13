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

class ViewController: UIViewController {

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    
    var timer: CADisplayLink!
    
    var lastFrameTimeStamp: CFTimeInterval = 0.0
    
    var projectionMatrix: Matrix4!
    
    var objectToDraw: Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        
        view.layer.addSublayer(metalLayer)
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(90.0, aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)

        setupTrianglePSO()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    func setupTrianglePSO()
    {
        objectToDraw = Cube(device: self.device)
        
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
        
        let cameraMatrix = Matrix4()
        cameraMatrix.translate(0.0, y: 0.0, z: -7.0)
        cameraMatrix.rotateAroundX(Matrix4.degrees(toRad: 25.0), y: 0.0, z: 0.0)
        objectToDraw.render(commandQueue: self.commandQueue, pipelineState: self.pipelineState, drawable: drawable, viewMatrix: cameraMatrix, projectionMatrix: self.projectionMatrix, clearColor: nil)
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
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        
        autoreleasepool{
            self.render()
        }
    }
}
