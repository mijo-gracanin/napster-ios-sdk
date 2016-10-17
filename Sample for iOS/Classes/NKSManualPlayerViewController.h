//
//  NKSManualPlayerViewController.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@class NKTrackListPlayer;

@interface NKSManualPlayerViewController : UIViewController

- (id)initWithTrackListPlayer:(NKTrackListPlayer *)trackListPlayer;

- (void)setTrackListPlayer:(NKTrackListPlayer *)trackListPlayer;

@end
