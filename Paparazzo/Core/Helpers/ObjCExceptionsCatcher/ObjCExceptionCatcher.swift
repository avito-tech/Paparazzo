import Foundation
#if !COCOAPODS
import ObjCExceptionsCatcherHelpers
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
