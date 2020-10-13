//
//  BDVideoFilterProvider.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import <Foundation/Foundation.h>
#import "AgoraRtcKit2/AgoraVideoFilterProviderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDVideoFilterProvider : NSObject <AgoraVideoFilterProviderDelegate>
+ (instancetype)sharedInstance;

- (void)loadProcessor;
- (int)setParameter:(NSString *)parameter;
@end

NS_ASSUME_NONNULL_END
