//
//  AgoraVideoFilterProviderDelegate.h
//  Agora Media SDK
//
//  Created by LLF on 2020/9/21.
//

#pragma once

#import <Foundation/Foundation.h>

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

/**
 * Protocol of Video Filter Event Handler
 * It needs implement by Client App
 */
@protocol AgoraVideoFilterEventHandlerDelegate <NSObject>
- (void)onEvent:(NSString * _Nullable)key value:(NSString * _Nullable)value;
@end
