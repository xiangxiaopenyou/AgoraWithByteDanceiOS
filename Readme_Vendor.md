# 实现agora::rtc::IExtensionVideoFilter接口

```
// iOS
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
```

# 实现AgoraVideoFilterProviderDelegate接口

```
// iOS
@interface BDVideoFilterProvider : NSObject <AgoraVideoFilterProviderDelegate>
@property (nonatomic, weak) id<AgoraByteDanceDataReceiver> dataReceiver;
+ (instancetype)sharedInstance;

- (void)loadProcessor;
- (int)setParameter:(NSString *)parameter; // 设置模型加载，美颜，贴纸参数，参数用 json 的方式传输
@end
```

AgoraVideoFilterProviderDelegate接口定义如下

```
/**
 * Position of Video Filter.
 */
typedef NS_ENUM(NSInteger, AgoraVideoFilterPosition) {
  /**
   * 0: Video Filter Position Invalid.
   */
  AgoraVideoFilterPositionInvalid = 0,
  /**
   * 1: Video Filter Pre Encoder.
   */
  AgoraVideoFilterPositionPreEncoder = 1,
  /**
   * 2: Video Filter Post Decoder.
   */
  AgoraVideoFilterPositionPostDecoder = 2,
};

/**
 * Protocol of Video Filter Provider
 * It needs implement by Video Filter Vendor
 */
@protocol AgoraVideoFilterProviderDelegate <NSObject>

/**
 * Name of Provider
 */
- (NSString * _Nonnull)name;

/**
 * Version of Provider
 */
- (NSString * _Nonnull)version;

/**
 * Vendor of Provider,
 */
- (NSString * _Nonnull)vendor;

/**
 * VideoFilter Pointer of Provider
 * It needs implement all interface of agora::rtc::IExtensionVideoFilter
 */
- (void* _Nullable)createVideoFilter;

/**
 * VideoFilter Pointer Deleter of Provider
 */
- (bool)destroyVideoFilter:(void * _Nullable)videoFilter;

/**
 * Position of Video Filter
 */
- (AgoraVideoFilterPosition)videoFilterPosition;
@end
```

PS: 提供的framework需要使用SDK Cpp相关Interface，需要引入AgoraRtcKit2.framework, 不需要Emedded & Sign，只需要Do Not Embedded，因为最终的App负责嵌入AgoraRtcKit2.framework
