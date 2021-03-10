//
//  Agora RTC/MEDIA SDK
//
//  Created by LLF in 2021-01.
//  Copyright (c) 2021 Agora.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRtcOptional.h"

@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (SafeOptional)

- (nonnull AgoraRtcOptional<NSDictionary<KeyType, ObjectType> *> *)op;
- (nonnull AgoraRtcOptional<ObjectType> *)agora_OptionalForKey:(nonnull KeyType)aKey __attribute__((pure));
- (nonnull AgoraRtcOptional<ObjectType> *)agora_OptionalForKey:(nonnull KeyType)aKey of:(nonnull Class)aClass __attribute__((pure));
- (nonnull AgoraRtcOptional<ObjectType> *)agora_firstOptionalKeyPassingTest:(NS_NOESCAPE BOOL (^_Nonnull const)(const KeyType _Nonnull aKey, const ObjectType _Nonnull aVal))testBlock __attribute__((pure));

@end
