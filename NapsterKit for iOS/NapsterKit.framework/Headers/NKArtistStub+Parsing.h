//
//  NKArtistStub+Parsing.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <NapsterKit/NapsterKit.h>
#import "NKArtistStub.h"

@interface NKArtistStub (Parsing)

+(instancetype)parseFromJson:(id)json;

-(BOOL)validate:(NSError**)error;

@end

