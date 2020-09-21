//
//  BDDataProviderDelegate.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#ifndef BDDataProviderDelegate_h
#define BDDataProviderDelegate_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, ByteDanceErrorCode) {
  BYTEDANCE_ERROR_OK = 0,
  BYTEDANCE_ERROR_NOT_INIT_RTC_ENGINE = 1,
  BYTEDANCE_ERROR_NOT_INIT_VIDEO_FILTER = 2,
  BYTEDANCE_ERR_NOT_INIT_PLUGIN_MANAGER = 3,
  BYTEDANCE_ERROR_ERR_PARAMETER = 10,
  BYTEDANCE_ERROR_INVALID_JSON = 100,
  BYTEDANCE_ERROR_INVALID_JSON_TYPE = 101,
};

@protocol BDVideoFrameDataSource <NSObject>

@property (assign, nonatomic) int format;
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;
@property (assign, nonatomic) int yStride;
@property (assign, nonatomic) int uStride;
@property (assign, nonatomic) int vStride;
@property (assign, nonatomic) uint8_t* _Nullable yBuffer;
@property (assign, nonatomic) uint8_t* _Nullable uBuffer;
@property (assign, nonatomic) uint8_t* _Nullable vBuffer;
@property (assign, nonatomic) int rotation;
@property (assign, nonatomic) int64_t renderTimeMs;
@property (assign, nonatomic) int avsync_type;

@end

@protocol BDDataReceiverDelegate <NSObject>
- (void)onDataReceive:(NSString *_Nullable)data;
@end

@protocol BDVideoFilterDelegate<NSObject>
- (NSInteger)adaptVideoFrame:(id<BDVideoFrameDataSource> _Nullable)inFrame outFrame:(id<BDVideoFrameDataSource> _Nullable)outFrame;
- (NSInteger)enable:(BOOL)enabled withName:(NSString * _Nonnull)name;
- (NSInteger)setProperty:(NSString * _Nonnull)key withValue:(NSString * _Nonnull)value withName:(NSString * _Nonnull)name;
- (BOOL)onDataStreamWillStart;
- (void)onDataStreamWillStop;
- (NSInteger)setDataReceiverDelegate:(id<BDDataReceiverDelegate> _Nullable)delegate withName:(NSString * _Nonnull)name;
@end

@protocol BDVideoFilterProviderDelegate<NSObject>
- (NSString * _Nonnull)uniqueName;
- (NSString * _Nonnull)version;
- (NSString * _Nonnull)vendor;
- (id<BDVideoFilterDelegate> _Nonnull)videoFilterProvider;
@end

#endif /* BDDataProviderDelegate_h */
