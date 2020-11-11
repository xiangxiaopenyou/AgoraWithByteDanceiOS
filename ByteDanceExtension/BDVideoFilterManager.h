//
//  BDVideoFilterProvider.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import <Foundation/Foundation.h>
#include "AgoraRtcKit2/AgoraMediaFilterExtensionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class BDVideoExtensionObject;

@interface BDVideoFilterManager : NSObject
+ (instancetype)sharedInstance;

+ (NSString * __nonnull)vendorName;
- (BDVideoExtensionObject * __nonnull)mediaFilterExtension;
- (void)loadPlugin;
- (int)setParameter:(NSString * __nullable)parameter;
@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface BDVideoExtensionObject : NSObject <AgoraMediaFilterExtensionDelegate>
@property (copy, nonatomic) NSString * __nonnull vendorName;
@property (assign, nonatomic) void * __nullable mediaFilterProvider;

@end

NS_ASSUME_NONNULL_END

