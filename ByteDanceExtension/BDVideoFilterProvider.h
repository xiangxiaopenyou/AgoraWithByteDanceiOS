//
//  BDVideoFilterProvider.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import <Foundation/Foundation.h>
#import "BDVideoFilterProviderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDVideoFilterProvider : NSObject

@property (nonatomic, weak) id<BDDataReceiverDelegate> dataReceiveDelegate;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface BDVideoFilter : NSObject <BDVideoFilterDelegate>

@end

NS_ASSUME_NONNULL_END
