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
    
    var vertexBuffer: MTLBuffer!
    
    let vertexData: [Float] =
    [
        0.0,  1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        
        view.layer.addSublayer(metalLayer)

        loadData()
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(gameLoop))
        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    func loadData()
    {
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
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
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0xcc/0xff,
            green: 0.0,
            blue: 0.0,
            alpha: 1.0
        )
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    @objc func gameLoop() {
        autoreleasepool{
            self.render()
        }
    }
}
