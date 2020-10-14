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
  bdProcessor_->initOpenGL();
}

BDVideoFilter::~BDVideoFilter() {
  if (bdProcessor_) {
    bdProcessor_->releaseOpenGL();
  }
}

bool BDVideoFilter::setProperty(const char* key, const char* json_value) {
  if (!json_value) {
    return false;
  }
  
  if (bdProcessor_) {
    std::string parameter(json_value);
    bdProcessor_->setParameters(parameter);
    return true;
  }
  
  return false;
}

unsigned int BDVideoFilter::property(const char* key,
                                     char* json_value_buffer,
                                     unsigned int json_value_buffer_size) const {
  return 0;
}

bool BDVideoFilter::setExtensionFacility(agora::rtc::IExtensionFacility* facility) {
  facility_ = facility;
  return true;
}

void BDVideoFilter::sendEvent(const char* key, const char* json_value) {
  if (facility_) {
    facility_->fireEvent(key, json_value);
  }
}

void BDVideoFilter::log(agora::commons::LOG_LEVEL level, const char* message) {
  if (facility_) {
    facility_->log(level, message);
  }
}

bool BDVideoFilter::filter(const agora::media::base::VideoFrame& original_frame,
            agora::media::base::VideoFrame& processed_frame) {
  if (bdProcessor_) {
    bdProcessor_->processFrame(original_frame);
    processed_frame = original_frame;
    return true;
  }
  
  return false;
}

}
}
