# 实现agora::rtc::IExtensionVideoFilter接口

```
// iOS
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
```

# 实现agora::rtc::IExtensionProvider接口

```
// iOS
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
```

提供BDVideoFilterManager，定义如下

```
NS_ASSUME_NONNULL_BEGIN

@class BDVideoExtensionObject;

@interface BDVideoFilterManager : NSObject
+ (instancetype)sharedInstance;

+ (NSString * __nonnull)vendorName; //插件id
- (BDVideoExtensionObject * __nonnull)mediaFilterExtension; //实现了AgoraMediaFilterExtensionDelegate接口的对象
- (void)loadPlugin; // 加载插件
- (int)setParameter:(NSString * __nullable)parameter; //配置插件参数
@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface BDVideoExtensionObject : NSObject <AgoraMediaFilterExtensionDelegate>
@property (copy, nonatomic) NSString * __nonnull vendorName; //插件id
@property (assign, nonatomic) void * __nullable mediaFilterProvider; //实现了agora::rtc::IExtensionProvider接口对象
@property (weak, nonatomic) id<AgoraMediaFilterEventDelegate> __nullable observer; //实现了AgoraMediaFilterEventDelegate接口对象

@end

NS_ASSUME_NONNULL_END
```

AgoraMediaFilterExtensionDelegate接口定义如下

```
@protocol AgoraMediaFilterExtensionDelegate <NSObject>

- (NSString * __nonnull)vendor; //插件id

- (void * __nullable)mediaFilterProvider; //插件id
@optional
- (id<AgoraMediaFilterEventDelegate> __nullable)mediaFilterObserver; //实现了AgoraMediaFilterEventDelegate接口对象
@end
```

AgoraMediaFilterEventDelegate接口定义如下

```
- (void)onEvent:(NSString * __nullable)vendor
            key:(NSString * __nullable)key
     json_value:(NSString * __nullable)json_value;
```

PS: 提供的framework需要使用SDK Cpp相关Interface，需要引入AgoraRtcKit2.framework, 不需要Emedded & Sign，只需要Do Not Embedded，因为最终的App负责嵌入AgoraRtcKit2.framework
