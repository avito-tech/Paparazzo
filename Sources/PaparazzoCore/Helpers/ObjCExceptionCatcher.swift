import Foundation
#if canImport(ObjCExceptionsCatcher)
import ObjCExceptionsCatcher
#endif

final class ObjCExceptionCatcher {
    static func tryClosure(
        tryClosure: @convention(block) () -> (),
        catchClosure: @convention(block) @escaping (NSException) -> (),
        finallyClosure: @convention(block) @escaping () -> () = {})
    {
        AvitoMediaPicker_ObjCExceptionCatcherHelper.`try`(tryClosure, catch: catchClosure, finally: finallyClosure)
    }
}
