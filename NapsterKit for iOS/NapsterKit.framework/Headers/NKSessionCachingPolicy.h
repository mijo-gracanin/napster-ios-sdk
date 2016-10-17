//
//  NKSessionCachingPolicy.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 Default key under which session is cached in `NSUserDefaults`.
 */
extern NSString *NKSessionCachingPolicyUserDefaultsKey;

/**
 Handlers persistance of session.
 */
@interface NKSessionCachingPolicy : NSObject

/**
 Called by the framework when persistance of session data is needed.
 */
-(void)cacheSerializedSession:(NSData*)encryptedSessionData;

/**
 Called by the framework when serialized session data is needed.
 */
-(NSData*)fetchSerializedSession;

/**
 Implementation that doesn't cache session data.
 When NKSession is deallocated from memory, user needs to manually open a new session.
 */
+(NKSessionCachingPolicy*)notCachingPolicy;

/**
 Implementation that caches session data in `NSUserDefaults` under key `NKSessionCachingPolicyUserDefaultsKey`.
 */
+(NKSessionCachingPolicy*)defaultPolicy;

@end
