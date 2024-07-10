import Foundation

final class Resources {
    static let bundle = Bundle(for: Resources.self)
        .path(forResource: "Paparazzo", ofType: "bundle")
        .flatMap { Bundle(path: $0) } ?? Bundle.main
}

func localized(_ string: String, _ arguments: CVarArg...) -> String {
    
    let tableNameInMainBundle = "Paparazzo"
    
    // Search for localized string in Paparazzo.strings in main bundle first...
    let format = NSLocalizedString(
        string,
        tableName: tableNameInMainBundle,
        bundle: Bundle.main,
        // ...use Localizable.strings bundled with Paparazzo as a fallback
        value: NSLocalizedString(string, bundle: Resources.bundle, comment: ""),
        comment: ""
    )
    
    return String(format: format, arguments: arguments)
}
