#import "CIContext+XCode8Workaround.h"

@implementation CIContext (XCode8Workaround)

+ (CIContext *)fixed_contextWithOptions:(NSDictionary<NSString *, id> *)options {
    return [CIContext contextWithOptions:options];
}

@end
