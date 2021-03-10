//
//  Agora RTC/MEDIA SDK
//
//  Created by LLF in 2021-01.
//  Copyright (c) 2021 Agora.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRtcOptional.h"

@interface NSArray<__covariant ObjectType> (SafeOptional)

- (nonnull AgoraRtcOptional<ObjectType> *)agora_firstOptionalObjectPassingTest:(NS_NOESCAPE BOOL (^_Nonnull const)(const ObjectType _Nonnull aVal))testBlock __attribute__((pure));

@end
