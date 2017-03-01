import Foundation

final class ObjCExceptionCatcher {
    static func tryClosure(
        tryClosure: () -> (),
        catchClosure: @escaping (NSException) -> (),
        finallyClosure: @escaping () -> () = {})
    {
        AvitoMediaPicker_ObjCExceptionCatcherHelper.`try`(tryClosure, catch: catchClosure, finally: finallyClosure)
    }
}
