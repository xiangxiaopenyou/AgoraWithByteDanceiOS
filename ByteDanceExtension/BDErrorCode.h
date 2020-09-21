//
//  BDErrorCode.h
//  AgoraWithByteDance
//
//  Created by LLF on 2020/9/21.
//

#ifndef BDErrorCode_h
#define BDErrorCode_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, ByteDanceErrorCode) {
  ByteDanceErrorCodeOK = 0,
  ByteDanceErrorCodeNotInitRTCEngine = 1,
  ByteDanceErrorCodeNotInitVideoFilter = 2,
  ByteDanceErrorCodeNotInitPluginManager = 3,
  ByteDanceErrorCodeErrorParameter = 10,
  ByteDanceErrorCodeInvalidJSON = 100,
  ByteDanceErrorCodeInvalidJSONType = 101,
};

#endif /* BDErrorCode_h */
