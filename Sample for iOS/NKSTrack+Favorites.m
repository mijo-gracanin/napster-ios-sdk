//
//  NKSTrack+Favorites.m
//  Track Playback Sample
//
//  Created by Emanuel Kotzayan on 9/7/16.
//  Copyright © 2016 Napster International. All rights reserved.
//

#import "NKSTrack+Favorites.h"
#import "NapsterKit/NKAudioFormat+Parsing.h"

@implementation NKTrack (Favorites)

+(instancetype)parseFromFavoriteJson:(NSDictionary*)json {
    if (![json isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSString *albumID = [json objectForKey:@"albumId"];
    NSString *albumName = [json objectForKey:@"albumName"];
    
    NSMutableDictionary* albumJson = [NSMutableDictionary new];
    
    if (albumID) {
        albumJson[@"id"] = albumID;
    }
    
    if (albumName) {
        albumJson[@"name"] = albumName;
    }
    
    NSString *artistID = [[json objectForKey:@"contributors"] objectForKey: @"primaryArtist"];
    NSString *artistName = [json objectForKey:@"artistName"];
    
    NSMutableDictionary* artistJson = [NSMutableDictionary new];
    
    if (artistID) {
        artistJson[@"id"] = artistID;
    }
    
    if (artistName) {
        artistJson[@"name"] = artistName;
    }
    
    NSString *sampleUrlString = [json objectForKey:@"previewURL"];
    NSURL *sampleURL = [NSURL URLWithString:sampleUrlString];
    
    NSNumber *duration = [json objectForKey:@"playbackSeconds"];
    
    NSArray *formats = [json objectForKey:@"formats"];
    NSMutableArray *supportedFormats = [NSMutableArray new];
    for (NSDictionary *format in formats) {
        [supportedFormats addObject: [NKAudioFormat parseFromJson: format]];
    }
    
    NKTrack *object = [[self alloc] initWithID:[json objectForKey:@"id"]
                                          name:[json objectForKey:@"name"]
                                     sampleURL:sampleURL
                                      duration:duration
                                        artist:[NKArtistStub parseFromJson: artistJson]
                                         album:[NKAlbumStub parseFromJson: albumJson]   
                         supportedAudioFormats:supportedFormats];
    
    if (![object validate:nil]) {
        return nil;
    }
    
    return object;
}

@end
