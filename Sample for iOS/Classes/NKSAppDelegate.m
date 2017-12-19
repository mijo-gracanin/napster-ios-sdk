//
//  NKSAppDelegate.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSNetworkActivityIndicatorController.h"
#import "NKSAppDelegate.h"

#if         TRACK_PLAYBACK_SAMPLE
#   import "NKTrackListPlayer.h"
#   import "NKSTrackPlaybackRootViewController.h"
#elif    STATION_PLAYBACK_SAMPLE
#   import "NKSStationRootViewController.h"
#endif

#   define CONSUMER_KEY     @"ADD_API_KEY_HERE"
#   define CONSUMER_SECRET  @"ADD_API_SECRET_HERE"

#if TRACK_PLAYBACK_SAMPLE
#   define BASE_URL         @"sample1://authorize"
#elif STATION_PLAYBACK_SAMPLE
#   define BASE_URL         @"sample2://authorize"
#endif

NSString* const NKSFavoritesPlaylistName = @"Sample App Favorites";

@interface NKSAppDelegate () <AVAudioSessionDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) BOOL shouldResumePlaybackAtInterruptionEnd;

@property (nonatomic, readonly) NKTrackPlayer  *player;

@property (nonatomic, strong  ) NKNapster     *napster;

@property (nonatomic, strong)   NKSRootViewController *rootViewController;

@end

@implementation NKSAppDelegate

static NSString* const kKeychainServiceName = @"com.napster.sample";
static NSString* const kKeychainTokenKey = @"token";

#pragma mark - Properties

- (NKTrackPlayer*)player {
    return self.napster.player;
}

+ (NSURL*)authorizationURL {
    return [NSURL URLWithString:BASE_URL];
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSString* consumerKey = CONSUMER_KEY;
    NSString* consumerSecret = CONSUMER_SECRET;

    NKNapster *napster = [NKNapster napsterWithConsumerKey:consumerKey
                                                  consumerSecret:consumerSecret
                                            sessionCachingPolicy:NKSessionCachingPolicy.defaultPolicy
                                              notificationCenter:[NSNotificationCenter defaultCenter]
                            ];
    
    self.napster = napster;
    
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    
    UINavigationBar* navBarAppearance = [UINavigationBar appearance];
    [navBarAppearance setBarStyle:UIBarStyleBlackOpaque];
    
    NKSRootViewController *rootViewController = nil;

#if         TRACK_PLAYBACK_SAMPLE
    rootViewController = [[NKSTrackPlaybackRootViewController alloc] initWithNapster:self.napster];
#elif       STATION_PLAYBACK_SAMPLE
    rootViewController = [[NKSStationRootViewController alloc] initWithNapster:self.napster];
#endif

    self.rootViewController = rootViewController;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = navController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:NKNotificationPlaybackStateChanged object:nil];
    
    [[self window] makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [self refreshAccessToken];
}


- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    NSLog(@"Received URL: %@", url);
    
    if (![[url scheme] hasPrefix:@"sample"]) return NO;
    
    if ([[url host] isEqual:@"authorization-canceled"]) return YES;

    void (^showErrorLoggingIn)(void) = ^() {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign In Failed", nil) message:NSLocalizedString(@"The sign in request failed.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
    };
    
    
    if ([[url host] isEqual:@"authorize"]) {
        NSDictionary* params = [NSDictionary rs_dictionaryWithQuery:[url query]];
        
        [self handleAuthenticationResponse:params onError:showErrorLoggingIn];
        
        return YES;
    }
    
    if ([[url host] isEqual:@"authorization-failed"]) {
        showErrorLoggingIn();
        return YES;
    }
    
    return NO;
}

#pragma mark - Audio session delegate

- (void)beginInterruption
{
    NSLog(@"Audio session interruption began.");
    switch (self.player.playbackState) {
        case NKPlaybackStateStopped:
        case NKPlaybackStateFinished:
        case NKPlaybackStatePaused:
            return;
        case NKPlaybackStateBuffering:
        case NKPlaybackStatePlaying:
            [self setShouldResumePlaybackAtInterruptionEnd:YES];
            [self.player pausePlayback];
            return;
    }
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    NSLog(@"Audio session interruption ended.");
    if (![self shouldResumePlaybackAtInterruptionEnd]) return;
    [self setShouldResumePlaybackAtInterruptionEnd:NO];
    if (flags != AVAudioSessionInterruptionOptionShouldResume) return;
    [self.player resumePlayback];
}

#pragma mark - Audio route change

- (void) audioRouteChangeListenerCallback:(NSNotification*)notification
{
    // Pause when switching to the internal speaker, i.e. unplugging headphones.
    @autoreleasepool {
        NSUInteger reason = [[notification userInfo][AVAudioSessionRouteChangeReasonKey] integerValue];
        if (reason != AVAudioSessionRouteChangeReasonOldDeviceUnavailable) return;
        
        AVAudioSessionRouteDescription* currentRoute = [[AVAudioSession sharedInstance] currentRoute];
        
        NSArray* outputs = [currentRoute outputs];
        
        for (AVAudioSessionPortDescription* output in outputs) {
            NSString* portType = [output portType];
            
            if ([portType isEqualToString: AVAudioSessionPortBuiltInSpeaker]) {
                continue;
            }
            
            switch (self.player.playbackState) {
                case NKPlaybackStateStopped:
                case NKPlaybackStateFinished:
                case NKPlaybackStatePaused:
                    return;
                case NKPlaybackStateBuffering:
                case NKPlaybackStatePlaying:
                    NSLog(@"Pausing playback because of switch to internal speaker.");
                    [self.player pausePlayback];
                    return;
            }

        }
    }
}

#pragma mark - Remote control

- (void)remoteControlReceivedWithEvent:(UIEvent*)event
{
    switch ([event subtype]) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            switch (self.player.playbackState) {
                case NKPlaybackStateStopped:
                case NKPlaybackStateFinished:
                    break;
                case NKPlaybackStatePaused:
                    [self.player resumePlayback];
                    break;
                case NKPlaybackStatePlaying:
                case NKPlaybackStateBuffering:
                    [self.napster.player pausePlayback];
                    break;
            }
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self.rootViewController playNextTrack];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self.rootViewController playPreviousTrack];
            break;
        default:
            break;
    }
}

#pragma mark - Notification handlers

- (void)playbackStateChanged:(NSNotification*)notification
{
    switch ([self.player playbackState]) {
        case NKPlaybackStateBuffering:
        case NKPlaybackStatePaused:
        case NKPlaybackStateFinished:
            return;
        case NKPlaybackStatePlaying: {
            NSError* sessionActivationError = nil;
            BOOL activatedSession = [[AVAudioSession sharedInstance] setActive:YES error:&sessionActivationError];
            if (!activatedSession) {
                NSLog(@"Failed to activate audio session: %@", sessionActivationError);
                return;
            }
            
            NSError* sessionCategorizationError = nil;
            BOOL categorizedSession = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionCategorizationError];
            if (!categorizedSession) {
                NSLog(@"Failed to set audio session category: %@", sessionCategorizationError);
                return;
            }
            
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(audioRouteChangeListenerCallback:)
                                                         name:AVAudioSessionRouteChangeNotification
                                                       object: [AVAudioSession sharedInstance]];
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            return;
        }
        case NKPlaybackStateStopped: {
            [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
            
            
            [[AVAudioSession sharedInstance] setActive:NO error:NULL];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:NULL];
            [[NSNotificationCenter defaultCenter] removeObserver: self name: AVAudioSessionRouteChangeNotification object: [AVAudioSession sharedInstance]];
            return;
        }
    }
}

#pragma mark - Authentication

- (void)refreshAccessToken
{
    if (self.napster.isSessionOpen) {
        [self.napster refreshSessionWithCompletionHandler:^(NKSession *session, NSError *error) {
            if (!session) {
                // ... some error happened
            }
        }];
    }
}

#pragma mark - Helpers

+ (NKSAppDelegate*)appDelegate
{
    return (NKSAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (NSString*)stringByEscapingURLQueryComponent:(NSString*)key
{
    NSString *result = key;
    
    CFStringRef originalAsCFString = (__bridge CFStringRef) key;
    CFStringRef leaveAlone = CFSTR(" ");
    CFStringRef toEscape = CFSTR("\n\r\"?[]()$,!'*;:@&=#%+/");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalAsCFString, leaveAlone, toEscape, kCFStringEncodingUTF8);
    
    if (escapedStr) {
        NSMutableString *mutable = [NSMutableString stringWithString:(__bridge_transfer NSString *) escapedStr];
        
        [mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
        result = mutable;
    }
    return result;  
}

#pragma mark Authentication

- (void)handleAuthenticationResponse:(NSDictionary*)response onError:(void(^)(void))onError {
    NSString *code = [response objectForKey:@"code"];
 
    [self.napster openSessionWithOAuthCode:code
                                    baseURL:[NSURL URLWithString:BASE_URL]
                          completionHandler:^(NKSession *session, NSError *error) {
        if (!session) {
            onError();
            return;
        }
       
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Signed In", nil) message:NSLocalizedString(@"You have successfully signed in.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alertView show];
    }];
}

@end
