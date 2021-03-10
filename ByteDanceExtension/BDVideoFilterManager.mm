//
//  BDVideoFilterProvider.m
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import "BDVideoFilterManager.h"
#include <memory>
#include "BDVideoFilterProvider.h"
#include "BDProcessor.h"
#import <OpenGLES/EAGL.h>
#import "BDErrorCode.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@implementation BDVideoExtensionObject

- (id<AgoraExtProviderDelegate>)mediaFilterProvider {
  return _mediaFilterProvider;
}

- (NSString *)vendor {
  return _vendorName;
}

@end

@interface BDVideoFilterManager() {
  ByteDance::Extension::BDProcessor* _bdProcessor;
  BDExtensionProvider* _bdProvider;
  EAGLContext* _context;
}

@end

static NSString *kVendorName = @"ByteDance.VideoFilter";

@implementation BDVideoFilterManager

+ (id)sharedInstance {
    static BDVideoFilterManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDVideoFilterManager alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)vendorName {
  return kVendorName;
}

- (BDVideoExtensionObject *)mediaFilterExtension {
  BDVideoExtensionObject *obj = [BDVideoExtensionObject new];
  obj.vendorName = kVendorName;
  
  if (_bdProvider) {
    obj.mediaFilterProvider = _bdProvider;
  } else {
    obj.mediaFilterProvider = nil;
  }
  
  return obj;
}

- (void)loadPlugin {
  _bdProcessor = new ByteDance::Extension::BDProcessor();
  if (_bdProcessor) {
    _bdProvider = [[BDExtensionProvider alloc] initWithProcessor:_bdProcessor];
  }
}

- (int)setParameter:(NSString *)parameter {
  if (_bdProcessor) {
    std::string p([parameter UTF8String]);
    return _bdProcessor->setParameters(p);
  }
  
  return 0;
}

- (void)onDataReceive:(NSString *)data {
  if (data && data.length && _bdProvider) {
    [_bdProvider fireEvent:kVendorName key:data value:data];
  }
}

- (void)initGL {
  if (_context == nil) {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  }
  [EAGLContext setCurrentContext:_context];
}

- (void)releaseGL {
  [EAGLContext setCurrentContext:nil];
  _context = nil;
}

- (void)makeCurrent {
  EAGLContext *prev = [EAGLContext currentContext];
  if (prev != _context) {
    [EAGLContext setCurrentContext:_context];
  }
}

- (void)logMessage:(int)retval message:(NSString *)message {
  @autoreleasepool {
    if (!message && message.length) { return; }
    if (!_bdProvider) { return; }
    if (retval == 0) { return; }
    [_bdProvider log:AgoraExtLogLevelWarn message:message];
  }
}

extern "C" void logMessage(int retval, NSString* message) {
  [[BDVideoFilterManager sharedInstance] logMessage:retval message:message];
}

extern "C" void initGL() {
  [[BDVideoFilterManager sharedInstance] initGL];
}

extern "C" void releaseGL() {
  [[BDVideoFilterManager sharedInstance] releaseGL];
}

extern "C" void makeCurrent() {
  [[BDVideoFilterManager sharedInstance] makeCurrent];
}

extern "C" void dataCallback(NSString* data) {
  if (!data || !data.length) { return; }
  [[BDVideoFilterManager sharedInstance] onDataReceive:data];
}

@end
