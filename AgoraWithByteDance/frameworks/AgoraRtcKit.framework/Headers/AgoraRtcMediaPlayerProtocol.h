//
//  AgoraRtcMediaPlayerProtocol.h
//  AgoraRtcMediaPlayerProtocol
//
//  Copyright (c) 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraObjects.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView View;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView View;
#endif

NS_ASSUME_NONNULL_BEGIN
@protocol AgoraRtcMediaPlayerProtocol <NSObject>

/**
 * Get unique media player id of the media player entity.
 * @return
 * - >= 0: The mediaPlayerId of this media player entity.
 * - < 0: Failure.
 */
- (int)getMediaPlayerId;
/**
 * Opens a media file with a specified URL.
 * @param url The URL of the media file that you want to play.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)open:(NSString *)url startPos:(NSInteger)startPos;

/**
 * Plays the media file.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)play;

/**
 * Pauses playing the media file.
 */
- (int)pause;

/**
 * Stops playing the current media file.
 */
- (int)stop;

/**
 * Resumes playing the media file.
 */
- (int)resume;

/**
 * Sets the current playback position of the media file.
 * @param position The new playback position (ms).
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)seekToPosition:(NSInteger)position;

/**
 * Gets the duration of the media file.
 */
- (NSInteger)getDuration;

/**
 * Gets the current playback position of the media file.(ms).
 */
- (NSInteger)getPosition;
/**
 * Gets the number of the media streams in the media resource.
 */
- (NSInteger)getStreamCount;

/** Gets the detailed information of the media stream.
 
 @param index The index of the media stream.
 
 @return * If the call succeeds, returns the detailed information of the media
 stream. See AgoraMediaStreamInfo.
 * If the call fails and returns nil.
 */
- (AgoraRtcMediaStreamInfo *_Nullable)getStreamByIndex:(int)index;

/**
 * Sets whether to loop the media file for playback.
 * @param loopCount the number of times looping the media file.
 * - 0: Play the audio effect once.
 * - 1: Play the audio effect twice.
 * - -1: Play the audio effect in a loop indefinitely, until stopEffect() or stop() is called.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)setLoopCount:(int)loopCount;

/**
 * Change playback speed
 * @param speed the enum of playback speed
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)changePlaybackSpeed:(AgoraMediaPlayBackSpeed)speed;

/**
 * Slect playback audio track of the media file
 * @param speed the index of the audio track in meia file
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)selectAudioTrack:(int)index;

/**
 * take screenshot while playing  video
 * @param filename the filename of screenshot file
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)takeScreenshot:(NSString *)filename;

/**
 * select internal subtitles in video
 * @param index the index of the internal subtitles
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)selectInternalSubtitle:(int)index;

/**
 * set an external subtitle for video
 * @param url The URL of the subtitle file that you want to load.
 * @return
 * - 0: Success.
 * - < 0: Failure.
 */
- (int)setExternalSubtitle:(NSString *)url;

/** Gets current playback state.
 
 @return * The call succeeds and returns current playback state. See
 AgoraMediaPlayerState.
 * The call fails and returns nil.
 */
- (AgoraMediaPlayerState)getPlayerState;

/**
 * @brief Turn mute on or off
 *
 * @return mute Whether to mute on
 */
- (int)mute:(bool)isMute;

/**
 * @brief Get mute state
 *
 * @return mute Whether is mute on
 */
- (BOOL)getMute;

/**
 * @brief Adjust playback volume
 *
 * @param volume The volume value to be adjusted
 * The volume can be adjusted from 0 to 400:
 * 0: mute;
 * 100: original volume;
 * 400: Up to 4 times the original volume (with built-in overflow protection).
 * @return int < 0 on behalf of an error, the value corresponds to one of MEDIA_PLAYER_ERROR
 */
- (int)adjustPlayoutVolume:(int)volume;

/**
 * @brief Get the current playback volume
 *
 * @return  volume
 */
- (int)getPlayoutVolume;

/**
 * @brief adjust publish signal volume
 */
- (int)adjustPublishSignalVolume:(int)volume;

/**
 * @brief get publish signal volume
 */
- (int)getPublishSignalVolume;

/**
 * @brief modify player option before play,
 * @param [in] key
 *        the option key name reference AgoraConstants.h
 * @param [in] value
 *        the option value
 * @return int <= 0 On behalf of an error, the value corresponds to one of PLAYER_ERROR
 */
- (int)setPlayerOption:(NSString *)key value:(NSInteger)value;

/**
 * @brief Set video rendering view
 */
- (int)setView:(View *_Nullable)view;

/**
 * @brief Set video display mode
 *
 * @param renderMode Video display mode
 * @return int < 0 on behalf of an error, the value corresponds to one of MEDIA_PLAYER_ERROR
 */
- (int)setRenderMode:(AgoraMediaPlayerRenderMode)mode;


@end
NS_ASSUME_NONNULL_END
