//
//  AgoraRtcEngineKitEx.h
//  AgoraRtcEngineKit
//
//  Copyright (c) 2020 Agora. All rights reserved.
//  Created by LLF on 2020/3/9.
//

#import "AgoraRtcEngineKit.h"
#import "AgoraObjects.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@interface AgoraRtcEngineKit(Ex)

/**
 * Joins a channel.
 *
 * Users in the same channel can talk to each other, and multiple users in the
 * same channel can start a group chat. Users with different App IDs cannot
 * call each other even if they join the same channel.
 *
 * You must call the {@link leaveChannel: leaveChannel} method to exit the
 * current call before entering another channel. This method call is
 * asynchronous; therefore, you can call this method in the main user interface
 * thread.
 *
 * A successful method call triggers the following callbacks:
 *
 * - The local client: {@link AgoraRtcEngineDelegate.rtcEngine:didJoinChannel:withUid:elapsed: didJoinChannel}.
 * - The remote client: {@link AgoraRtcEngineDelegate.rtcEngine:didJoinedOfUid:elapsed: didJoinedOfUid},
 * if the user joining the channel is in the Communication profile, or is a
 * BROADCASTER in the Live Broadcast profile.
 *
 * When the connection between the client and Agora's server is interrupted due
 * to poor network conditions, the SDK tries reconnecting to the server. When
 * the local client successfully rejoins the channel, the SDK triggers the {@link AgoraRtcEngineDelegate.rtcEngine:didRejoinChannel:withUid:elapsed: didRejoinChannel} callback on the local client.
 *
 * @note
 * - When joining a channel, the SDK calls
 * `setCategory(AVAudioSessionCategoryPlayAndRecord)` to set `AVAudioSession`
 * to `PlayAndRecord` mode. When `AVAudioSession` is set to `PlayAndRecord`
 * mode, the sound played (for example a ringtone) is interrupted. The app
 * should not set `AVAudioSession` to any other mode.
 * - The SDK uses the iOS's AVAudioSession shared object for audio recording
 * and playback. Using this object may affect the SDK’s audio functions.
 * @param token The token for authentication.
 * - In situations not requiring high security: You can use the temporary token
 * generated at Console. For details, see [Get a temporary token](https://docs.agora.io/en/Agora%20Platform/token?platform=All%20Platforms#get-a-temporary-token).
 * - In situations requiring high security: Set it as the token generated at
 * you server. For details, see [Generate a token](https://docs.agora.io/en/Agora%20Platform/token?platform=All%20Platforms#get-a-token).
 * @param channelId Unique channel name for the AgoraRTC session in the string
 * format. The string length must be less than 64 bytes. Supported character
 * scopes are:
 * - All lowercase English letters: a to z.
 * - All uppercase English letters: A to Z.
 * - All numeric characters: 0 to 9.
 * - The space character.
 * - Punctuation characters and other symbols, including: "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", " {", "}", "|", "~", ",".
 * @param info (Optional) Additional information about the channel. This
 * parameter can be set to `nil` or contain channel related information. Other
 * users in the channel do not receive this message.
 * @param uid User ID. A 32-bit unsigned integer with a value ranging from 1 to
 * (2<sup>32</sup>-1). The `uid` must be unique. If a `uid` is not assigned (or
 * set to 0), the SDK assigns and returns a `uid` in the callback. Your app
 * must record and maintain the returned `uid` since the SDK does not do so.
 * @param connectionId pointer to connection ID, out param
 * @param mediaOptions AgoraRtcChannelMediaOptions Object.
 * @param joinSuccessBlock Same as {@link AgoraRtcEngineDelegate.rtcEngine:didJoinChannel:withUid:elapsed: didJoinChannel}. We recommend you set this parameter as `nil` to use `didJoinChannel`.
 * - If `joinSuccessBlock` is nil, the SDK triggers the `didJoinChannel` callback.
 * - If you implement both `joinSuccessBlock` and `didJoinChannel`, `joinSuccessBlock` takes higher priority than `didJoinChannel`.
 *
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)joinChannelExByToken:(NSString* _Nullable)token
                  channelId:(NSString* _Nonnull)channelId
                        uid:(NSUInteger)uid
               connectionId:(unsigned int *)connectionId
                   delegate:(id<AgoraRtcEngineDelegate> _Nullable)delegate
               mediaOptions:(AgoraRtcChannelMediaOptions* _Nonnull)mediaOptions
                joinSuccess:(void(^ _Nullable)(NSString* _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;

/**
 *  Updates the channel media options after joining the channel.
 *
 * @param mediaOptions The channel media options: ChannelMediaOptions.
 * @param connectionId connection ID
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)updateChannelExWithMediaOptions:(AgoraRtcChannelMediaOptions* _Nonnull)mediaOptions
                          connectionId:(unsigned int)connectionId;

/**
 * Leaves the channel.
 *
 * This method allows a user to leave the channel, for example, by hanging up or
 * exiting a call.
 *
 * This method also releases all resources related to the call.
 *
 * This method is an asynchronous call, which means that the result of this
 * method returns before the user has not actually left the channel. Once
 * the user successfully leaves the channel, the SDK triggers the
 * {@link AgoraRtcEngineDelegate.rtcEngine:didLeaveChannelWithStats: didLeaveChannelWithStats} callback.
 *
 * @note
 * - If you call {@link destroy} immediately after this method, the leaveChannel
 * process is interrupted, and the SDK does not trigger the
 * `didLeaveChannelWithStats` callback.
 * - When you call this method, the SDK deactivates the audio session on iOS by
 * default, and may affect other apps.
 *
 * @param channelId channel ID
 * @param connectionId connection ID
 * @param leaveChannelBlock This callback indicates that a user leaves a channel, and provides the statistics of the call in #AgoraChannelStats.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)leaveChannelEx:(NSString* _Nonnull)channelId
         connectionId:(unsigned int)connectionId
    leaveChannelBlock:(void(^ _Nullable)(AgoraChannelStats* _Nonnull stat))leaveChannelBlock;

/** Mutes a specified remote user's audio stream.

 @note  When setting to YES, this method stops playing audio streams without affecting the audio stream receiving process.

 @param uid  User ID whose audio streams the user intends to mute.
 @param mute * YES: Stops playing a specified user’s audio streams.
 * NO: Resumes playing a specified user’s audio streams.
 @param connectionId connection ID.
 
 @return * 0: Success.
* <0: Failure.
 */
- (int)muteRemoteAudioStreamEx:(NSUInteger)uid
                          mute:(BOOL)mute
                  connectionId:(unsigned int)connectionId;

/**
 * Sets the video encoder configuration.
 *
 * Each configuration profile corresponds to a set of video parameters,
 * including the resolution, frame rate, and bitrate.
 *
 * The parameters specified in this method are the maximum values under ideal network conditions.
 * If the video engine cannot render the video using the specified parameters
 * due to poor network conditions, the parameters further down the list are
 * considered until a successful configuration is found.
 *
 * @param config The local video encoder configuration, see #AgoraVideoEncoderConfiguration.
 * @param connectionId connection ID.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)setVideoEncoderConfigurationEx:(AgoraVideoEncoderConfiguration* _Nonnull)config
                         connectionId:(unsigned int)connectionId;

/** Binds the remote user to the video display window, that is, sets the view for the user of the specified uid.

 Usually, the application should specify the uid of the remote video in the method call before the user enters a channel. If the remote uid is unknown to the application, set it later when the application receives the [userJoinedBlock]([AgoraRtcEngineKit userJoinedBlock:]) event.
 If the Video Recording function is enabled, the Video Recording Service joins the channel as a dumb client, which means other clients will also receive the [didJoinedOfUid]([AgoraRtcEngineDelegate rtcEngine:didJoinedOfUid:elapsed:]) event. Your application should not bind it with the view, because it does not send any video stream. If your application cannot recognize the dumb client, bind it with the view when the [firstRemoteVideoDecodedOfUid]([AgoraRtcEngineDelegate rtcEngine:firstRemoteVideoDecodedOfUid:size:elapsed:]) event is triggered. To unbind the user with the view, set the view to null. After the user has left the channel, the SDK unbinds the remote user.

 @param remote AgoraRtcVideoCanvas
 @param connectionId connection ID.
 @return * 0: Success.
* <0: Failure.
 */
- (int)setupRemoteVideoEx:(AgoraRtcVideoCanvas* _Nonnull)remote
             connectionId:(unsigned int)connectionId;

/** Configures the remote video display mode. The application can call this method multiple times to change the display mode.

 @param uid  User id of the user whose video streams are received.
 @param mode AgoraVideoRenderMode
 @param mirror AgoraVideoMirrorMode
 @param connectionId connection ID.
 
 @return * 0: Success.
 * <0: Failure.
 */
- (int)setRemoteRenderModeEx:(NSUInteger)uid
                        mode:(AgoraVideoRenderMode)mode
                      mirror:(AgoraVideoMirrorMode)mirror
                connectionId:(unsigned int)connectionId;

/**
 * Stops or resumes receiving the video stream of a specified user.
 *
 * @note
 * Once you leave the channel, the settings in this method becomes invalid.
 *
 * @param uid ID of the specified remote user.
 * @param mute Determines whether to receive or stop receiving a specified video stream:
 * - `YES`: Stop receiving the specified video stream.
 * - `NO`: (Default) Receive the specified video stream.
 * @param connectionId connection ID.
 *
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)muteRemoteVideoStreamEx:(NSUInteger)uid
                          mute:(BOOL)mute
                  connectionId:(unsigned int)connectionId;

/** Pushes the external audio frame to the Agora SDK for encoding.
 *
 * @param data      External audio data.
 * @param sourceId  The audio track ID.
 * @param timestamp Time stamp of the external audio frame to be synchronized with the external video source.
 * @param connectionId connection ID.
 * @return * 0: Success.
 * <0: Failure.
 */
- (int)pushExternalAudioFrameExNSData:(NSData * _Nonnull)data
                             sourceId:(NSInteger)sourceId
                            timestamp:(NSTimeInterval)timestamp
                         connectionId:(unsigned int)connectionId;

/** Pushes the external audio frame to the Agora SDK for encoding.

 * @param data      External audio data.
 * @param samples   Number of samples for the push.
 * @param sourceId  The audio track ID.
 * @param timestamp Time stamp of the external audio frame to be synchronized with the external video source.
 * @param connectionId connection ID.
 * @return * 0: Success.
 * <0: Failure.
 */

- (int)pushExternalAudioFrameExRawData:(void * _Nonnull)data
                               samples:(NSInteger)samples
                              sourceId:(NSInteger)sourceId
                             timestamp:(NSTimeInterval)timestamp
                          connectionId:(unsigned int)connectionId __deprecated_msg("pushExternalAudioFrameExRawData:sourceId:timestamp:connectionId instead.");

/**
 * Pushes the external audio frame to the sample buffer for encoding.
 *
 * @param sampleBuffer Sample buffer
 * @param connectionId connection ID.
 * @return
 * -  0: Success.
 * - <0: Failure.
 */
- (int)pushExternalAudioFrameExSampleBuffer:(CMSampleBufferRef _Nonnull)sampleBuffer
                               connectionId:(unsigned int)connectionId;
/**
 * Pushes the external video frame.
 *
 * This method pushes the video frame using the AgoraVideoFrame class and
 * passes it to the Agora SDK with the `format` parameter in AgoraVideoFormat.
 *
 * Call {@link setExternalVideoSource:useTexture:pushMode: setExternalVideoSource}
 * and set the `pushMode` parameter as `YES` before calling this method.
 * @note
 * In the Communication profile, this method does not support pushing textured
 * video frames.
 * @param frame Video frame containing the SDK's encoded video data to be
 * pushed: #AgoraVideoFrame.
 * @param connectionId connection ID.
 * @return
 * - `YES`: Success.
 * - `NO`: Failure.
 */
- (BOOL)pushExternalVideoFrame:(AgoraVideoFrame * _Nonnull)frame connectionId:(unsigned int)connectionId;

- (int)sendCustomReportMessageEx:(NSString * _Nullable)messageId
                        category:(NSString * _Nullable)category
                           event:(NSString * _Nullable)event
                           label:(NSString * _Nullable)label
                           value:(NSInteger)value
                    connectionId:(unsigned int)connectionId;

@end

NS_ASSUME_NONNULL_END
