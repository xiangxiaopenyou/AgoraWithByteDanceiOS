//
//  BDVideoFrame.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#pragma once

#include "BDVideoFilterProviderDelegate.h"

namespace ByteDance {
namespace Extension {
/**
 * Video pixel formats.
 */
enum VIDEO_PIXEL_FORMAT {
  /**
   * 0: Unknown format.
   */
  VIDEO_PIXEL_UNKNOWN = 0,
  /**
   * 1: I420.
   */
  VIDEO_PIXEL_I420 = 1,
  /**
   * 2: BGRA.
   */
  VIDEO_PIXEL_BGRA = 2,
  /**
   * 3: NV21.
   */
  VIDEO_PIXEL_NV21 = 3,
  /**
   * 4: RGBA.
   */
  VIDEO_PIXEL_RGBA = 4,
  /**
   * 8: NV12.
   */
  VIDEO_PIXEL_NV12 = 8,
  /**
   * 10: GL_TEXTURE_2D
   */
  VIDEO_TEXTURE_2D = 10,
  /**
   * 11: GL_TEXTURE_OES
   */
  VIDEO_TEXTURE_OES = 11,
  /**
   * 16: I422.
   */
  VIDEO_PIXEL_I422 = 16,
};

/**
 * The definition of the VideoFrame struct.
 */
struct BDVideoFrame {
  BDVideoFrame(): type(ByteDance::Extension::VIDEO_PIXEL_I420),
  height(0), yStride(0), uStride(0), vStride(0), yBuffer(nullptr),
  uBuffer(nullptr), vBuffer(nullptr), rotation(0), renderTimeMs(0), avsync_type(0) {}
  
  BDVideoFrame(id<BDVideoFrameDataSource> dataSource);
  
  /**
   * The video pixel format: #VIDEO_PIXEL_FORMAT.
   */
  VIDEO_PIXEL_FORMAT type;
  /**
   * The width of the Video frame.
   */
  int width;
  /**
   * The height of the video frame.
   */
  int height;
  /**
   * The line span of Y buffer in the YUV data.
   */
  int yStride;
  /**
   * The line span of U buffer in the YUV data.
   */
  int uStride;
  /**
   * The line span of V buffer in the YUV data.
   */
  int vStride;
  /**
   * The pointer to the Y buffer in the YUV data.
   */
  uint8_t* yBuffer;
  /**
   * The pointer to the U buffer in the YUV data.
   */
  uint8_t* uBuffer;
  /**
   * The pointer to the V buffer in the YUV data.
   */
  uint8_t* vBuffer;
  /**
   * The clockwise rotation information of this frame. You can set it as 0, 90, 180 or 270.
   */
  int rotation;
  /**
   * The timestamp to render the video stream. Use this parameter for audio-video synchronization when
   * rendering the video.
   *
   * @note This parameter is for rendering the video, not capturing the video.
   */
  int64_t renderTimeMs;
  /**
   * The type of audio-video synchronization.
   */
  int avsync_type;
};
}
}
