//
//  NKNapster+Extensions.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKNapster+Extensions.h"
#import "NSArray+NKExtensions.h"
#import "NKPlaylistStub_Private.h"
#import "NKPlaylistDetail_Private.h"
#import "NKAPI+Parsing.h"
#import "NKSTrack+Favorites.h"

@implementation NKNapster (API)

static NKNapster* _shared = nil;

+ (NKNapster*)sharedInstance
{
    return _shared;
}

+ (void)setSharedInstance:(NKNapster*)sharedInstance {
    _shared = sharedInstance;
}

- (NKRequest*)rs_favoritesInLibrary:(void(^)(NSArray* tracks, NSError* error))completion
{
    return [self requestForMethod:NKHTTPMethodGET path:@"me/favorites" authenticated:YES params:@{@"filter":@"track", @"limit":@20, @"include":@"tracks"} completion:^(id result, NSError* error) {
        if (!completion) return;
        
        NSArray* favoriteList = [result objectForKey: @"favorites"];
        
        NSArray* favorites = [favoriteList rk_map:^id(id value) {
            NSDictionary* favoriteDict = [[[value objectForKey: @"linked"] objectForKey: @"tracks"] firstObject];
            
            return [NKTrack parseFromFavoriteJson: favoriteDict];
        }];
        completion(favorites, error);
    }];
}

- (NKRequest*)rs_addToFavoritesWithTrackID:(NSString*)trackID completion:(void(^)(NSError* error))completion
{
    return [self requestForMethod:NKHTTPMethodPOST path:@"me/favorites" authenticated:YES params:@{ @"favorites": @[ @{@"id": trackID} ] } completion:^(id result, NSError* error) {
        if (!completion) return;
        completion(error);
    }];
}

@end
