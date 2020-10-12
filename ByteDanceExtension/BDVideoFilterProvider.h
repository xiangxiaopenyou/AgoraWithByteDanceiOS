//
//  BDVideoFilterProvider.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import <Foundation/Foundation.h>
#import "AgoraRtcKit2/AgoraVideoFilterProviderDelegate.h"

@protocol AgoraByteDanceDataReceiver <NSObject>
- (void)onDataReceive:(NSString * _Nullable)data;
@end

NS_ASSUME_NONNULL_BEGIN

@interface BDVideoFilterProvider : NSObject <AgoraVideoFilterProviderDelegate>
@property (nonatomic, weak) id<AgoraByteDanceDataReceiver> dataReceiver;
+ (instancetype)sharedInstance;

- (void)loadProcessor;
- (int)setParameter:(NSString *)parameter;
@end

NS_ASSUME_NONNULL_END
