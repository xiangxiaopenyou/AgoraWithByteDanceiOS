//
//  BDProcessor.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//
#pragma once

#include <thread>
#include <string>
#include <mutex>
#include <vector>
#import <AgoraRtcKit/AgoraExtObjects.h>
#include "bef_effect_ai_api.h"
#include "bef_effect_ai_lightcls.h"
#include "rapidjson.h"

namespace ByteDance {
namespace Extension {
class BDProcessor {
public:
  BDProcessor();
  bool initOpenGL();
  bool releaseOpenGL();
  int processFrame(AgoraExtVideoFrame* capturedFrame);
  int releaseEffectEngine();
  int setParameters(std::string parameter);
  void onDataCallback(std::string data);
  std::thread::id getThreadId();
  
private:
  void processFaceDetect();
  void processHandDetect();
  void processLightDetect();
  void processEffect(AgoraExtVideoFrame* capturedFrame);
  void prepareCachedVideoFrame(AgoraExtVideoFrame* capturedFrame);
  std::mutex mutex_;
  
  bef_effect_handle_t byteEffectHandler_ = nullptr;
  std::string licensePath_;
  std::string modelDir_;
  bool aiEffectEnabled_ = false;
  char** aiNodes_ = nullptr;
  rapidjson::SizeType aiNodeCount_ = 0;
  std::vector<float> aiNodeIntensities_;
  std::vector<std::string> aiNodeKeys_;
  bool aiEffectNeedUpdate_ = false;
  
  bool faceAttributeEnabled_ = false;
  std::string faceDetectModelPath_;
  std::string faceAttributeModelPath_;
  bef_effect_handle_t faceDetectHandler_ = nullptr;
  bef_effect_handle_t faceAttributesHandler_ = nullptr;
  
  bool handDetectEnabled_ = false;
  std::string handDetectModelPath_;
  std::string handBoxModelPath_;
  std::string handGestureModelPath_;
  std::string handKPModelPath_;
  bef_effect_handle_t handDetectHandler_ = nullptr;
  
  bool lightDetectEnabled_ = false;
  std::string lightDetectModelPath_;
  bef_effect_handle_t lightDetectHandler_ = nullptr;
  
  AgoraExtVideoFrame* prevFrame_ = nil;
  unsigned char* yuvBuffer_ = nullptr;
  unsigned char* rgbaBuffer_ = nullptr;
  
  bool faceStickerEnabled_ = false;
  std::string faceStickerItemPath_;
};
}
}
