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
BDVideoFilter::BDVideoFilter(std::shared_ptr<BDProcessor> bdProcessor) {
  bdProcessor_ = bdProcessor;
}

BDVideoFilter::~BDVideoFilter() {
  bdProcessor_->releaseOpenGL();
}

void BDVideoFilter::setEnabled(bool enable) {}

bool BDVideoFilter::adaptVideoFrame(const BDVideoFrame& capturedFrame,
                                    BDVideoFrame& adaptedFrame) {
  bdProcessor_->processFrame(capturedFrame);
  adaptedFrame = capturedFrame;
  return true;
}

size_t BDVideoFilter::setProperty(const char *property) {
  if (!property) {
    return ByteDanceErrorCodeErrorParameter;
  }
  std::string parameter(property);
  bdProcessor_->setParameters(parameter);
  return 0;
}

bool BDVideoFilter::onDataStreamWillStart() {
  bdProcessor_->initOpenGL();
  return true;
}

void BDVideoFilter::onDataStreamWillStop() {
  bdProcessor_->releaseOpenGL();
}

}
}
