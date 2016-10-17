//
//  NKSession.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NKOAuthToken.h"
#import "NKUser.h"

/**
 Session state.
 */
typedef NS_ENUM(NSInteger, NKSessionState) {
    NKSessionStateClosed  = 0,  /* Session is invalid. */
    NKSessionStateOpen    = 1,  /* Session is in opened state and can be used to make authenticated API calls. */
    NKSessionStateExpired = 2,  /* Session was opened, but has expired. */
};

/**
 Authentication session.
 */
@interface NKSession : NSObject

/**
 Session state.
 */
@property (nonatomic, assign, readonly) NKSessionState  state;

/**
 Session OAuth token.
 */
@property (nonatomic, strong, readonly) NKOAuthToken    *token;

/**
 User model for current authenticated.
 */
@property (nonatomic, strong, readonly) NKUser          *user;

/**
 Convenience property that returns can session be used to make authenticated HTTP requests.
 */
@property (nonatomic, assign, readonly) BOOL            isOpen;

@end
