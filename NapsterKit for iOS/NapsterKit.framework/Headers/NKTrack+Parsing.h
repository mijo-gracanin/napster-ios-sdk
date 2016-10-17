//
//  NKTrack+Parsing.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKTrack.h"

@interface NKTrack (Parsing)

+(instancetype)parseFromJson:(id)json;

-(BOOL)validate:(NSError**)error;

@end
