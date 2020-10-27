//
//  BDVideoFilterProvider.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/10/21.
//

#pragma once

#include "AgoraRtcKit2/AgoraMediaBase.h"
#include "AgoraRtcKit2/NGIAgoraExtensionControl.h"
#include "AgoraRtcKit2/AgoraRefCountedObject.h"
#include "AgoraRtcKit2/NGIAgoraExtensionProvider.h"

namespace ByteDance {
namespace Extension {
class BDProcessor;

class BDExtensionProvider : public agora::rtc::IExtensionProvider {
public:
  BDExtensionProvider(agora::agora_refptr<BDProcessor> processor);
  ~BDExtensionProvider();
  
  void setExtensionControl(agora::rtc::IExtensionControl* control) override;
  agora::rtc::IExtensionProvider::PROVIDER_TYPE getProviderType() override;
  agora::agora_refptr<agora::rtc::IAudioFilter> createAudioFilter(const char* id) override;
  agora::agora_refptr<agora::rtc::IVideoFilter> createVideoFilter(const char* id) override;
  agora::agora_refptr<agora::rtc::IVideoSinkBase> createVideoSink(const char* id) override;
  int log(agora::commons::LOG_LEVEL level, const char* message);
  int fireEvent(const char *vendor, const char* event_json_str);
protected:
  BDExtensionProvider() = default;
private:
  agora::agora_refptr<agora::rtc::IVideoFilter> video_filter_;
  agora::agora_refptr<BDProcessor> processor_;
  agora::rtc::IExtensionControl* extension_control_;
};

}
}
