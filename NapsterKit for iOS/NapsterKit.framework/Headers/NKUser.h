//
//  NKUser.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 Notification will be posted when user model changes.
 */
extern NSString* const NKNotificationUserChanged;

/**
 Subscription state.
 */
typedef NS_ENUM(NSInteger, NKSubscriptionState) {
    NKSubscriptionStateUnknown  = 0, /* unknown subscription state, maybe user needs to update their SDK version    */
    NKSubscriptionStateTrial    = 1, /* user is in a free trial                                                     */
    NKSubscriptionStatePaying   = 2, /* user is paying                                                              */
    NKSubscriptionStateExpired  = 3, /* trial has ended, user has not yet subscribed                                */
};

/**
 User model.
 */
@interface NKUser : NSObject

/**
 User ID for Napster Service.
 */
@property (nonatomic, copy, readonly)   NSString                *ID;

/**
 Subscription state for user.
 */
@property (nonatomic, assign, readonly) NKSubscriptionState     subscriptionState;

/**
 Expiration date for current subscription state.
 */
@property (nonatomic, copy, readonly)   NSDate                  *expirationDate;

/**
 Number of plays remaining if user is on a play based tier.
 If this parameter is `nil`, then user isn't on a play based tier.
 */
@property (nonatomic, copy, readonly)   NSNumber                *playsRemaining;

@end
