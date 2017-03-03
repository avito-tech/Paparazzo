#import <CoreImage/CoreImage.h>

@interface CIContext (XCode8Workaround)

// NOTE: см. http://stackoverflow.com/questions/39570644/cicontext-initwithoptions-unrecognized-selector-sent-to-instance-0x170400960
+ (nonnull CIContext *)fixed_contextWithOptions:(nullable NSDictionary<NSString *, id> *)options;

@end
