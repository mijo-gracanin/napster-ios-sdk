//
//  NKStation+Parsing.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <NapsterKit/NapsterKit.h>
#import "NKStation.h"

@interface NKStation (Parsing)

+(instancetype)parseFromJson:(id)json;

+(NSArray*)parseStationsFromJson:(NSArray*)jsonArray;

-(BOOL)validate:(NSError**)error;

@end
