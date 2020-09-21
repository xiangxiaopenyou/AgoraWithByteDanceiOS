//
//  BDVideoFilter.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#include "BDVideoFilterProviderDelegate.h"
#include <memory>
#include "BDVideoFrame.h"
#include "BDProcessor.h"

namespace ByteDance {
namespace Extension {
class BDVideoFilter {
public:
  BDVideoFilter(std::shared_ptr<BDProcessor> bdProcessor);
  ~BDVideoFilter();
  
  bool adaptVideoFrame(const BDVideoFrame &capturedFrame,
                       BDVideoFrame &adaptedFrame);
  void setEnabled(bool enable);
  
  size_t setProperty(const char* property);
  bool onDataStreamWillStart();
  void onDataStreamWillStop();
private:
  std::shared_ptr<BDProcessor> bdProcessor_;
protected:
  BDVideoFilter() = default;
};

}
}
