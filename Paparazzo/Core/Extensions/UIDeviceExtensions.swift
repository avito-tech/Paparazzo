extension UIDevice {
    
    static func systemVersionLessThan(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == ComparisonResult.orderedAscending
    }
    
    var isIPhoneX: Bool {
        let iPhonePlusHeight = CGFloat(2208)
        return userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height > iPhonePlusHeight
    }
    
    var hasSensorHousing: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        }
        return false
    }
}
