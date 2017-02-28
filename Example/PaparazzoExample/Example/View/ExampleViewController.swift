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
    
    var onShowMediaPickerButtonTap: (() -> ())? {
        get { return exampleView?.onShowMediaPickerButtonTap }
        set { exampleView?.onShowMediaPickerButtonTap = newValue }
    }
    
    var onShowPhotoLibraryButtonTap: (() -> ())? {
        get { return exampleView?.onShowPhotoLibraryButtonTap }
        set { exampleView?.onShowPhotoLibraryButtonTap = newValue }
    }
}
