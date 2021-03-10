//
//  BDVideoFilter.mm
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#include "BDVideoFilter.h"
#import "BDErrorCode.h"

@implementation BDVideoFilter {
  ByteDance::Extension::BDProcessor* _processor;
  BOOL _opengl_released;
}

- (instancetype)initWithProcessor:(ByteDance::Extension::BDProcessor *)processor {
  if (self = [super init]) {
    _processor = processor;
    _opengl_released = NO;
  }
  return self;
}

- (void)dealloc {
  if (_processor && !_opengl_released) {
    _processor->releaseOpenGL();
  }
  _processor = nullptr;
}

- (BOOL)adaptVideoFrame:(AgoraExtVideoFrame *)srcFrame dstFrame:(AgoraExtVideoFrame **)dstFrame {
  if (_processor) {
    *dstFrame = nil;
    _processor->processFrame(srcFrame);
    *dstFrame = srcFrame;
    return true;
  }
  return false;
}

- (BOOL)didDataStreamWillStart {
  if (_processor) {
    return _processor->initOpenGL();
  }
  
  return false;
}

- (void)didDataStreamWillStop {
  if (_processor) {
    _processor->releaseOpenGL();
    _opengl_released = YES;
  }
}

- (NSInteger)getPropertyWithKey:(NSString *)key value:(NSData **)value { return -1; }

- (BOOL)isEnabled { return false; }

- (void)setEnabled:(BOOL)enabled { }

- (NSInteger)setPropertyWithKey:(NSString * _Nonnull)key value:(NSData * _Nonnull)value { return -1; }

@end

