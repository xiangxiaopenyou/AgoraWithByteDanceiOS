//
//  AgoraExtObjects.h
//  Agora SDK
//
//  Created by LLF on 21-3-9.
//  Copyright (c) 2021 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

/**
 * Bytes per sample
 */
typedef NS_ENUM(NSInteger, BytesPerSampleType) {
  /**
   * two bytes per sample
   */
  TwoBytesPerSample = 2,
};

/**
 * The class of AgoraAudioPcmFrame.
 */
__attribute__((visibility("default"))) @interface AgoraAudioPcmFrame: NSObject
 @property (assign, nonatomic) uint32_t captureTimestamp;
 @property (assign, nonatomic) size_t samplesPerChannel;
 @property (assign, nonatomic) int sampleRateHz;
 @property (assign, nonatomic) size_t channelNumbers;
@property (strong, nonatomic) NSData* __nonnull pcmBuffer;
 @property (assign, nonatomic) BytesPerSampleType bytesPerSample;
@end

/** The class of AgoraExtVideoFrame.
 */
__attribute__((visibility("default"))) @interface AgoraExtVideoFrame : NSObject
/** Video format:
 * - 1: I420
 * - 2: BGRA
 * - 3: NV21
 * - 4: RGBA
 * - 5: IMC2
 * - 7: ARGB
 * - 8: NV12
 * - 12: iOS texture (CVPixelBufferRef)
 */
@property (nonatomic, assign) NSInteger type;

/**
 * use CVPixelBuffer or yuv raw data, Default value is YES, if use raw data,
 * should set isUseCVPixelBuffer to NO
 */
@property (nonatomic, assign) BOOL isUseCVPixelBuffer;

/**
 * The width of the Video frame.
 */
@property (nonatomic, assign) int width;
/**
 * The height of the video frame.
 */
@property (nonatomic, assign) int height;
/**
 * The line span of Y buffer in the YUV data.
 */
@property (nonatomic, assign) int yStride;
/**
 * The line span of U buffer in the YUV data.
 */
@property (nonatomic, assign) int uStride;
/**
 * The line span of V buffer in the YUV data.
 */
@property (nonatomic, assign) int vStride;
/**
 * The pointer to the Y buffer in the YUV data.
 */
@property (nonatomic, assign) uint8_t* _Nullable yBuffer;
/**
 * The pointer to the U buffer in the YUV data.
 */
@property (nonatomic, assign) uint8_t* _Nullable uBuffer;
/**
 * The pointer to the V buffer in the YUV data.
 */
@property (nonatomic, assign) uint8_t* _Nullable vBuffer;
/**
 * The clockwise rotation information of this frame. You can set it as 0, 90, 180 or 270.
 */
@property (nonatomic, assign) int rotation;
/**
 * The timestamp to render the video stream. Use this parameter for audio-video synchronization when
 * rendering the video.
 *
 * @note This parameter is for rendering the video, not capturing the video.
 */
@property (nonatomic, assign) int64_t renderTimeMs;
/**
 * The type of audio-video synchronization.
 */
@property (nonatomic, assign) int avSyncType;

/** CVPixelBuffer
 */
@property(assign, nonatomic) CVPixelBufferRef _Nullable pixelBuffer;
@end
