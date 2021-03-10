//
//  Agora RTC/MEDIA SDK
//
//  Created by LLF in 2021-01.
//  Copyright (c) 2021 Agora.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AGORA_FINAL __attribute__((objc_subclassing_restricted))

#define AGORA_ASSERT_AND_RETURN_OPTIONAL(condition) if(!(condition)) { \
NSParameterAssert(condition); \
return AgoraRtcOptional.empty; \
}

AGORA_FINAL
@interface AgoraRtcOptional<SomeType> : NSObject <NSCopying>
@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) BOOL hasValue;
@property (nonatomic, readonly, nonnull) SomeType get;
@property (nonatomic, copy, readonly, nonnull) NSArray<SomeType> *list;

+ (nonnull instancetype)empty;
+ (nonnull instancetype)of:(nonnull SomeType const)aValue;
+ (nonnull instancetype)of:(nonnull SomeType const)aValue as:(nonnull Class)aClass;
+ (nonnull instancetype)ofNullable:(nullable SomeType const)aValue;
+ (nonnull instancetype)ofNullable:(nullable SomeType const)aValue as:(nonnull Class)aClass;
- (nonnull AgoraRtcOptional *)objectForKeyedSubscript:(nonnull id<NSCopying>)key;
- (nonnull AgoraRtcOptional *)objectAtIndexedSubscript:(NSUInteger)idx;

+ (nonnull instancetype)new NS_UNAVAILABLE;
- (nonnull instancetype)init NS_UNAVAILABLE;
@end
