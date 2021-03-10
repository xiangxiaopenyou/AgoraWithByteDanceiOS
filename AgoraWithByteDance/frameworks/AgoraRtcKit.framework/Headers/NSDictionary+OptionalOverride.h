//
//  Agora RTC/MEDIA SDK
//
//  Created by LLF in 2021-01.
//  Copyright (c) 2021 Agora.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRtcOptional.h"

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (OptionalOverride)

- (nonnull AgoraRtcOptional<ObjectType> *)objectForKeyedSubscript:(nonnull KeyType)key;
+ (void)agora_enableAgoraRtcOptionalByDefault;

@end
