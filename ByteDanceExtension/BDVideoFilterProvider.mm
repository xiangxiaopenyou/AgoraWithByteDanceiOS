//
//  BDVideoFilterProvider.m
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import "BDVideoFilterProvider.h"
#include <memory>
#include "BDVideoFilter.h"
#import <OpenGLES/EAGL.h>
#import "BDErrorCode.h"

@interface BDVideoFilterProvider() {
  ByteDance::Extension::BDVideoFilter* _bdVideoFilter;
  EAGLContext* _context;
}

@end

@implementation BDVideoFilterProvider

+ (id)sharedInstance {
    static BDVideoFilterProvider * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDVideoFilterProvider alloc] init];
    });
    return sharedInstance;
}

- (void)loadProcessor {
  std::shared_ptr<ByteDance::Extension::BDProcessor> processor = std::make_shared<ByteDance::Extension::BDProcessor>();
  _bdVideoFilter = new ByteDance::Extension::BDVideoFilter(processor);
}

- (int)setParameter:(NSString *)parameter {
  if (_bdVideoFilter) {
    return _bdVideoFilter->setProperty(nullptr, [parameter UTF8String]);
  }
  
  return 0;
}

- (void)dealloc {
  if (_bdVideoFilter) {
    delete _bdVideoFilter;
    _bdVideoFilter = nullptr;
  }
}

- (void* _Nullable)createVideoFilter {
  if (!_bdVideoFilter) {
    std::shared_ptr<ByteDance::Extension::BDProcessor> processor = std::make_shared<ByteDance::Extension::BDProcessor>();
    _bdVideoFilter = new ByteDance::Extension::BDVideoFilter(processor);
  }
  return _bdVideoFilter;
}

- (bool)destroyVideoFilter:(void * _Nullable)videoFilter {
  if (!videoFilter) {
    return false;
  }
  ByteDance::Extension::BDVideoFilter* filter = static_cast<ByteDance::Extension::BDVideoFilter*>(videoFilter);
  if (filter) {
    delete filter;
    filter = nullptr;
  }
  return true;
}

- (AgoraVideoFilterPosition)videoFilterPosition {
  return AgoraVideoFilterPositionPreEncoder;
}

- (NSString * _Nonnull)name {
  return @"VideoFilterProvider";
}

- (NSString * _Nonnull)vendor {
  return @"ByteDance";
}

- (NSString * _Nonnull)version {
  return @"v3.9.3.1";
}

- (void)onDataReceive:(const char *)data {
  if (data && _bdVideoFilter) {
    _bdVideoFilter->sendEvent(data, data);
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
  if (!message) {
    return;
  }
  
  if (_bdVideoFilter) {
    if (retval != 0) {
      _bdVideoFilter->log(agora::commons::LOG_LEVEL::LOG_LEVEL_ERROR, message);
    } else {
      _bdVideoFilter->log(agora::commons::LOG_LEVEL::LOG_LEVEL_INFO, message);
    }
  }
}

extern "C" void logInfoMessage(std::string message) {
  [[BDVideoFilterProvider sharedInstance] logMessage:0 message:message.c_str()];
}

extern "C" void logMessage(int retval, std::string message) {
  [[BDVideoFilterProvider sharedInstance] logMessage:retval message:message.c_str()];
}

extern "C" void initGL() {
  [[BDVideoFilterProvider sharedInstance] initGL];
}

extern "C" void releaseGL() {
  [[BDVideoFilterProvider sharedInstance] releaseGL];
}

extern "C" void makeCurrent() {
  [[BDVideoFilterProvider sharedInstance] makeCurrent];
}

extern "C" void dataCallback(const char *data) {
  if (!data) { return; }
  dispatch_async(dispatch_get_main_queue(), ^{
    [[BDVideoFilterProvider sharedInstance] onDataReceive:data];
  });
}

@end
