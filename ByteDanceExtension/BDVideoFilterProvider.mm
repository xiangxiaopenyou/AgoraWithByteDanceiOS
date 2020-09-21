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

NSString* bd_VideoFilterProviderClassName() {
  return NSStringFromClass([BDVideoFilterProvider class]);
}

@interface BDVideoFilter() {
  std::shared_ptr<ByteDance::Extension::BDVideoFilter> _bdVideoFilter;
}

- (instancetype)initWithVideoFilter:(std::shared_ptr<ByteDance::Extension::BDVideoFilter>)videoFilter;
@end

@implementation BDVideoFilter

- (void)convertVideoFrame:(ByteDance::Extension::BDVideoFrame&)videoFrame to:(id<BDVideoFrameDataSource>)dataSource {
  dataSource.format = videoFrame.type;
  dataSource.width = videoFrame.width;
  dataSource.height = videoFrame.height;
  dataSource.yStride = videoFrame.yStride;
  dataSource.uStride = videoFrame.uStride;
  dataSource.vStride = videoFrame.vStride;
  dataSource.yBuffer = videoFrame.yBuffer;
  dataSource.uBuffer = videoFrame.uBuffer;
  dataSource.vBuffer = videoFrame.vBuffer;
  dataSource.rotation = videoFrame.rotation;
  dataSource.renderTimeMs = videoFrame.renderTimeMs;
  dataSource.avsync_type = videoFrame.avsync_type;
}

- (instancetype)initWithVideoFilter:(std::shared_ptr<ByteDance::Extension::BDVideoFilter>)videoFilter {
  if (self = [super init]) {
    if (!videoFilter) return nil;
    _bdVideoFilter = videoFilter;
  }
  return self;
}

- (int)adaptVideoFrame:(id<BDVideoFrameDataSource> _Nullable)inFrame outFrame:(id<BDVideoFrameDataSource> _Nullable)outFrame {
  const ByteDance::Extension::BDVideoFrame capturedFrame = ByteDance::Extension::BDVideoFrame(inFrame);
  ByteDance::Extension::BDVideoFrame retFrame = ByteDance::Extension::BDVideoFrame(outFrame);
  int retval = _bdVideoFilter->adaptVideoFrame(capturedFrame, retFrame);
  [self convertVideoFrame:retFrame to:outFrame];
  return retval;
}

- (void)setEnable:(BOOL)enabled {
  _bdVideoFilter->setEnabled(enabled);
}

- (bool)onDataStreamWillStart {
  return _bdVideoFilter->onDataStreamWillStart();
}

- (void)onDataStreamWillStop {
  _bdVideoFilter->onDataStreamWillStop();
}

- (size_t)setProperty:(NSString *)property {
  if (!property) {
    return ByteDanceErrorCodeErrorParameter;
  }
  
  const char *value = [property UTF8String];
  return _bdVideoFilter->setProperty(value);
}

@end

@interface BDVideoFilterProvider() <BDVideoFilterProviderDelegate> {
  std::shared_ptr<ByteDance::Extension::BDVideoFilter> _bdVideoFilter;
  EAGLContext* _context;
}

@property (strong, nonatomic) BDVideoFilter *objcVideoFilter;

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

- (instancetype)init {
  if (self = [super init]) {
    std::shared_ptr<ByteDance::Extension::BDProcessor> processor = std::make_shared<ByteDance::Extension::BDProcessor>();
    _bdVideoFilter = std::make_shared<ByteDance::Extension::BDVideoFilter>(processor);
    if (!_bdVideoFilter) {
      return nil;
    }
    _objcVideoFilter = [[BDVideoFilter alloc] initWithVideoFilter:_bdVideoFilter];
  }
  return self;
}

- (void)dealloc {
  _bdVideoFilter.reset();
}

- (NSString * _Nonnull)uniqueName {
  return @"ByteDanceVideoFilterProvider";
}

- (NSString * _Nonnull)vendor {
  return @"ByteDance";
}

- (NSString * _Nonnull)version {
  return @"v3.9.2.1";
}

- (id<BDVideoFilterDelegate> _Nonnull)videoFilterProvider {
  return _objcVideoFilter;
}

- (void)onDataReceive:(NSString *_Nullable)data {
  [self.dataReceiveDelegate onDataReceive:data];
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
  EAGLContext * prev = [EAGLContext currentContext];
  if (prev != _context) {
    [EAGLContext setCurrentContext:_context];
  }
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

extern "C" void dataCallback(const char * data) {
  if (!data) { return; }
  NSString *str = [NSString stringWithCString:data encoding:[NSString defaultCStringEncoding]];
  dispatch_async(dispatch_get_main_queue(), ^{
    [[BDVideoFilterProvider sharedInstance] onDataReceive:str];
  });
}

@end
