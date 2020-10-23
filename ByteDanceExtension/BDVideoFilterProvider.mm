//
//  BDVideoFilterProvider.m
//  ByteDanceExtension
//
//  Created by LLF on 2020/10/21.
//

#import "BDVideoFilterProvider.h"
#include "BDVideoFilter.h"

namespace ByteDance {
namespace Extension {
BDExtensionProvider::BDExtensionProvider(agora::agora_refptr<BDProcessor> processor): processor_(processor) {}
BDExtensionProvider::~BDExtensionProvider() {}

void BDExtensionProvider::setExtensionControl(agora::rtc::IExtensionControl* control) {
  extension_control_ = control;
}

agora::rtc::IExtensionProvider::PROVIDER_TYPE BDExtensionProvider::getProviderType() {
  return agora::rtc::IExtensionProvider::PROVIDER_TYPE::LOCAL_VIDEO_FILTER;
}

agora::agora_refptr<agora::rtc::IAudioFilter> BDExtensionProvider::createAudioFilter(const char* id) {
  return nullptr;
}

agora::agora_refptr<agora::rtc::IVideoFilter> BDExtensionProvider::createVideoFilter(const char* id) {
  if (processor_) {
    auto videoFilter = new agora::RefCountedObject<ByteDance::Extension::BDVideoFilter>(processor_);
    return videoFilter;
  }
  
  return nullptr;
}

agora::agora_refptr<agora::rtc::IVideoSinkBase> BDExtensionProvider::createVideoSink(const char* id) {
  return nullptr;
}

int BDExtensionProvider::log(agora::commons::LOG_LEVEL level, const char* message) {
  if (extension_control_) {
    return extension_control_->log(level, message);
  }
  return -1;
}

int BDExtensionProvider::fireEvent(const char *vendor, const char* event_json_str) {
  if (extension_control_) {
    return extension_control_->fireEvent(vendor, event_json_str, event_json_str);
  }
  return -1;
}

}
}
