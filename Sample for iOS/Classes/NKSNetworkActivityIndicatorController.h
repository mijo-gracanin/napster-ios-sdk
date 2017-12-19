//
//  NKSNetworkActivityIndicatorController.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NKSNetworkActivityIndicatorController : NSObject

+ (NKSNetworkActivityIndicatorController*)shared;
- (void)incrementActivities;
- (void)decrementActivities;

@end
