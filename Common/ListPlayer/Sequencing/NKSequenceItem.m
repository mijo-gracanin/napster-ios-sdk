//
//  NKSequenceItem.m
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import "NKSequenceItem.h"

@interface NKSequenceItem()

@property (nonatomic, strong)     NKTrack *track;

@end

@implementation NKSequenceItem

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@\n%@", super.description, @{
        @"track" : ((id)self.track ?: [NSNull null])
    }.description];
}

+(NKSequenceItem*)sequenceItemWithTrack:(NKTrack*)track {
    NKSequenceItem *item = [[self alloc] init];
    item.track = track;
    
    return item;
}

@end
