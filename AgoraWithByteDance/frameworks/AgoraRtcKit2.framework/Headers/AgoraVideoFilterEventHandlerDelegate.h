//
//  AgoraVideoFilterEventHandlerDelegate.h
//  Agora Media SDK
//
//  Created by LLF on 2020/9/21.
//

#pragma once

#import <Foundation/Foundation.h>

/**
 * Protocol of Video Filter Event Handler
 * It needs implement by Client App
 */
@protocol AgoraVideoFilterEventHandlerDelegate <NSObject>
- (void)onEvent:(NSString * _Nullable)key value:(NSString * _Nullable)value;
@end
