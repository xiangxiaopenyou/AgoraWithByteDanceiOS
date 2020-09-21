//
//  BDVideoFrame.mm
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#include "BDVideoFrame.h"

namespace ByteDance {
namespace Extension {

BDVideoFrame::BDVideoFrame(id<BDVideoFrameDataSource> dataSource) {
  if (dataSource != nil) {
    type = static_cast<VIDEO_PIXEL_FORMAT>(dataSource.format);
    width = dataSource.width;
    height = dataSource.height;
    yStride = dataSource.yStride;
    uStride = dataSource.uStride;
    vStride = dataSource.vStride;
    yBuffer = dataSource.yBuffer;
    uBuffer = dataSource.uBuffer;
    vBuffer = dataSource.vBuffer;
    rotation = dataSource.rotation;
    renderTimeMs = dataSource.renderTimeMs;
    avsync_type = dataSource.avsync_type;
  }
}

}
}
