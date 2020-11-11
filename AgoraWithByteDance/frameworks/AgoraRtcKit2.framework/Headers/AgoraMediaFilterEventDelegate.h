//
//  AgoraMediaFilterEventDelegate.h
//  Agora SDK
//
//  Created by LLF on 2020-9-21.
//  Copyright (c) 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AgoraMediaFilterEventDelegate <NSObject>

/* Meida filter(audio filter or video filter) event callback
 */
- (void)onEvent:(NSString * __nullable)vendor
            key:(NSString * __nullable)key
     json_value:(NSString * __nullable)json_value;
@end
