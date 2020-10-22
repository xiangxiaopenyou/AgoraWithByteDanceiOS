//
//  BDVideoFilter.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#pragma once

#include "AgoraRtcKit2/AgoraMediaBase.h"
#include "AgoraRtcKit2/NGIAgoraMediaNode.h"
#include "AgoraRtcKit2/AgoraRefPtr.h"
#include "BDProcessor.h"

namespace ByteDance {
namespace Extension {
class BDVideoFilter: public agora::rtc::IVideoFilter {
public:
  BDVideoFilter(agora::agora_refptr<BDProcessor> bdProcessor);
  ~BDVideoFilter();
  
  virtual size_t setProperty(const char* key, const void* buf, size_t buf_size) override;
  virtual bool onDataStreamWillStart() override;
  virtual void onDataStreamWillStop() override;
  
  virtual bool adaptVideoFrame(const agora::media::base::VideoFrame& capturedFrame,
                               agora::media::base::VideoFrame& adaptedFrame) override;
  
protected:
  BDVideoFilter() = default;
private:
  agora::agora_refptr<BDProcessor> bdProcessor_;
  bool opengl_released_ = false;
};

}
}
