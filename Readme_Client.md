# 初始化字节 plugin

使用 RtcEngine sharedEngineWithConfig初始化方法

```
// iOS
AgoraRtcEngineConfig *cfg = [AgoraRtcEngineConfig new];
cfg.appId = appID;
BDVideoFilterManager *provider = [BDVideoFilterManager sharedInstance];
[provider loadPlugin];
BDVideoExtensionObject *obj = [provider mediaFilterExtension];
obj.observer = self;
cfg.mediaFilterExtensions = @[obj];

self.agoraKit = [AgoraRtcEngineKit sharedEngineWithConfig:cfg delegate:self];
```

# 注册人脸识别，光线识别，表情识别，手部识别的回调

## iOS

```
cfg.eventDelegate = self; // self为实现了AgoraMediaFilterEventDelegate接口的对象
```

其中 self 需要实现以下 protocol

```
// iOS
@protocol AgoraMediaFilterEventDelegate <NSObject>
- (void)onEvent:(NSString * __nullable)vendor
            key:(NSString * __nullable)key
     json_value:(NSString * __nullable)json_value;
@end
```
# 设置参数

设置模型加载，美颜，贴纸参数，参数用 json 的方式传输

```
// iOS
[[BDVideoFilterManager sharedInstance] setParameter:jsonString];
```

参数解释如下

```
{
  "plugin.bytedance.licensePath" : "字节 lincense 的路径",
  "plugin.bytedance.modelDir" : "模型所在根目录",
  
  "plugin.bytedance.faceAttributeEnabled" : true, // 是否启用脸部属性检测
  "plugin.bytedance.faceDetectModelPath" : "字节脸部检测模型路径",
  "plugin.bytedance.faceAttributeModelPath" : "字节脸部属性模型路径",
  
  "plugin.bytedance.handDetectEnabled" : true, // 是否启用手部检测
  "plugin.bytedance.handBoxModelPath" : "字节手部 box 模型的路径",
  "plugin.bytedance.handKPModelPath" : "字节手部 kp 模型的路径",
  "plugin.bytedance.handGestureModelPath" : "手部姿势模型路径",
  "plugin.bytedance.handDetectModelPath" : "手部检测模型路径",

  "plugin.bytedance.lightDetectEnabled" : true, // 是否启用灯光检测
  "plugin.bytedance.lightDetectModelPath" : "字节灯光检测模型的路径",
  
  "plugin.bytedance.faceStickerEnabled" : true, // 是否启用贴纸
  "plugin.bytedance.faceStickerItemResourcePath" : "要加载贴纸所在路径",
 
  "plugin.bytedance.aiEffectEnabled" : true, // 是否启用字节特效
  "plugin.bytedance.ai.composer.nodes" : [ // 美颜，化妆和修容的 composer node
    {
      "path" : "美颜路径1",
      "key" : "美颜路径1对应的 Key",
      "intensity" : 1 // 美颜强度
    },
    {
      "path" : "美颜路径2",
      "key" : "美颜路径2对应的 Key",
      "intensity" : 1 // 美颜强度
    }
  ]
}
```

PS: 需要使用SDK Cpp相关Interface，需要引入AgoraRtcKit2.framework, 需要Emedded & Sign
