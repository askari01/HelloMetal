//
//  ViewController.swift
//  HelloMetal
//
//  Created by John Yang on 12/06/16.
//
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
//    var vertexBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    
//    var objectToDraw: Triangle!
    var objectToDraw: Cube!
    var projectionMatrix: Matrix4!
    
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
//    let vertexData:[Float] = [
//        0.0, 1.0, 0.0,
//        -1.0, -1.0, 0.0,
//        1.0, -1.0, 0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(
            Matrix4.degreesToRad(85.0),
            aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height),
            nearZ: 0.01,
            farZ: 100.0)
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
//        let dataSize = vertexData.count * sizeofValue(vertexData[0])
//        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: [])
        
//        objectToDraw = Triangle(device: device)
        
        objectToDraw = Cube(device: device)
//        objectToDraw.positionX = 0.0
//        objectToDraw.positionY =  0.0
//        objectToDraw.positionZ = -2.0
//        objectToDraw.rotationZ = Matrix4.degreesToRad(45);
//        objectToDraw.scale = 0.5
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do {
           try self.pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let pipelineError as NSError {
            print("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.newCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(_:)))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func render() {
        
        let drawable = metalLayer.nextDrawable()!
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degreesToRad(25), y: 0.0, z: 0.0)
        
        objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    }
    
    func newFrame(displayLink: CADisplayLink){
        
        if lastFrameTimestamp == 0.0 {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        let elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        gameloop(timeSinceLastUpdate: elapsed)
    }
    
    func gameloop(timeSinceLastUpdate timeInterval: CFTimeInterval) {
        
        objectToDraw.updateWithDelta(timeInterval)
        
        autoreleasepool {
            self.render()
        }
    }


}

