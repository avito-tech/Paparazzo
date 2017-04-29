import UIKit

final class ExampleViewController: UIViewController, ExampleViewInput {
    
    private var exampleView: ExampleView? {
        return view as? ExampleView
    }
    
    override func loadView() {
        view = ExampleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Disposables
    
    private var disposables = [AnyObject]()
    
    func addDisposable(_ disposable: AnyObject) {
        disposables.append(disposable)
    }
    
    // MARK: - ExampleViewInput
    
    func setMediaPickerButtonTitle(_ title: String) {
        exampleView?.setMediaPickerButtonTitle(title)
    }
    
    func setMaskCropperButtonTitle(_ title: String) {
        exampleView?.setMaskCropperButtonTitle(title)
    }
    
    func setPhotoLibraryButtonTitle(_ title: String) {
        exampleView?.setPhotoLibraryButtonTitle(title)
    }
    
    var onShowMediaPickerButtonTap: (() -> ())? {
        get { return exampleView?.onShowMediaPickerButtonTap }
        set { exampleView?.onShowMediaPickerButtonTap = newValue }
    }
    
    var onShowPhotoLibraryButtonTap: (() -> ())? {
        get { return exampleView?.onShowPhotoLibraryButtonTap }
        set { exampleView?.onShowPhotoLibraryButtonTap = newValue }
    }
    
    var onMaskCropperButtonTap: (() -> ())? {
        get { return exampleView?.onMaskCropperButtonTap }
        set { exampleView?.onMaskCropperButtonTap = newValue }
    }
}
