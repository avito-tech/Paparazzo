import AVFoundation
import ImageSource

#if !(arch(i386) || arch(x86_64))
import MetalKit
#endif

#if !(arch(i386) || arch(x86_64))
@available(iOS 9.0, *)
class CameraOutputMTKView: MTKView, CameraOutputRenderView, CameraCaptureOutputHandler {
    // MARK: - State
    private var hasWindow = false
    private var bufferQueue = DispatchQueue.main
    
    // Metal
    private var textureCache : CVMetalTextureCache?
    private var imageTexture: MTLTexture?

    lazy private var commandQueue: MTLCommandQueue? = {
        return device?.makeCommandQueue()
    }()
    
    private var renderPipelineState: MTLRenderPipelineState?

    private let semaphore = DispatchSemaphore(value: 1)

    
    // MARK: - Init
    required init(captureSession: AVCaptureSession, outputOrientation: ExifOrientation, mtlDevice: MTLDevice) {
        self.orientation = outputOrientation

        super.init(frame: .zero, device: mtlDevice)

        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device!, nil, &textureCache)
        
        framebufferOnly = true
        colorPixelFormat = .bgra8Unorm
        contentScaleFactor = UIScreen.main.scale
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentMode = .scaleAspectFill
        
        bufferQueue = CaptureSessionPreviewService.startStreamingPreview(
            of: captureSession,
            to: self,
            isMirrored: outputOrientation.isMirrored)
        
        initializeRenderPipelineState()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        let hasWindow = (window != nil)
        
        bufferQueue.async { [weak self] in
            self?.hasWindow = hasWindow
        }
    }
    
    // MARK: - CameraOutputView
    
    var orientation: ExifOrientation
    var onFrameDraw: (() -> ())?
    
    var imageBuffer: CVImageBuffer? {
        didSet {
            if hasWindow {
                display()
            }
        }
    }
    
    private func display() {
        guard let imageBuffer  = imageBuffer else { return }
        let width = CVImageBufferGetDisplaySize(imageBuffer).width
        let height = CVImageBufferGetDisplaySize(imageBuffer).height
        
        var imageTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, imageBuffer, nil, colorPixelFormat, Int(width), Int(height), 0, &imageTexture)

        guard
            let unwrappedImageTexture = imageTexture,
            let texture = CVMetalTextureGetTexture(unwrappedImageTexture),
            result == kCVReturnSuccess
        else { return }
        
        self.imageTexture = texture
        drawableSize = CGSize(width: width, height: height)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        autoreleasepool {
            guard
                var texture = imageTexture,
                let device = device,
                let commandBuffer = commandQueue?.makeCommandBuffer()
                else {
                    _ = semaphore.signal()
                    return
            }
            
            render(texture: texture, withCommandBuffer: commandBuffer, device: device)
        }
    }
    
    private func render(texture: MTLTexture, withCommandBuffer commandBuffer: MTLCommandBuffer, device: MTLDevice) {
        guard
            let currentRenderPassDescriptor = self.currentRenderPassDescriptor,
            let currentDrawable = self.currentDrawable,
            let renderPipelineState = renderPipelineState,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
            else {
                semaphore.signal()
                return
        }
        
        encoder.pushDebugGroup("RenderFrame")
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.popDebugGroup()
        encoder.endEncoding()
        
        commandBuffer.addScheduledHandler { [weak self] (buffer) in
            guard let unwrappedSelf = self else { return }
            
            unwrappedSelf.semaphore.signal()
        }
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    private func initializeRenderPipelineState() {
        guard
            let device = device,
            let filepath = Resources.bundle.path(forResource: "CameraShader", ofType: "metallib"),
            let library = try? device.makeLibrary(filepath: filepath)
        else { return }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = 1
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture")
        
        do {
            try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch {
            assertionFailure("Failed creating a render state pipeline. Can't render the texture without one.")
            return
        }
    }
}
#endif
