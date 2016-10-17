//
//  NKNapster.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@class NKUser;
@class NKStation;

@class NKRequest;
@class NKOAuthToken;

@class NKTrackPlayer;

@class NKSession;
@class NKSessionCachingPolicy;

@class NKStationPlayer;

typedef void (^StationPlayerCompletion)(NKStationPlayer *stationPlayer, NSError *error);

typedef void (^OpenSessionCompletionHandler)(NKSession *session, NSError *error);

typedef void (^RequestCompletionHandler)(id json, NSError *error);

/**
 HTTP method type
 */
typedef NS_ENUM(NSInteger, NKHTTPMethod) {
    NKHTTPMethodGET,
    NKHTTPMethodPOST,
    NKHTTPMethodPUT,
    NKHTTPMethodDELETE,
};

/**
 NapsterKit engine.
 */
@interface NKNapster : NSObject

#pragma mark - Factory methods

/**
 Creates NapsterKit engine. 
 
 @param consumerKey     Key that will be used to access APIs.
 @param consumerSecret  Secret information that will be used for authentication purposes.

 To obtain `consumerKey` and `consumerSecret`, please register at NapsterKit portal.
 https://developer.napster.com/
 */
+(NKNapster*)napsterWithConsumerKey:(NSString*)consumerKey
                        consumerSecret:(NSString*)consumerSecret;

/**
 Creates NapsterKit engine.
 
 @param consumerKey             Key that will be used to access APIs.
 @param consumerSecret          Secret information that will be used for authentication purposes.
 @param sessionCachingPolicy    Policy that controls how session will be persisted during it's lifetime.
 
 To obtain `consumerKey` and `consumerSecret`, please register at NapsterKit portal.
 https://developer.napster.com/
 */
+(NKNapster*)napsterWithConsumerKey:(NSString*)consumerKey
                        consumerSecret:(NSString*)consumerSecret
                  sessionCachingPolicy:(NKSessionCachingPolicy*)sessionCachingPolicy;

/**
 Creates NapsterKit engine.
 
 @param consumerKey             Key that will be used to access APIs.
 @param consumerSecret          Secret information that will be used for authentication purposes.
 @param sessionCachingPolicy    Policy that controls how session will be persisted during it's lifetime.
 @param notificationCenter      Notification center that the SDK should use.
 
 To obtain `consumerKey` and `consumerSecret`, please register at NapsterKit portal.
 https://developer.napster.com/
 */
+(NKNapster*)napsterWithConsumerKey:(NSString*)consumerKey
                        consumerSecret:(NSString*)consumerSecret
                  sessionCachingPolicy:(NKSessionCachingPolicy*)sessionCachingPolicy
                    notificationCenter:(NSNotificationCenter*)notificationCenter;

#pragma mark - Configuration

/**
 Returns the currently set OAuth consumer key.
 */
@property (nonatomic, copy, readonly) NSString *consumerKey;

/**
 Returns the currently set OAuth consumer secret.
 */
@property (nonatomic, copy, readonly) NSString *consumerSecret;

#pragma mark - Session

/**
 Calculates url that handles NapsterKit login logic.
 
 @param Url where user will be redirected after login process. This is usually your 
        web service url that will extract OAuth token from response.
 */
+(NSString*)loginUrlWithConsumerKey:(NSString*)consumerKey
                        redirectUrl:(NSURL*)redirectUrl;

/**
 Returns current session that the engine is using.
 */
@property (nonatomic, readonly)         NKSession   *session;

/**
 Returns information is session open and usable to make authenticated API calls.
 */
@property (nonatomic, assign, readonly) BOOL        isSessionOpen;

/**
 Opens session with code from implicit OAuth flow
 */
-(void)openSessionWithOAuthCode:(NSString*)code
                        baseURL:(NSURL*)baseURL
              completionHandler:(OpenSessionCompletionHandler)completionHandler;


/**
 Opens session for OAuth token.
 */
- (void)openSessionWithToken:(NKOAuthToken*)token
           completionHandler:(OpenSessionCompletionHandler)completionHandler;

/**
 Refreshes existing open session
 
 @warning Only call this method when the session is opened.
 
 */
typedef void (^RefreshSessionCompletionHandler)(NKSession *session, NSError *error);
- (void)refreshSessionWithCompletionHandler:(RefreshSessionCompletionHandler)handler;

/**
 Closes opened session.
 */
- (void)closeSession;

#pragma mark - API

/**
 Convenience method for communication with the Napster APIs.
 
 @param method          HTTP method.
 @param path            HTTP request path.
 @param authenticated   Add authentication info to request.
 @param params          HTTP request parameters.
 @param completion      Callback that will be called if request isn't cancelled.
 
 @warning   Calling this method with true value for authenticated param will cause exception if
            session isn't opened.
 */
-(NKRequest*)requestForMethod:(NKHTTPMethod)method
                          path:(NSString*)path
                 authenticated:(BOOL)authenticated
                        params:(NSDictionary*)params
                    completion:(RequestCompletionHandler)completion;

#pragma mark - Playback
/**
 Creates radio player that enables playback of radio stations.
 */
-(NKRequest*)createStationPlayerFor:(NSString*)identifier
                            complete:(StationPlayerCompletion)complete;

/**
 Returns player instance.
 */
@property (nonatomic, strong, readonly) NKTrackPlayer        *player;

#pragma mark - Notifications

@property (nonatomic, strong, readonly) NSNotificationCenter  *notificationCenter;

/**
 Posted when the current track failed. Check userInfo's NKNotificationErrorKey for the cause.
 */
extern NSString* const NKNotificationCurrentTrackFailed;

/**
 Posted when the upcoming track failed. Check userInfo's NKNotificationErrorKey for the cause.
 */
extern NSString* const NKNotificationUpcomingTrackFailed;

/**
 Posted at the start of each network request.
 */
extern NSString* const NKNotificationNetworkRequestBegan;

/**
 Posted at the end of each network request.
 */
extern NSString* const NKNotificationNetworkRequestEnded;

/**
 Posted when session changes.
 */
extern NSString* const NKNotificationSessionChanged;

/**
 Key of old session in user info for `NKNotificationSessionChanged` notification
 */
extern NSString* const NKNotificationSessionChangedFormerSessionKey;

#pragma mark - Notification user info keys

extern NSString* const NKNotificationErrorKey;

#pragma mark - Errors

extern NSString* const NKErrorDomain;

typedef NS_ENUM(NSInteger, NKErrorCode) {
    NKErrorUnknown = 0,
    
    NKErrorCanceled,
    
    NKErrorAuthenticationError,
    
    NKErrorAuthorizationError,
    
    NKErrorResourceNotFound,
    
    NKErrorConnectionFailed,
    
    NKErrorPlaybackSessionInvalid,

};

@end
