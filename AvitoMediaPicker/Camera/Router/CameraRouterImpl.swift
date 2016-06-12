import Marshroute

final class CameraRouterImpl: /*BaseRouter,*/ CameraRouter {

    func showPhotoLibrary(moduleOutput moduleOutput: PhotoLibraryModuleOutput) {
        print("showPhotoLibrary")
    }
    
    func showCroppingModule(photo photo: AnyObject, moduleOutput: CroppingModuleOutput) {
        print("showCroppingModule")
    }
}
