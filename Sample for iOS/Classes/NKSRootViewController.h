//
//  NKSRootViewController.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@class NKNapster;

@interface NKSRootViewController : UIViewController

@property (nonatomic, strong, readonly) NKNapster *napster;

-(instancetype)initWithNapster:(NKNapster*)napster andNibNamed:(NSString*)nibName;

#pragma mark - Authentication

- (void)promptWithMemberBenefits;
- (void)promptWithSignInOptions;
- (void)signIn;
- (void)signOut;

#pragma mark - Lock Screen Events

- (void)playNextTrack;
- (void)playPreviousTrack;

@end
