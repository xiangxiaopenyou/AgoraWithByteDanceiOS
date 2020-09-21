//
//  LogUtils.h
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#ifndef logutils_h
#define logutils_h

#ifdef __cplusplus
extern "C" {
#endif
void logmessage(const char *message, ...) __attribute__((format(printf, 1, 2)));

#ifdef __cplusplus
}
#endif

#define PRINTF_INFO(...) logmessage(__VA_ARGS__)
#define PRINTF_ERROR(...) logmessage(__VA_ARGS__)
#endif /* logutils_h */
