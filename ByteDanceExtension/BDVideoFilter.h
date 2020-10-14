//
//  BDVideoFilter.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#include "AgoraRtcKit2/AgoraMediaBase.h"
#include "AgoraRtcKit2/NGIAgoraExtensionVideoFilter.h"
#include <memory>
#include "BDProcessor.h"

namespace ByteDance {
namespace Extension {
class BDVideoFilter: public agora::rtc::IExtensionVideoFilter {
public:
  BDVideoFilter(std::shared_ptr<BDProcessor> bdProcessor);
  ~BDVideoFilter();
  
  bool setProperty(const char* key, const char* json_value) override;
  unsigned int property(const char* key,
                        char* json_value_buffer,
                        unsigned int json_value_buffer_size) const override;
  bool setExtensionFacility(agora::rtc::IExtensionFacility* facility) override;
  bool filter(const agora::media::base::VideoFrame& original_frame,
              agora::media::base::VideoFrame& processed_frame) override;
  void sendEvent(const char* key, const char* json_value);
  void log(agora::commons::LOG_LEVEL level, const char* message);
protected:
  BDVideoFilter() = default;
private:
  std::shared_ptr<BDProcessor> bdProcessor_;
  agora::rtc::IExtensionFacility* facility_;
};

}
}
