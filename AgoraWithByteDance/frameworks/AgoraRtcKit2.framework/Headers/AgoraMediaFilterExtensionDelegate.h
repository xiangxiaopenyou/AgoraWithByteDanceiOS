//
//  AgoraMediaFilterExtensionDelegate.h
//  Agora SDK
//
//  Created by LLF on 2020-9-21.
//  Copyright (c) 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AgoraMediaFilterExtensionDelegate <NSObject>

/* Media filter(audio filter or video fitler) name, shoud be unique
 *
 */
- (NSString * __nonnull)vendor;
/* Meida filter(audio filter or video filter) pointer,
 * this pointer should implement IExtensionProvider interface
 */
- (void * __nullable)mediaFilterProvider;
@end
