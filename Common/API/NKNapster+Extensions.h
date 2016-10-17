//
//  NKNapster+Extensions.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <NapsterKit/NapsterKit.h>
#import "NKPlaylistDetail.h"
#import "NKPlaylistStub.h"

@interface NKNapster (Extensions)

/**
 Gets the user's favorites. An accessToken must have already been set.
 @param completion A block called when the request has finished. If the request succeeded, an array of NKTrack objects is given.
 @return A request object that you may cancel (by calling [request cancel]) while the request is queuing or in progress.
 */
- (NKRequest*)rs_favoritesInLibrary:(void(^)(NSArray* tracks, NSError* error))completion;


/**
 Adds a track to user's favorites. An accessToken must have already been set.
 @param trackID The ID for the track to be added.
 @param completion A block called when the request has finished. If the request succeeded, 'error' will be nil.
 @return A request object that you may cancel (by calling [request cancel]) while the request is queuing or in progress.
 */
- (NKRequest*)rs_addToFavoritesWithTrackID:(NSString*)trackID completion:(void(^)(NSError* error))completion;

@end
