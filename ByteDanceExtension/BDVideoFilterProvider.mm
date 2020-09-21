//
//  BDVideoFilterProvider.m
//  ByteDanceExtension
//
//  Created by LLF on 2020/9/21.
//

#import "BDVideoFilterProvider.h"
#import "BDVideoFilterProviderDelegate.h"
#include <memory>
#include "BDVideoFlilter.h"

@interface BDVideoFilterProvider() <BDVideoFilterProviderDelegate> {
  std::shared_ptr<>
}
@end

@implementation BDVideoFilterProvider

- (NSString * _Nonnull)uniqueName {
  return @"ByteDanceVideoFilterProvider";
}

- (NSString * _Nonnull)vendor {
  return @"ByteDance";
}

- (NSString * _Nonnull)version {
  return @"v3.9.2.1";
}

- (id<BDVideoFilterDelegate> _Nonnull)videoFilterProvider {
  <#code#>
}

@end
