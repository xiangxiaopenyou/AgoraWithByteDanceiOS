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

agora::rtc::IExtensionProvider::PROVIDER_TYPE BDExtensionProvider::getProviderType() {
  return agora::rtc::IExtensionProvider::PROVIDER_TYPE::LOCAL_VIDEO_FILTER;
}

agora::agora_refptr<agora::rtc::IAudioFilter> BDExtensionProvider::createAudioFilter(const char* filter_id, agora::rtc::IExtensionControl* ctrl) {
  return nullptr;
}

agora::agora_refptr<agora::rtc::IVideoFilter> BDExtensionProvider::createVideoFilter(const char* filter_id, agora::rtc::IExtensionControl* ctrl) {
  extension_control_ = ctrl;
  if (filter_id) {
    filter_id_ = const_cast<char *>(filter_id);
  }
  
  if (processor_) {
    auto videoFilter = new agora::RefCountedObject<ByteDance::Extension::BDVideoFilter>(processor_);
    return videoFilter;
  }
  
  return nullptr;
}

agora::agora_refptr<agora::rtc::IVideoSinkBase> BDExtensionProvider::createVideoSink(const char* filter_id, agora::rtc::IExtensionControl* ctrl) {
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
    return extension_control_->fireEvent(vendor, filter_id_, event_json_str, event_json_str);
  }
  return -1;
}

}
}
