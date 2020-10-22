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

namespace ByteDance {
namespace Extension {
class BDProcessor;

class BDExtensionProvider : public agora::rtc::IExtensionProvider {
public:
  BDExtensionProvider(agora::agora_refptr<BDProcessor> processor);
  ~BDExtensionProvider();
  
  virtual agora::rtc::IExtensionProvider::PROVIDER_TYPE getProviderType() override;
  virtual agora::agora_refptr<agora::rtc::IAudioFilter> createAudioFilter(const char* filter_id, agora::rtc::IExtensionControl* ctrl) override;
  virtual agora::agora_refptr<agora::rtc::IVideoFilter> createVideoFilter(const char* filter_id, agora::rtc::IExtensionControl* ctrl) override;
  virtual agora::agora_refptr<agora::rtc::IVideoSinkBase> createVideoSink(const char* filter_id, agora::rtc::IExtensionControl* ctrl) override;
  int log(agora::commons::LOG_LEVEL level, const char* message);
  int fireEvent(const char *vendor, const char* event_json_str);
protected:
  BDExtensionProvider() = default;
private:
  agora::agora_refptr<agora::rtc::IVideoFilter> video_filter_;
  agora::agora_refptr<BDProcessor> processor_;
  agora::rtc::IExtensionControl* extension_control_;
  char* filter_id_;
};

}
}
