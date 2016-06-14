import Marshroute

final class CameraRouterImpl: /*BaseRouter,*/ CameraRouter {
    
    typealias AssemblyFactory = protocol<ImageCroppingAssemblyFactory, PhotoLibraryAssemblyFactory>

    private let assemblyFactory: AssemblyFactory

    init(assemblyFactory: AssemblyFactory) {
        self.assemblyFactory = assemblyFactory
    }

    func showPhotoLibrary(moduleOutput moduleOutput: PhotoLibraryModuleOutput) {
        print("showPhotoLibrary")
        let assembly = assemblyFactory.photoLibraryAssembly()
        let viewController = assembly.viewController(moduleOutput: moduleOutput)
        // TODO: открыть через Marshroute
    }
    
    func showCroppingModule(photo photo: AnyObject, moduleOutput: ImageCroppingModuleOutput) {
        print("showCroppingModule")
        let assembly = assemblyFactory.imageCroppingAssembly()
        let viewController = assembly.viewController(photo: photo, moduleOutput: moduleOutput)
        // TODO: открыть через Marshroute
    }
}