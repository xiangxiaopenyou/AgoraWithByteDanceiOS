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
  bool setEventDelegate(agora::rtc::IExtensionVideoFilterEventDelegate* delegate) override;
  bool filter(const agora::media::base::VideoFrame& original_frame,
              agora::media::base::VideoFrame& processed_frame) override;

protected:
  BDVideoFilter() = default;
private:
  std::shared_ptr<BDProcessor> bdProcessor_;
};

}
}
