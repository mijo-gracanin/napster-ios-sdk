//
//  NKArtistStub.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NKArtistStub : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *ID;

@property (nonatomic, copy, readonly) NSString *name;

-(instancetype)initWithID:(NSString*)ID
                     name:(NSString*)name;

@end
