//
//  NKPlaylistStub.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKPlaylistStub_Private.h"

@implementation NKPlaylistStub

@end

@implementation NKPlaylistStub (Parsing)

+ (id)withPayload:(NSDictionary*)payload {
    if (!payload) return nil;
    
    NKPlaylistStub* playlist = [self new];
    
    [playlist setIdentifier:payload[@"id"]];
    [playlist setName:payload[@"name"]];
    [playlist setAuthor:payload[@"author"]];
    [playlist setCreatedAt:[NSDate dateWithTimeIntervalSince1970:[payload[@"created"] doubleValue] / 1000.0]];
    
    return playlist;
}

@end
