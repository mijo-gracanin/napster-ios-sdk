//
//  NKPlaylistDetail.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NKPlaylistDetail : NSObject

@property (nonatomic, readonly) NSString* identifier;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* author;
@property (nonatomic, readonly) NSDate* createdAt;
@property (nonatomic, readonly) NSArray* tracks;

@end
