//
//  BDProcessor.mm
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#include "BDProcessor.h"
#include <chrono>
#include "bef_effect_ai_yuv_process.h"
#include "document.h"
#include "writer.h"
#include "stringbuffer.h"
#include "prettywriter.h"
#import "BDErrorCode.h"
#import <Foundation/Foundation.h>

extern "C" void initGL();
extern "C" void releaseGL();
extern "C" void makeCurrent();
extern "C" void dataCallback(NSString* data);
extern "C" void logMessage(int retval, NSString* message);

namespace ByteDance {
namespace Extension {
using namespace rapidjson;
static NSString *log = nil;

BDProcessor::BDProcessor(): prevFrame_([AgoraExtVideoFrame new]) {}

bool BDProcessor::initOpenGL() {
  const std::lock_guard<std::mutex> lock(mutex_);
  initGL();
  return true;
}

bool BDProcessor::releaseOpenGL() {
  const std::lock_guard<std::mutex> lock(mutex_);
  releaseGL();
  return true;
}

void BDProcessor::prepareCachedVideoFrame(AgoraExtVideoFrame* capturedFrame) {
  int ysize = capturedFrame.yStride * capturedFrame.height;
  int usize = capturedFrame.uStride * capturedFrame.height / 2;
  int vsize = capturedFrame.vStride * capturedFrame.height / 2;
  if (yuvBuffer_ == nullptr ||
      rgbaBuffer_ == nullptr ||
      prevFrame_.width != capturedFrame.width ||
      prevFrame_.height != capturedFrame.height ||
      prevFrame_.yStride != capturedFrame.yStride ||
      prevFrame_.uStride != capturedFrame.uStride ||
      prevFrame_.vStride != capturedFrame.vStride) {
    if (yuvBuffer_) {
      free(yuvBuffer_);
      yuvBuffer_ = nullptr;
    }
    if (rgbaBuffer_) {
      free(rgbaBuffer_);
      rgbaBuffer_ = nullptr;
    }
    
    yuvBuffer_ = (unsigned char*)malloc(ysize + usize + vsize);
    rgbaBuffer_ = (unsigned char*)malloc(capturedFrame.yStride * capturedFrame.height * 4);
  }
  // update YUV buffer
  memcpy(yuvBuffer_, capturedFrame.yBuffer, ysize);
  memcpy(yuvBuffer_ + ysize, capturedFrame.uBuffer, usize);
  memcpy(yuvBuffer_ + ysize + usize, capturedFrame.vBuffer, vsize);
  
  // update RGBA buffer
  cvt_yuv2rgba(yuvBuffer_, rgbaBuffer_, BEF_AI_PIX_FMT_YUV420P, capturedFrame.width,
               capturedFrame.height, capturedFrame.width, capturedFrame.height,
               BEF_AI_CLOCKWISE_ROTATE_0,
               false);
  prevFrame_ = capturedFrame;
}

void BDProcessor::processEffect(AgoraExtVideoFrame* capturedFrame) {
  makeCurrent();
  if (!byteEffectHandler_) {
    bef_effect_result_t ret;
    ret = bef_effect_ai_create(&byteEffectHandler_);
    
    log = [NSString stringWithFormat:@"BDProcessor::processEffect create effect handle failed ! %d", ret];
    logMessage(ret, log);
    
    ret = bef_effect_ai_check_license(byteEffectHandler_, licensePath_.c_str());
    
    log = [NSString stringWithFormat:@"BDProcessor::processEffect check license failed, %d path: %s",  ret, licensePath_.c_str()];
    logMessage(ret, log);
    
    ret = bef_effect_ai_init(byteEffectHandler_, 0, 0, modelDir_.c_str(), "");
    
    log = [NSString stringWithFormat:@"BDProcessor::processEffect init effect handler failed, %d model path: %s", ret, modelDir_.c_str()];
    logMessage(ret, log);
    ret = bef_effect_ai_composer_set_mode(byteEffectHandler_, 1, 0);
    
    log = [NSString stringWithFormat:@"BDProcessor::processEffect set composer mode failed %d", ret];
    logMessage(ret, log);
  }
  
  if (aiEffectNeedUpdate_) {
    bef_effect_result_t ret;
    if (aiNodeCount_ <= 0) {
      const char *nodes[] = {};
      ret = bef_effect_ai_composer_set_nodes(byteEffectHandler_,
                                             nodes, 0);
      log = [NSString stringWithFormat:@"BDProcessor::processEffect composer set nodes to empty failed ! %d", ret];
      logMessage(ret, log);
    } else {
      ret = bef_effect_ai_composer_set_nodes(byteEffectHandler_,
                                             (const char **) aiNodes_, aiNodeCount_);
      log = [NSString stringWithFormat:@"BDProcessor::processEffect composer set nodes failed ! %d", ret];
      logMessage(ret, log);
      for (SizeType i = 0; i < aiNodeCount_; i++) {
        ret = bef_effect_ai_composer_update_node(byteEffectHandler_, aiNodes_[i],
                                                 aiNodeKeys_[i].c_str(),
                                                 aiNodeIntensities_[i]);
        log = [NSString stringWithFormat:@"BDProcessor::processEffect update composer failed %d %s %s %f", ret, aiNodeKeys_[i].c_str(), aiNodes_[i], aiNodeIntensities_[i]];
        logMessage(ret, log);
      }
    }
    aiEffectNeedUpdate_ = false;
  }
  
  uint64_t timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
  bef_effect_ai_set_width_height(byteEffectHandler_, capturedFrame.width,
                                 capturedFrame.height);
  
  bef_effect_result_t ret;
  if (faceStickerEnabled_) {
    ret = bef_effect_ai_set_effect(byteEffectHandler_, faceStickerItemPath_.c_str());
    log = [NSString stringWithFormat:@"BDProcessor::updateEffect set sticker effect failed %d", ret];
    logMessage(ret, log);
  } else {
    ret = bef_effect_ai_set_effect(byteEffectHandler_, "");
    log = [NSString stringWithFormat:@"BDProcessor::updateEffect clear sticker effect failed %d",
                    ret];
    logMessage(ret, log);
  }
  
  ret = bef_effect_ai_algorithm_buffer(byteEffectHandler_, rgbaBuffer_,
                                       BEF_AI_PIX_FMT_RGBA8888, capturedFrame.width,
                                       capturedFrame.height, capturedFrame.yStride * 4,
                                       timestamp);
  log = [NSString stringWithFormat:@"BDProcessor::updateEffect ai algorithm buffer failed %d", ret];
  logMessage(ret, log);
  ret = bef_effect_ai_process_buffer(byteEffectHandler_, rgbaBuffer_,
                                     BEF_AI_PIX_FMT_RGBA8888, capturedFrame.yStride,
                                     capturedFrame.height, capturedFrame.yStride * 4,
                                     rgbaBuffer_, BEF_AI_PIX_FMT_RGBA8888, timestamp);
  log = [NSString stringWithFormat:@"BDProcessor::updateEffect ai process buffer failed %d", ret];
  logMessage(ret, log);
  
  cvt_rgba2yuv(rgbaBuffer_, yuvBuffer_, BEF_AI_PIX_FMT_YUV420P, capturedFrame.yStride,
               capturedFrame.height);
  
  int ysize = capturedFrame.yStride * capturedFrame.height;
  int usize = capturedFrame.uStride * capturedFrame.height / 2;
  int vsize = capturedFrame.vStride * capturedFrame.height / 2;
  memcpy(capturedFrame.yBuffer, yuvBuffer_, ysize);
  memcpy(capturedFrame.uBuffer, yuvBuffer_ + ysize, usize);
  memcpy(capturedFrame.vBuffer, yuvBuffer_ + ysize + usize, vsize);
}

void BDProcessor::processFaceDetect() {
  if (!faceDetectHandler_) {
    bef_effect_result_t ret;
    ret = bef_effect_ai_face_detect_create(
                                           BEF_DETECT_SMALL_MODEL | BEF_DETECT_FULL | BEF_DETECT_MODE_VIDEO,
                                           faceDetectModelPath_.c_str(), &faceDetectHandler_);
    log = [NSString stringWithFormat:@"BDProcessor::processFaceDetect create face detect handle failed ! %d", ret];
    logMessage(ret, log);
    ret = bef_effect_ai_face_check_license(faceDetectHandler_, licensePath_.c_str());
    log = [NSString stringWithFormat:@"BDProcessor::processFaceDetect check_license face detect failed ! %d", ret];
    logMessage(ret, log);
    
    ret = bef_effect_ai_face_detect_setparam(faceDetectHandler_,
                                             BEF_FACE_PARAM_FACE_DETECT_INTERVAL, 15);
    
    ret = bef_effect_ai_face_detect_setparam(faceDetectHandler_,
                                             BEF_FACE_PARAM_MAX_FACE_NUM,
                                             BEF_MAX_FACE_NUM);
  }
  if (!faceAttributesHandler_) {
    bef_effect_result_t ret;
    ret = bef_effect_ai_face_attribute_create(0, faceAttributeModelPath_.c_str(),
                                              &faceAttributesHandler_);
    log = [NSString stringWithFormat:@"BDProcessor::processFaceDetect create face attribute handle failed ! %d", ret];
    logMessage(ret, log);
    
    ret = bef_effect_ai_face_attribute_check_license(faceAttributesHandler_, licensePath_.c_str());
    log = [NSString stringWithFormat:@"BDProcessor::processFaceDetect check_license face attribute failed ! %d", ret];
    logMessage(ret, log);
  }
  
  bef_ai_face_info faceInfo;
  memset(&faceInfo, 0, sizeof(bef_ai_face_info));
  bef_effect_result_t ret;
  ret = bef_effect_ai_face_detect(faceDetectHandler_, rgbaBuffer_, BEF_AI_PIX_FMT_RGBA8888, prevFrame_.yStride, prevFrame_.height, prevFrame_.yStride * 4, BEF_AI_CLOCKWISE_ROTATE_0, BEF_DETECT_MODE_VIDEO | BEF_DETECT_FULL, &faceInfo);
  log = [NSString stringWithFormat:@"BDProcessor::processFaceDetect face info detect failed ! %d", ret];
  logMessage(ret, log);
  
  bef_ai_face_attribute_result attributeResult;
  if (faceInfo.face_count > 0) {
    unsigned long long attriConfig =
    BEF_FACE_ATTRIBUTE_AGE | BEF_FACE_ATTRIBUTE_HAPPINESS |
    BEF_FACE_ATTRIBUTE_EXPRESSION | BEF_FACE_ATTRIBUTE_GENDER
    | BEF_FACE_ATTRIBUTE_RACIAL | BEF_FACE_ATTRIBUTE_ATTRACTIVE;
    
    ret = bef_effect_ai_face_attribute_detect_batch(faceAttributesHandler_, rgbaBuffer_,
                                                    BEF_AI_PIX_FMT_RGBA8888,
                                                    prevFrame_.yStride,
                                                    prevFrame_.height,
                                                    prevFrame_.yStride * 4,
                                                    faceInfo.base_infos,
                                                    faceInfo.face_count, attriConfig,
                                                    &attributeResult);
    log = [NSString stringWithFormat:@"face attribute detect failed ! %d", ret];
    logMessage(ret, log);
  }
  
  rapidjson::StringBuffer strBuf;
  rapidjson::PrettyWriter<rapidjson::StringBuffer> writer(strBuf);
  writer.SetMaxDecimalPlaces(3);
  writer.StartObject();
  writer.Key("plugin.bytedance.face.info");
  writer.StartArray();
  for (int i = 0; i < faceInfo.face_count; ++i) {
    writer.StartObject();
    writer.Key("yaw");
    writer.Double(faceInfo.base_infos[i].yaw);
    writer.Key("roll");
    writer.Double(faceInfo.base_infos[i].roll);
    writer.Key("pitch");
    writer.Double(faceInfo.base_infos[i].pitch);
    writer.Key("action");
    writer.Int(faceInfo.base_infos[i].action);
    writer.Key("expression");
    writer.Int((int)attributeResult.attr_info[i].exp_type);
    //    writer.Key("confused_prob");
    //    writer.Double(attributeResult.attr_info[i].confused_prob);
    writer.EndObject();
  }
  writer.EndArray();
  writer.EndObject();
  NSString* text = [[NSString alloc] initWithCString:strBuf.GetString() encoding:NSUTF8StringEncoding];
  logMessage(-1, text);
  dataCallback(text);
}

void BDProcessor::processHandDetect() {
  if (!handDetectHandler_) {
    bef_effect_result_t ret;
    
    ret = bef_effect_ai_hand_detect_create(&handDetectHandler_, 0);
    log = [NSString stringWithFormat:@"BDProcessor::processHandDetect create hand detect handle failed ! %d", ret];
    logMessage(ret, log);
    ret = bef_effect_ai_hand_check_license(handDetectHandler_, licensePath_.c_str());
    log = [NSString stringWithFormat:@"BDProcessor::processHandDetect check_license hand detect failed ! %d", ret];
    logMessage(ret, log);
    ret = bef_effect_ai_hand_detect_setmodel(handDetectHandler_,
                                             BEF_AI_HAND_MODEL_DETECT,
                                             handDetectModelPath_.c_str());
    ret = bef_effect_ai_hand_detect_setmodel(handDetectHandler_,
                                             BEF_AI_HAND_MODEL_BOX_REG,
                                             handBoxModelPath_.c_str());
    ret = bef_effect_ai_hand_detect_setmodel(handDetectHandler_,
                                             BEF_AI_HAND_MODEL_GESTURE_CLS,
                                             handGestureModelPath_.c_str());
    ret = bef_effect_ai_hand_detect_setmodel(handDetectHandler_,
                                             BEF_AI_HAND_MODEL_KEY_POINT,
                                             handKPModelPath_.c_str());
    ret = bef_effect_ai_hand_detect_setparam(handDetectHandler_, BEF_HAND_MAX_HAND_NUM,
                                             2);
    ret = bef_effect_ai_hand_detect_setparam(handDetectHandler_,
                                             BEF_HNAD_ENLARGE_FACTOR_REG, 2.0);
  }
  
  bef_ai_hand_info handInfo;
  bef_effect_result_t ret;
  ret = bef_effect_ai_hand_detect(handDetectHandler_, rgbaBuffer_,
                                  BEF_AI_PIX_FMT_RGBA8888, prevFrame_.yStride,
                                  prevFrame_.height, prevFrame_.yStride * 4,
                                  BEF_AI_CLOCKWISE_ROTATE_0,
                                  BEF_AI_HAND_MODEL_DETECT | BEF_AI_HAND_MODEL_BOX_REG |
                                  BEF_AI_HAND_MODEL_GESTURE_CLS |
                                  BEF_AI_HAND_MODEL_KEY_POINT, &handInfo, 0);
  log = [NSString stringWithFormat:@"hand detect failed ! %d", ret];
  logMessage(ret, log);
  
  rapidjson::StringBuffer strBuf;
  rapidjson::PrettyWriter<rapidjson::StringBuffer> writer(strBuf);
  writer.SetMaxDecimalPlaces(3);
  writer.StartObject();
  writer.Key("plugin.bytedance.hand.info");
  
  writer.StartArray();
  for (int i = 0; i < handInfo.hand_count; i++) {
    bef_ai_hand hand = handInfo.p_hands[i];
    writer.StartObject();
    writer.Key("action");
    writer.Int(hand.action);
    
    writer.Key("seq_action");
    writer.Double(hand.seq_action);
    writer.EndObject();
  }
  
  writer.EndArray();
  
  writer.EndObject();
  NSString* text = [[NSString alloc] initWithCString:strBuf.GetString() encoding:NSUTF8StringEncoding];
  dataCallback(text);
}

void BDProcessor::processLightDetect() {
  if (!lightDetectHandler_) {
    bef_effect_result_t ret;
    
    ret = bef_effect_ai_lightcls_create(&lightDetectHandler_,
                                        lightDetectModelPath_.c_str(), 5);
    log = [NSString stringWithFormat:@"BDProcessor::processLightDetect create face detect handle failed ! %d", ret];
    logMessage(ret, log);
    ret = bef_effect_ai_lightcls_check_license(lightDetectHandler_, licensePath_.c_str());
    log = [NSString stringWithFormat:@"BDProcessor::processLightDetect check_license light detect failed ! %d", ret];
    logMessage(ret, log);
  }
  
  bef_effect_result_t ret;
  bef_ai_light_cls_result lightInfo;
  ret = bef_effect_ai_lightcls_detect(lightDetectHandler_, rgbaBuffer_,
                                      BEF_AI_PIX_FMT_RGBA8888, prevFrame_.yStride,
                                      prevFrame_.height, prevFrame_.yStride * 4,
                                      BEF_AI_CLOCKWISE_ROTATE_0, &lightInfo);
  log = [NSString stringWithFormat:@"light detect failed ! %d", ret];
  logMessage(ret, log);
  
  rapidjson::StringBuffer strBuf;
  rapidjson::PrettyWriter<rapidjson::StringBuffer> writer(strBuf);
  writer.SetMaxDecimalPlaces(3);
  writer.StartObject();
  writer.Key("plugin.bytedance.light.info");
  writer.StartObject();
  writer.Key("selected_index");
  writer.Int(lightInfo.selected_index);
  writer.Key("prob");
  writer.Double(lightInfo.prob);
  writer.EndObject();
  writer.EndObject();
  NSString* text = [[NSString alloc] initWithCString:strBuf.GetString() encoding:NSUTF8StringEncoding];
  dataCallback(text);
}

int BDProcessor::processFrame(AgoraExtVideoFrame* capturedFrame) {
  const std::lock_guard<std::mutex> lock(mutex_);
  
  if (aiEffectEnabled_ || faceAttributeEnabled_) {
    prepareCachedVideoFrame(capturedFrame);
  }
  
  if (faceAttributeEnabled_) {
    processFaceDetect();
  }
  
  if (handDetectEnabled_) {
    processHandDetect();
  }
  
  if (lightDetectEnabled_) {
    processLightDetect();
  }
  
  if (aiEffectEnabled_) {
    processEffect(capturedFrame);
  }
  
  return 0;
}

int BDProcessor::releaseEffectEngine() {
  const std::lock_guard<std::mutex> lock(mutex_);
  if (byteEffectHandler_) {
    bef_effect_ai_destroy(byteEffectHandler_);
    byteEffectHandler_ = nullptr;
  }
  aiEffectEnabled_ = false;
  licensePath_.clear();
  modelDir_.clear();
  
  if (aiNodes_) {
    for (int i = 0; i < aiNodeCount_; i++) {
      free(aiNodes_[i]);
    }
    free(aiNodes_);
  }
  aiNodeIntensities_.clear();
  aiNodeKeys_.clear();
  aiNodeCount_ = 0;
  aiEffectNeedUpdate_ = false;
  
  faceStickerEnabled_ = false;
  faceStickerItemPath_.clear();
  
  if (yuvBuffer_) {
    free(yuvBuffer_);
    yuvBuffer_ = nullptr;
  }
  if (rgbaBuffer_) {
    free(rgbaBuffer_);
    rgbaBuffer_ = nullptr;
  }
  prevFrame_ = [AgoraExtVideoFrame new];
  
  faceAttributeEnabled_ = false;
  faceDetectModelPath_.clear();
  faceAttributeModelPath_.clear();
  if (faceDetectHandler_) {
    bef_effect_ai_face_detect_destroy(faceDetectHandler_);
    faceDetectHandler_ = nullptr;
  }
  if (faceAttributesHandler_) {
    bef_effect_ai_face_attribute_destroy(faceAttributesHandler_);
    faceAttributesHandler_ = nullptr;
  }
  
  handDetectEnabled_ = false;
  handDetectModelPath_.clear();
  handBoxModelPath_.clear();
  handGestureModelPath_.clear();
  handKPModelPath_.clear();
  if (handDetectHandler_) {
    bef_effect_ai_hand_detect_destroy(handDetectHandler_);
  }
  
  lightDetectEnabled_ = false;
  lightDetectModelPath_.clear();
  if (lightDetectHandler_) {
    bef_effect_ai_lightcls_release(lightDetectHandler_);
  }
  
  return 0;
}

int BDProcessor::setParameters(std::string parameter) {
  const std::lock_guard<std::mutex> lock(mutex_);
  Document d;
  d.Parse(parameter.c_str());
  if (d.HasParseError()) {
    return -ByteDanceErrorCodeInvalidJSON;
  }
  
  if (d.HasMember("plugin.bytedance.licensePath")) {
    Value& licensePath = d["plugin.bytedance.licensePath"];
    if (!licensePath.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    licensePath_ = std::string(licensePath.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.modelDir")) {
    Value& modelDir = d["plugin.bytedance.modelDir"];
    if (!modelDir.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    modelDir_ = std::string(modelDir.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.aiEffectEnabled")) {
    Value& enabled = d["plugin.bytedance.aiEffectEnabled"];
    if (!enabled.IsBool()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    aiEffectEnabled_ = enabled.GetBool();
  }
  
  if (d.HasMember("plugin.bytedance.ai.composer.nodes")) {
    Value& nodes = d["plugin.bytedance.ai.composer.nodes"];
    if (!nodes.IsArray()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    
    if (aiNodes_) {
      for (int i = 0; i < aiNodeCount_; i++) {
        free(aiNodes_[i]);
      }
      free(aiNodes_);
    }
    aiNodeIntensities_.clear();
    aiNodeKeys_.clear();
    aiNodeCount_ = nodes.Size();
    if (aiNodeCount_ > 0) {
      aiNodes_ = (char **) malloc(nodes.Size() * sizeof(char *));
      for (SizeType i = 0; i < nodes.Size(); i++) {
        if (!nodes[i].IsObject()) {
          return -ByteDanceErrorCodeInvalidJSONType;
        }
        Value &node = nodes[i];
        
        if (node.HasMember("path") && node.HasMember("key") &&
            node.HasMember("intensity")) {
          Value &vPath = node["path"];
          Value &vKey = node["key"];
          Value &vIntensity = node["intensity"];
          const char *path = vPath.GetString();
          size_t strLength = strlen(path);
          aiNodes_[i] = (char *) malloc((strLength + 1) * sizeof(char *));
          strncpy(aiNodes_[i], path, strLength);
          aiNodes_[i][strLength] = '\0';
          aiNodeKeys_.push_back(vKey.GetString());
          aiNodeIntensities_.push_back(vIntensity.GetFloat());
        } else {
          log = [NSString stringWithFormat:@"plugin.bytedance.ai.composer.nodes param error: idx %d", i];
          logMessage(-1, log);
        }
      }
    }
    aiEffectNeedUpdate_ = true;
  }
  
  if (d.HasMember("plugin.bytedance.faceAttributeEnabled")) {
    Value& enabled = d["plugin.bytedance.faceAttributeEnabled"];
    if (!enabled.IsBool()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    faceAttributeEnabled_ = enabled.GetBool();
  }
  
  if (d.HasMember("plugin.bytedance.faceDetectModelPath")) {
    Value& faceDetectModelPath = d["plugin.bytedance.faceDetectModelPath"];
    if (!faceDetectModelPath.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    faceDetectModelPath_ = std::string(faceDetectModelPath.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.faceAttributeModelPath")) {
    Value& attributeModelPath = d["plugin.bytedance.faceAttributeModelPath"];
    if (!attributeModelPath.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    faceAttributeModelPath_ = std::string(attributeModelPath.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.faceStickerEnabled")) {
    Value& enabled = d["plugin.bytedance.faceStickerEnabled"];
    if (!enabled.IsBool()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    faceStickerEnabled_ = enabled.GetBool();
  }
  
  if (d.HasMember("plugin.bytedance.faceStickerItemResourcePath")) {
    Value& path = d["plugin.bytedance.faceStickerItemResourcePath"];
    if (!path.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    faceStickerItemPath_ = std::string(path.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.handDetectEnabled")) {
    Value& enabled = d["plugin.bytedance.handDetectEnabled"];
    if (!enabled.IsBool()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    handDetectEnabled_ = enabled.GetBool();
  }
  
  if (d.HasMember("plugin.bytedance.handDetectModelPath")) {
    Value& path = d["plugin.bytedance.handDetectModelPath"];
    if (!path.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    handDetectModelPath_ = std::string(path.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.handBoxModelPath")) {
    Value& path = d["plugin.bytedance.handBoxModelPath"];
    if (!path.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    handBoxModelPath_ = std::string(path.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.handGestureModelPath")) {
    Value& path = d["plugin.bytedance.handGestureModelPath"];
    if (!path.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    handGestureModelPath_ = std::string(path.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.handKPModelPath")) {
    Value& path = d["plugin.bytedance.handKPModelPath"];
    if (!path.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    handKPModelPath_ = std::string(path.GetString());
  }
  
  if (d.HasMember("plugin.bytedance.lightDetectEnabled")) {
    Value& enabled = d["plugin.bytedance.lightDetectEnabled"];
    if (!enabled.IsBool()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    lightDetectEnabled_ = enabled.GetBool();
  }
  
  if (d.HasMember("plugin.bytedance.lightDetectModelPath")) {
    Value& path = d["plugin.bytedance.lightDetectModelPath"];
    if (!path.IsString()) {
      return -ByteDanceErrorCodeInvalidJSONType;
    }
    lightDetectModelPath_ = std::string(path.GetString());
  }
  
  return 0;
}

std::thread::id BDProcessor::getThreadId() {
  std::thread::id id = std::this_thread::get_id();
  return id;
}

}
}
