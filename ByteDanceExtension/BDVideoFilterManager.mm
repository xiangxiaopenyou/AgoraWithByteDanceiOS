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
#import <AgoraRtcKit2/AgoraRtcEngineKit.h>

@implementation BDVideoExtensionObject

- (void *)mediaFilterProvider {
  return _mediaFilterProvider;
}

- (NSString *)vendor {
  return _vendorName;
}

- (id<AgoraMediaFilterEventDelegate>)mediaFilterObserver {
  return _observer;
}

@end

@interface BDVideoFilterManager() {
  agora::agora_refptr<ByteDance::Extension::BDProcessor> _bdProcessor;
  agora::agora_refptr<ByteDance::Extension::BDExtensionProvider> _bdProvider;
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
    obj.mediaFilterProvider = _bdProvider.get();
  } else {
    obj.mediaFilterProvider = nullptr;
  }
  
  return obj;
}

- (void)loadPlugin {
  _bdProcessor = new agora::RefCountedObject<ByteDance::Extension::BDProcessor>();
  if (_bdProcessor) {
    _bdProvider = new agora::RefCountedObject<ByteDance::Extension::BDExtensionProvider>(_bdProcessor);
  }
}

- (int)setParameter:(NSString *)parameter {
  if (_bdProcessor) {
    std::string p([parameter UTF8String]);
    return _bdProcessor->setParameters(p);
  }
  
  return 0;
}

- (void)onDataReceive:(const char *)data {
  if (data && *data && _bdProvider) {
    NSString* dataString = [[NSString alloc] initWithUTF8String:data];
    if (dataString && [dataString length] > 0) {
      _bdProvider->fireEvent([kVendorName UTF8String], [dataString UTF8String]);
    }
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

- (void)logMessage:(int)retval message:(const char *)message {
  if (!message && *message) {
    return;
  }
  
  if (_bdProvider) {
    if (retval != 0) {
      _bdProvider->log(agora::commons::LOG_LEVEL::LOG_LEVEL_ERROR, message);
    }
  }
}

extern "C" void logMessage(int retval, std::string message) {
  [[BDVideoFilterManager sharedInstance] logMessage:retval message:message.c_str()];
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

extern "C" void dataCallback(const char *data) {
  if (!data || !*data) { return; }
  [[BDVideoFilterManager sharedInstance] onDataReceive:data];
}

@end
