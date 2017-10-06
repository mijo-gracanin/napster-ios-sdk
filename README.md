# Napster iOS SDK

## Introduction

The Napster iOS SDK was designed to provide a very easy way to integrate streaming music into your iOS application. The SDK itself handles playback and is used in conjunction with the [Napster Developer API](http://developer.napster.com) to give your users access to over 18 million tracks. The SDK plays full-length tracks for authenticated Napster subscribers and 30-second samples for everyone else.

## Requirements

NapsterKit requires iOS 9.3 or later.

## Documentation

Documented header files can be found within the framework.

## Start Rocking

1. If you have yet to do so, [Register your application](http://developer.napster.com) to acquire an OAuth consumer key.
2. [Download the Napster iOS SDK](https://github.com/Napster/napster-ios-sdk/archive/master.zip) and unzip.

## Installation

1. Drag `NapsterKit.framework` and `NapsterKit.bundle` into your project Xcode project
2. Open project settings for a target and in General tab add NapsterKit.framework to "Embeded Binaries" and "Linked Frameworks and Libraries"
3. Open Build Phases tab and add NapsterKit.bundle to "Copy Bundle Resources" phase
4. Add `#import <NapsterKit/NapsterKit.h>` in your target's `Prefix.pch` (or other project-wide common header)
5. Add `-ObjC` to Other Linker Flags for your target
6. Add `AudioToolbox.framework`, `CoreData.framework`, `SystemConfiguration.framework`, `CoreGraphics.framework` and `AVFoundation.framework` to your target's "Linked Frameworks and Libraries"

## Setting Your App’s OAuth Consumer Key

A valid OAuth consumer key and secret are required to run the SDK. If you do not have a consumer key, you can [register your application](http://developer.napster.com) to get one. Using that parameters, you need to instantate Napster engine object:

    [NKNapster napsterWithConsumerKey:@"YOUR_CONSUMER_KEY"
                         consumerSecret:@"YOUR_CONSUMER_SECRET"];

By default settings, Napster engine object will cache logged user credentials to NSUserDefaults, so in case engine is destroyed, session state will be persisted. In case you want some different session behavior, you can use the following method to create the engine.

        +(NKNapster*)napsterWithConsumerKey:(NSString*)consumerKey
                                consumerSecret:(NSString*)consumerSecret
                          sessionCachingPolicy:(NKSessionCachingPolicy*)sessionCachingPolicy;

## Setting a User’s OAuth Access Token

A valid OAuth token is required for any user-authenticated requests.  This includes accessing a user’s library and playlists via the Napster Developer API. It is also required for the SDK to play full-length tracks. If a token is not set, the SDK will only play 30-second samples. By setting the OAuth token, you are opening a new authentication session, and this is how to do it:

    NKNapster *napster = // ... instantate napster object
    NKOAuthToken *token = [NKOAuthToken authTokenWithAccessToken:@"USER_ACCESS_TOKEN"
                                                      refreshToken:@"USER_REFRESH_TOKEN"
                                                    expirationDate:[NSDate ...]];

    [napster openSession:token];

For information on how to authenticate a user and acquire an access token, see the Napster Developer Portal’s [authentication documentation](http://developer.napster.com/docs#authentication) or the included iOS sample app and its counterpart web server for code samples.

## Configuring an Audio Session

It is your responsibility to initialize, configure, activate and deactivate your audio session as well as handle audio interruptions and audio route changes. A simple audio session can be configured in the following manner:

    NSError* sessionActivationError = nil;
    BOOL activatedSession = [[AVAudioSession sharedInstance] setActive:YES error:&sessionActivationError];
    if (!activatedSession) {
        NSLog(@"Failed to activate audio session: %@", sessionActivationError);
        // Handle error.
    }

    NSError* sessionCategorizationError = nil;
    BOOL categorizedSession = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionCategorizationError];
    if (!categorizedSession) {
        NSLog(@"Failed to set audio session category: %@", sessionCategorizationError);
        // Handle error.
    }

See the sample app for more audio session example code.

## Notifications

The Napster iOS SDK posts notifications to alert your app to track changes, playback errors, state changes, etc. To view all SDK notifications, please view the SDK header file. You can observe notifications in the following manner:

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentTrackFailed:)
                                                 name:NKNotificationCurrentTrackFailed
                                               object:nil];

Check the notification’s userInfo dictionary to handle errors:

    - (void)currentTrackFailed:(NSNotification*)notification
    {
        NSError* error = [[notification userInfo] objectForKey:NKNotificationErrorKey];

        switch ((NKErrorCode)[error code]) {
            case NKErrorAccessTokenExpired:
                // Refresh access token.
                break;
            // Handle other kinds of errors.
            ...
            default:
                break;
        }
    }

## Sample App

To run the apps, open `Samples.xcworkspace` file, choose the wanted target and hit `Run`.
