//
//  AgoraVideoFilterDelegate.h
//  Agora SDK
//
//  Created by LLF on 2021-3-9.
//  Copyright (c) 2021 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraExtObjects.h"

/**
 * The AgoraVideoFilterDelegate protocol.
 *
 * This protocol is the intermediate node for video, which contains both the video source and the video
 * sink. It reads video frames from the underlying video pipeline and writes video frames back after
 * adaptation.
 */
@protocol AgoraVideoFilterDelegate <NSObject>

/**
 * VideoFilter's Video Data Format Use CVPixelBuffer or Not
 * @return
 * - `YES`: Use CVPixelBuffer.
 * - `NO`: Not Use CVPixelBuffer.
 */
- (BOOL)isUseCVPixelBuffer;
/**
 * Adapts the video frame.
 *
 * @param srcFrame The pointer to the captured video frame that you want to adapt.
 * @param dstFrame The in/out pointer to the adapted video frame.
 *
 * @return
 * - `YES`: Success.
 * - `NO`: Failure, if, for example, the `IVideofilter` object drops the video frame.
 */
- (BOOL)adaptVideoFrame:(AgoraExtVideoFrame * __nonnull)srcFrame
               dstFrame:(AgoraExtVideoFrame *_Nullable* _Nullable)dstFrame;

/**
 * Enables or disables the video filter.
 * @param enable Whether to enable the video filter:
 * - `YES`: (Default) Enable the video filter.
 * - `NO`: Do not enable the video filter. If the filter is disabled, frames will be passed without
 * adaption.
 */
- (void)setEnabled:(BOOL)enabled;

/**
 * Checks whether the video filter is enabled.
 * @return
 * - `YES`: The video filter is enabled.
 * - `NO`: The video filter is not enabled.
 */
- (BOOL)isEnabled;

/**
 * Sets a private property in the `IVideoFilter` class.
 *
 * @param key The pointer to the property name.
 * @param value The pointer to the buffer of this private property.
 * @return
 * - The actual size of the private property, if the method call succeeds.
 * - -1, if the method call fails.
 */
- (NSInteger)setPropertyWithKey:(NSString * __nonnull)key value:(NSData * __nonnull)value;

/**
 * Gets a private property in the IVideoFilter class.
 *
 * @param key The pointer to the property name.
 * @param(in/out) value The pointer to the buffer of this private property.
 * @return
 * - The actual size of the private property, if the method call succeeds.
 * - -1, if the method call fails.
 */
- (NSInteger)getPropertyWithKey:(NSString * __nonnull)key value:(NSData *_Nullable* _Nullable)value;

@optional
/**
 * This function is invoked right before data stream starts.
 * Custom filter can override this function for initialization.
 * @return
 * - `YES`: The initialization succeeds.
 * - `NO`: The initialization fails.
 */
- (BOOL)didDataStreamWillStart;
 /**
 * This function is invoked right before data stream stops.
 * Custom filter can override this function for deinitialization.
 */
- (void)didDataStreamWillStop;

@end
