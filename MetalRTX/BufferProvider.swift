//
//  BufferProvider.swift
//  MetalRTX
//
//  Created by Florian Schut on 14/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

import Metal
import Foundation

class BufferProvider: NSObject {
	let inflightBufferCount: Int
	private var uniformBuffers: [MTLBuffer]
	private var availableBufferIndex: Int = 0
	var availableResourceSemaphore: DispatchSemaphore
	
	init(device: MTLDevice, inflightBufferCount: Int, sizeOfUniformBuffer: Int){
		availableResourceSemaphore = DispatchSemaphore(value: inflightBufferCount)
		
		self.inflightBufferCount = inflightBufferCount
    	uniformBuffers = [MTLBuffer]()
		
		for _ in 0...inflightBufferCount-1 {
			let uniformBuffer = device.makeBuffer(length: sizeOfUniformBuffer, options: [])
			uniformBuffers.append(uniformBuffer!)
		}
	}
	
	deinit {
		for _ in 0...self.inflightBufferCount{
			self.availableResourceSemaphore.signal()
		}
	}
	
	func nextUniformBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer{
		let buffer = uniformBuffers[availableBufferIndex]
		
		let bufferPointer = buffer.contents()
		
		memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
		memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
		
		availableBufferIndex += 1
		if availableBufferIndex == inflightBufferCount{
			availableBufferIndex = 0
		}
		return buffer
	}
}
