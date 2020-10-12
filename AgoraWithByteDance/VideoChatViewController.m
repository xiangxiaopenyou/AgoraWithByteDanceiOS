//
//  VideoChatViewController.m
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

#import "VideoChatViewController.h"
#import <ByteDanceExtension/BDVideoFilterProvider.h>
#import "BDResourceHelper.h"
#import "AppID.h"

@interface VideoChatViewController() <AgoraByteDanceDataReceiver, AgoraVideoFilterEventHandlerDelegate> {
  NSString *faceInfo;
  NSString *handInfo;
  NSString *lightInfo;
}

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (weak, nonatomic) IBOutlet UIView *localVideo;
@property (weak, nonatomic) IBOutlet UIView *remoteVideo;
@property (weak, nonatomic) IBOutlet UIView *controlButtons;
@property (weak, nonatomic) IBOutlet UIImageView *remoteVideoMutedIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *localVideoMutedBg;
@property (weak, nonatomic) IBOutlet UIImageView *localVideoMutedIndicator;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupButtons];
  [self hideVideoMuted];
  [self initializeAgoraEngine];
  [self setupVideo];
  [self setupLocalVideo];
  [self joinChannel];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)initializeAgoraEngine {
  AgoraRtcEngineConfig *config = [AgoraRtcEngineConfig new];
  config.appId = appID;
  AgoraVideoFilterExtension *ext = [AgoraVideoFilterExtension new];
  ext.provider = [BDVideoFilterProvider sharedInstance];
  ext.eventHandler = self;
  config.extensions = @[ext];
  self.agoraKit = [AgoraRtcEngineKit sharedEngineWithConfig:config delegate:self];
}

- (void)setupVideo {
  // Default mode is disableVideo
  [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
  [self.agoraKit setClientRole:AgoraClientRoleBroadcaster];
  [self.agoraKit enableVideo];
  //[self.agoraKit startPreview];
  // Set up the configuration such as dimension, frame rate, bit rate and orientation
  AgoraVideoEncoderConfiguration *encoderConfiguration =
  [[AgoraVideoEncoderConfiguration alloc] initWithSize:AgoraVideoDimension640x360
                                             frameRate:AgoraVideoFrameRateFps15
                                               bitrate:AgoraVideoBitrateStandard
                                       orientationMode:AgoraVideoOutputOrientationModeAdaptative mirrorMode:AgoraVideoMirrorModeAuto];
  [self.agoraKit setVideoEncoderConfiguration:encoderConfiguration];
  [[BDVideoFilterProvider sharedInstance] loadProcessor];
}

- (void)setupLocalVideo {
  AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
  videoCanvas.uid = 0;
  // UID = 0 means we let Agora pick a UID for us
  
  videoCanvas.view = self.localVideo;
  videoCanvas.renderMode = AgoraVideoRenderModeHidden;
  [self.agoraKit setupLocalVideo:videoCanvas];
  
  // Bind local video stream to view
}

- (void)joinChannel {
  [self.agoraKit joinChannelByToken:token channelId:@"demoChannel1" info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
    // Join channel "demoChannel1"
  }];
  [self.agoraKit startPreview];
  // The UID database is maintained by your app to track which users joined which channels. If not assigned (or set to 0), the SDK will allocate one and returns it in joinSuccessBlock callback. The App needs to record and maintain the returned value as the SDK does not maintain it.
  
  [self.agoraKit setEnableSpeakerphone:YES];
  [UIApplication sharedApplication].idleTimerDisabled = YES;
}

/// Callback to handle the event such when the first frame of a remote video stream is decoded on the device.
/// @param engine - RTC engine instance
/// @param uid - user id
/// @param size - the height and width of the video frame
/// @param elapsed - lapsed Time elapsed (ms) from the local user calling JoinChannel method until the SDK triggers this callback.
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
  if (self.remoteVideo.hidden) {
    self.remoteVideo.hidden = NO;
  }
  
  AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
  videoCanvas.uid = uid;
  // Since we are making a simple 1:1 video chat app, for simplicity sake, we are not storing the UIDs. You could use a mechanism such as an array to store the UIDs in a channel.
  
  videoCanvas.view = self.remoteVideo;
  videoCanvas.renderMode = AgoraVideoRenderModeHidden;
  [self.agoraKit setupRemoteVideo:videoCanvas];
  // Bind remote video stream to view
}

- (IBAction)hangUpButton:(UIButton *)sender {
  [self leaveChannel];
}

///  Leave the channel and handle UI change when it is done.
- (void)leaveChannel {
  [self.agoraKit leaveChannel:^(AgoraChannelStats *stat) {
    [self hideControlButtons];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.remoteVideo removeFromSuperview];
    [self.localVideo removeFromSuperview];
  }];
}

/// Callback to handle an user offline event.
/// @param engine - RTC engine instance
/// @param uid - user id
/// @param reason - why is the user offline
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
  self.remoteVideo.hidden = true;
}

- (void)setupButtons {
  [self performSelector:@selector(hideControlButtons) withObject:nil afterDelay:3];
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remoteVideoTapped:)];
  [self.view addGestureRecognizer:tapGestureRecognizer];
  self.view.userInteractionEnabled = true;
}

- (void)hideControlButtons {
  self.controlButtons.hidden = true;
}

- (void)remoteVideoTapped:(UITapGestureRecognizer *)recognizer {
  if (self.controlButtons.hidden) {
    self.controlButtons.hidden = false;
    [self performSelector:@selector(hideControlButtons) withObject:nil afterDelay:3];
  }
}

- (void)resetHideButtonsTimer {
  [VideoChatViewController cancelPreviousPerformRequestsWithTarget:self];
  [self performSelector:@selector(hideControlButtons) withObject:nil afterDelay:3];
}

- (IBAction)didClickMuteButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  [self.agoraKit muteLocalAudioStream:sender.selected];
  [self resetHideButtonsTimer];
}

- (IBAction)didClickVideoMuteButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  [self.agoraKit muteLocalVideoStream:sender.selected];
  self.localVideo.hidden = sender.selected;
  self.localVideoMutedBg.hidden = !sender.selected;
  self.localVideoMutedIndicator.hidden = !sender.selected;
  [self resetHideButtonsTimer];
}

/// A callback to handle muting of the audio
/// @param engine  - RTC engine instance
/// @param muted  - YES if muted; NO otherwise
/// @param uid  - user id
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
  self.remoteVideo.hidden = muted;
  self.remoteVideoMutedIndicator.hidden = !muted;
}

- (void) hideVideoMuted {
  self.remoteVideoMutedIndicator.hidden = true;
  self.localVideoMutedBg.hidden = true;
  self.localVideoMutedIndicator.hidden = true;
}

- (IBAction)didClickSwitchCameraButton:(UIButton *)sender {
  sender.selected = !sender.selected;
  [self.agoraKit switchCamera];
  [self resetHideButtonsTimer];
}

- (void)enableEffect {
  BDResourceHelper *resourceHelper = [[BDResourceHelper alloc] init];
  NSDictionary *node1 = @{
    @"path": [resourceHelper composerNodePath:@"lip/fuguhong"],
    @"key": @"Internal_Makeup_Lips",
    @"intensity": @1.0
  };
  
  NSDictionary * node2 = @{
    @"path": [resourceHelper composerNodePath:@"blush/weixun"],
    @"key": @"Internal_Makeup_Blusher",
    @"intensity": @1.0
  };
  
  NSDictionary * node3 = @{
    @"path": [resourceHelper composerNodePath:@"reshape_camera"],
    @"key": @"Internal_Deform_Face",
    @"intensity": @1.0
  };
  
  NSArray * nodes = @[
    node1,
    node2,
    node3,
  ];
  
  NSDictionary * dic = @{
    @"plugin.bytedance.licensePath" : [resourceHelper licensePath],
    @"plugin.bytedance.modelDir" : [resourceHelper modelDirPath],
    @"plugin.bytedance.aiEffectEnabled" : @YES,
    
    @"plugin.bytedance.faceAttributeEnabled" : @YES,
    @"plugin.bytedance.faceDetectModelPath" : [resourceHelper modelPath:FACE_MODEL],
    @"plugin.bytedance.faceAttributeModelPath" : [resourceHelper modelPath:FACE_ATTRIBUTE_MODEL],
    @"plugin.bytedance.faceStickerEnabled" : @YES,
    @"plugin.bytedance.faceStickerItemResourcePath" : [resourceHelper stickerPath:@"leisituer"],
    
    @"plugin.bytedance.handDetectEnabled": @YES,
    @"plugin.bytedance.handDetectModelPath": [resourceHelper modelPath:HAND_DET_MODEL],
    @"plugin.bytedance.handBoxModelPath": [resourceHelper modelPath:HAND_BOX_MODEL],
    @"plugin.bytedance.handGestureModelPath": [resourceHelper modelPath:HAND_GESTURE_MODEL],
    @"plugin.bytedance.handKPModelPath": [resourceHelper modelPath:HAND_KP_MODEL],
    
    @"plugin.bytedance.lightDetectEnabled": @YES,
    @"plugin.bytedance.lightDetectModelPath": [resourceHelper modelPath:LIGHTCLS_MODEL],
    @"plugin.bytedance.ai.composer.nodes": nodes
  };
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  [[BDVideoFilterProvider sharedInstance] setParameter:jsonString];
}

- (IBAction)enableEffectTapped:(UIButton *)sender {
  [self enableEffect];
}

#pragma mark - AgoraByteDanceDataReceiver

- (void)onDataReceive:(NSString *)data {
  if ([data containsString:@"plugin.bytedance.face.info"]) {
    faceInfo = data;
  }
  if ([data containsString:@"plugin.bytedance.hand.info"]) {
    handInfo = data;
  }
  if ([data containsString:@"plugin.bytedance.light.info"]) {
    lightInfo = data;
  }
  
  NSString* info = [NSString stringWithFormat:@"%@\n\n%@\n\n%@", lightInfo, handInfo, faceInfo];
  self.infoTextView.text = info;
}

#pragma mark - AgoraVideoFilterEventHandlerDelegate

- (void)onEvent:(NSString *)key value:(NSString *)value {
}

@end
