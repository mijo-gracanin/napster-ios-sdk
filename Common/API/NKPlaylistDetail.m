//
//  NKPlaylistDetail.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKPlaylistDetail_Private.h"
#import "NKAPI+Parsing.h"
#import "NSArray+NKExtensions.h"

@implementation NKPlaylistDetail

@end

@implementation NKPlaylistDetail (Parsing)

+ (id)withPayload:(NSDictionary*)payload
{
    if (!payload) return nil;
    
    NKPlaylistDetail* playlist = [self new];
    
    [playlist setIdentifier:payload[@"id"]];
    [playlist setName:payload[@"name"]];
    [playlist setAuthor:payload[@"author"]];
    [playlist setCreatedAt:[NSDate dateWithTimeIntervalSince1970:[payload[@"created"] doubleValue] / 1000.0]];
    [playlist setTracks:[payload[@"tracks"] rk_map:^id(id value) {
        return [NKTrack parseFromJson:value error:nil];
    }]];
    
    return playlist;
}

@end
