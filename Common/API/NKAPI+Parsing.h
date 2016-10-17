//
//  NKAPI+Parsing.h
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import "NKPlaylistStub.h"
#import "NKPlaylistDetail.h"

@class NKAlbumStub;
@class NKArtistStub;
@class NKPlaylistDetail;
@class NKPlaylistStub;

@interface NKPlaylistDetail (Parsing)

+ (id)withPayload:(NSDictionary*)payload;

@end

@interface NKPlaylistStub (Parsing)

+ (id)withPayload:(NSDictionary*)payload;

@end