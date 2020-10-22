//
//  AgoraMediaFilterExtensionDelegate.h
//  Agora SDK
//
//  Created by LLF on 2020-9-21.
//  Copyright (c) 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraMediaFilterEventDelegate.h"

@protocol AgoraMediaFilterExtensionDelegate <NSObject>

- (NSString * __nonnull)vendor;

- (void * __nullable)mediaFilterProvider;
@optional
- (id<AgoraMediaFilterEventDelegate> __nullable)mediaFilterObserver;
@end
