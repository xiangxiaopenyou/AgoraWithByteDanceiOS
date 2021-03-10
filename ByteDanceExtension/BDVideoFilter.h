//
//  BDVideoFilter.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#pragma once

#import <AgoraRtcKit/AgoraVideoFilterDelegate.h>
#include "BDProcessor.h"

@interface BDVideoFilter : NSObject <AgoraVideoFilterDelegate>
- (instancetype)initWithProcessor:(ByteDance::Extension::BDProcessor *)processor;
@end
