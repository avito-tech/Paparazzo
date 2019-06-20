extension UIDevice {
    
    static func systemVersionLessThan(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == ComparisonResult.orderedAscending
    }
    
    var isIPhoneX: Bool {
        let iPhonePlusHeight = CGFloat(2208)
        return userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height > iPhonePlusHeight
    }
    
    var hasTopSafeAreaInset: Bool {
        if #available(iOS 11.0, *) {
            let top = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            return top > 0
        }
        return false
    }
    
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            // safeAreaInsets.top on device
            //  - with notch: 44.0 (iPhone X, XS, XR, etc.)
            //  - without notch: 24.0 (iPad Pro 12.9" 3rd generation), 20.0 (iPhone 6/7/8/etc)
            let top = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            return top > 24
        }
        return false
    }
}
