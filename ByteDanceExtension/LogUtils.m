//
//  LogUtils.m
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import "LogUtils.h"
#import <Foundation/Foundation.h>

void logmessage(const char *message, ...) {
  va_list args;
  va_start(args, message);
  NSLog(@"%@",[[NSString alloc] initWithFormat:[NSString stringWithUTF8String:message] arguments:args]);
  va_end(args);
}
