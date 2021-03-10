//
//  BDVideoFilterProvider.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/10/21.
//

#pragma once

#include <AgoraRtcKit/AgoraMediaFilterExtensionDelegate.h>
#include "BDProcessor.h"

@interface BDExtensionProvider : NSObject <AgoraExtProviderDelegate>

- (instancetype)initWithProcessor:(ByteDance::Extension::BDProcessor *)processor;
- (NSInteger)log:(AgoraExtLogLevel)level message:(NSString * __nullable)message;
- (NSInteger)fireEvent:(NSString * __nonnull)vendor key:(NSString * __nullable)key value:(NSString * __nullable)value;

@end
