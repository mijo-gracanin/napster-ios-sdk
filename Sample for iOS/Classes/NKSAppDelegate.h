//
//  NKSAppDelegate.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

extern NSString* const NKSFavoritesPlaylistName;

@interface NKSAppDelegate : UIResponder <UIApplicationDelegate>

+ (NKSAppDelegate*)appDelegate;

+ (NSURL*) authorizationURL;

@property (nonatomic) UIWindow* window;

@end
