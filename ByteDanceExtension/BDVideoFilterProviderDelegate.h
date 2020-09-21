//
//  BDVideoFilterProviderDelegate.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#ifndef BDDataProviderDelegate_h
#define BDDataProviderDelegate_h

#import <Foundation/Foundation.h>

NSString* _Nonnull bd_VideoFilterProviderClassName();

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
- (int)adaptVideoFrame:(id<BDVideoFrameDataSource> _Nullable)inFrame outFrame:(id<BDVideoFrameDataSource> _Nullable)outFrame;
- (void)setEnable:(BOOL)enabled;
- (size_t)setProperty:(NSString * _Nullable)property;
- (bool)onDataStreamWillStart;
- (void)onDataStreamWillStop;
@end

@protocol BDVideoFilterProviderDelegate<NSObject>
- (NSString * _Nonnull)uniqueName;
- (NSString * _Nonnull)version;
- (NSString * _Nonnull)vendor;
- (id<BDVideoFilterDelegate> _Nonnull)videoFilterProvider;
@property (nonatomic, weak) id<BDDataReceiverDelegate> _Nullable dataReceiveDelegate;

@end

#endif /* BDDataProviderDelegate_h */
