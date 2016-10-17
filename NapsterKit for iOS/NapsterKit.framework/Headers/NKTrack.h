//
//  NKTrack.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@class NKAlbumStub;
@class NKArtistStub;

@interface NKTrack : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString      *ID;

@property (nonatomic, copy, readonly) NSString      *name;

@property (nonatomic, copy, readonly) NSURL         *sampleURL;

@property (nonatomic, copy, readonly) NSNumber      *duration;

@property (nonatomic, copy, readonly) NKArtistStub  *artist;

@property (nonatomic, copy, readonly) NKAlbumStub   *album;

@property (nonatomic, copy, readonly) NSArray        *supportedAudioFormats;

-(instancetype)initWithID:(NSString*)ID
                     name:(NSString*)name
                sampleURL:(NSURL*)sampleURL
                 duration:(NSNumber*)duration
                   artist:(NKArtistStub*)artist
                    album:(NKAlbumStub*)album
         supportedAudioFormats:(NSArray*)supportedAudioFormats;

@end
