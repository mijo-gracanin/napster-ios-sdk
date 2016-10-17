//
//  NKPreviewTrack.h
//  NapsterKit
//
//  Created by Krunoslav Zaher on 12/8/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NKTrack;
@class NKArtistStub;

/**
 *  Next track in station playback queue.
 */
@interface NKPreviewTrack : NSObject

/**
 *  Track description. This value can be `nil` depending on station type
 *  and user account.
 */
@property (nonatomic, strong, readonly) NKTrack          *track;

/**
 *  Artist description. This property should always contain value.
 */
@property (nonatomic, strong, readonly) NKArtistStub     *artist;

-(instancetype)initWithTrack:(NKTrack*)track
                      artist:(NKArtistStub*)artist;

@end
