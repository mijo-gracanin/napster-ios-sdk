//
//  NKSequenceItem.h
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NKPlayableTrack;

@interface NKSequenceItem : NSObject<NSCopying>

@property (nonatomic, strong, readonly)     NKTrack *track;

+(NKSequenceItem*)sequenceItemWithTrack:(NKTrack*)track;

@end
