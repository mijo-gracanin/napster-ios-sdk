//
//  NKSRootViewController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSRootViewController.h"
#import "NKSAppDelegate.h"

typedef enum : NSInteger {
    NKSRootViewControllerAlertViewAccessTokenFailure = 1,
    NKSRootViewControllerAlertViewMemberBenefits,
    NKSRootViewControllerAlertViewSignInOptions,
} NKSRootViewControllerAlertView;

@interface NKSRootViewController ()

@property (nonatomic, strong) NKNapster *napster;

@property (assign, nonatomic) BOOL alreadyPromptedWithMemberBenefits;

@end

@implementation NKSRootViewController

-(instancetype)initWithNapster:(NKNapster*)napster andNibNamed:(NSString*)nibName {
    self = [super initWithNibName:nibName bundle:nil];
    if (!self) return nil;
    
    self.napster = napster;

    [self.napster.notificationCenter addObserver:self
                                         selector:@selector(sessionDidChange:)
                                             name:NKNotificationSessionChanged
                                           object:nil];

    [self.napster.notificationCenter addObserver:self
                                         selector:@selector(currentTrackFailed:)
                                             name:NKNotificationCurrentTrackFailed
                                           object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureForAuthenticationState];
}

-(void)dealloc {
    [self.napster.notificationCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureForAuthenticationState
{
    UIBarButtonItem* buttonItem = nil;
    if (self.napster.isSessionOpen) {
        buttonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign Out", nil) style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    } else {
        buttonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign In", nil) style:UIBarButtonItemStylePlain target:self action:@selector(promptWithSignInOptions)];
    }
    [[self navigationItem] setRightBarButtonItem:buttonItem];
}

#pragma mark - Authentication

- (void)promptWithMemberBenefits
{
    if (self.napster.isSessionOpen) return;
    
    if ([self alreadyPromptedWithMemberBenefits]) return;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Playing Samples", nil) message:NSLocalizedString(@"To play full-length tracks, sign in with your Napster account or download the Napster app to sign up.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"Sign In", nil), nil];
    [alertView setTag:NKSRootViewControllerAlertViewMemberBenefits];
    [alertView show];
    
    [self setAlreadyPromptedWithMemberBenefits:YES];
}

- (void)promptWithSignInOptions
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Sign in with your Napster account to play full-length tracks. Or download the Napster app to sign up.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"Sign In", nil), nil];
    [alertView setTag:NKSRootViewControllerAlertViewSignInOptions];
    [alertView show];
    
    [self setAlreadyPromptedWithMemberBenefits:YES];
}


- (void)signIn
{
    NSURL *authorizationUrl = [NKSAppDelegate authorizationURL];
    NSString* address = [NKNapster loginUrlWithConsumerKey:self.napster.consumerKey
                                                redirectUrl:authorizationUrl];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
}

- (void)signOut
{
    [self.napster closeSession];
}

- (void)currentTrackFailed:(NSNotification*)notification
{
    NSError* error = [[notification userInfo] objectForKey:NKNotificationErrorKey];
    
    switch ((NKErrorCode)[error code]) {
        case NKErrorAuthenticationError: {
            [self.napster closeSession];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Signed Out", nil) message:NSLocalizedString(@"Please sign in again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:NSLocalizedString(@"Sign In", nil), nil];
            [alertView setTag:NKSRootViewControllerAlertViewAccessTokenFailure];
            [alertView show];
            return;
        }
        case NKErrorPlaybackSessionInvalid: {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:NSLocalizedString(@"Playback session is invalid. Maybe your account can stream only from one device at a time.", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
            [alertView setTag:NKSRootViewControllerAlertViewAccessTokenFailure];
            [alertView show];
            return;
        }
        // Handle other kinds of errors.
        default:
            break;
    }
    
    NSString *errorDescription = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    
    if (!errorDescription) {
        errorDescription = NSLocalizedString(@"The track failed to play.", nil);
    }
    
    // Generic placeholder error alert.
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}


#pragma mark - Notifications

- (void)sessionDidChange:(NSNotification*)notification
{
    [self configureForAuthenticationState];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ((NKSRootViewControllerAlertView)[alertView tag]) {
        case NKSRootViewControllerAlertViewAccessTokenFailure: {
            if (buttonIndex == [alertView cancelButtonIndex]) return;
            [self signIn];
            return;
        }
        case NKSRootViewControllerAlertViewMemberBenefits: {
            if (buttonIndex == [alertView cancelButtonIndex]) return;
            if (buttonIndex == [alertView firstOtherButtonIndex]) {
                [self signIn];
                return;
            }
            return;
        }
        case NKSRootViewControllerAlertViewSignInOptions: {
            if (buttonIndex == [alertView cancelButtonIndex]) return;
            if (buttonIndex == [alertView firstOtherButtonIndex]) {
                [self signIn];
                return;
            }
            return;
        }
    }
}

#pragma mark - Lock Screen Events

- (void)playNextTrack {
    
}

- (void)playPreviousTrack {
    
}

@end
