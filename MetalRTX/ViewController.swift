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
    }
    
    


}

