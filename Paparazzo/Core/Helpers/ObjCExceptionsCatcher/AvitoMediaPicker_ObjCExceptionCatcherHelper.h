#import <Foundation/Foundation.h>

@interface AvitoMediaPicker_ObjCExceptionCatcherHelper: NSObject

+ (void)try:(nonnull NS_NOESCAPE void(^)())tryBlock
      catch:(nonnull void(^)(NSException * _Nonnull))catchBlock
    finally:(nonnull void(^)())finallyBlock;

@end
