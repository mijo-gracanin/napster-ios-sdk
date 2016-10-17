//
//  NKSFavoritesViewController.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@class NKTrackListPlayer;
@class NKNapster;

typedef void (^NKSFavoritesViewControllerSelectedListPlayer)(NKTrackListPlayer *trackListPlayer);

@interface NKSFavoritesViewController : UIViewController

- (id)initWithNapster:(NKNapster*)napster selectedTrackListPlayer:(NKSFavoritesViewControllerSelectedListPlayer)trackListPlayer;

@end
