//
//  MetalRenderer.swift
//  MetalRTX
//
//  Created by Florian Schut on 04/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

import Metal
import MetalKit
import simd


protocol MetalViewControllerDelegate : class{
    func updateLogic(timeSinceLastUpdate: CFTimeInterval)
    func renderObjects(drawable: CAMetalDrawable)
}

class MetalRenderer: NSObject, MTKViewDelegate {

    public let device: MTLDevice
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    var projectionMatrix: float4x4!
    
    weak var metalViewControllerDelegate: MetalViewControllerDelegate?
    
    init? (metalKitView: MTKView) {
        // Do any additional setup after loading the view, typically from a nib.
		self.device = metalKitView.device!
		self.commandQueue = device.makeCommandQueue()
		
		let defaultLibrary = device.makeDefaultLibrary()!
		let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment_shader")
		let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex_shader")
		
		let pipelineStateDesc = MTLRenderPipelineDescriptor()
		pipelineStateDesc.vertexFunction = vertexProgram
		pipelineStateDesc.fragmentFunction = fragmentProgram
		pipelineStateDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
		
		pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDesc)
		
        super.init()
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
	
	func draw(in view: MTKView) {
		render(view.currentDrawable)
	}
	
	func render(_ drawable: CAMetalDrawable?) {
		guard let drawable = drawable else { return }
		self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
	}
	
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0),
															 aspectRatio: Float(size.width / size.height),
															 nearZ: 0.01, farZ: 100.0)
	}
	
	class func loadTexture(device: MTLDevice, textureName: String) throws ->MTLTexture{
		let textureLoader = MTKTextureLoader(device: device)
		
		let textureLoaderOptions = [
			MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
			MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
		]
		
		return try textureLoader.newTexture(name: textureName, scaleFactor: 1.0,
											bundle: nil, options: textureLoaderOptions)
	}
}
