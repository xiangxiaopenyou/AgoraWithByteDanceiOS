//
//  BDVideoFilter.mm
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#include "BDVideoFilter.h"
#import "BDErrorCode.h"

namespace ByteDance {
namespace Extension {
BDVideoFilter::BDVideoFilter(agora::agora_refptr<BDProcessor> bdProcessor): bdProcessor_(bdProcessor) {}

BDVideoFilter::~BDVideoFilter() {
  if (bdProcessor_ && !opengl_released_) {
    bdProcessor_->releaseOpenGL();
  }
}

size_t BDVideoFilter::setProperty(const char* key, const void* buf, size_t buf_size) {
  if (!buf) {
    return -1;
  }
  
  if (bdProcessor_) {
    const char *json_value = static_cast<const char *>(buf);
    std::string parameter(json_value);
    return bdProcessor_->setParameters(parameter);
  }
  
  return -1;
}

bool BDVideoFilter::onDataStreamWillStart() {
  if (bdProcessor_) {
    bdProcessor_->initOpenGL();
    return true;
  }
  return false;
}

void BDVideoFilter::onDataStreamWillStop() {
  if (bdProcessor_) {
    bdProcessor_->releaseOpenGL();
    opengl_released_ = true;
  }
}

bool BDVideoFilter::adaptVideoFrame(const agora::media::base::VideoFrame& capturedFrame,
                                    agora::media::base::VideoFrame& adaptedFrame) {
  if (bdProcessor_) {
    bdProcessor_->processFrame(capturedFrame);
    adaptedFrame = capturedFrame;
    return true;
  }
  return false;
}

}
}
