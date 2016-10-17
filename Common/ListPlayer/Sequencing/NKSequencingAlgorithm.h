//
//  NKSequencingAlgorithm.h
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKTrackListPlayer.h"

@class NKSequenceItem;
@class NKSequencingContext;
@class NKListPlayerTracksChangedResult;

@protocol NKSequencingAlgorithm <NSObject>

-(instancetype)initWithTrackListPlayer:(NKTrackListPlayer*)trackListPlayer;

@property (nonatomic, readonly) NKSequencingContext *currentSequencingContext;

#pragma mark - Callbacks and Properties that could change sequencing info

-(void)currentItemChangedFrom:(NKSequenceItem*)fromItem;

-(NKSequenceItem*)sequencingItemAfterUpdateToTracks:(NSArray*)nextTracks
                                     andCurrentItem:(NKSequenceItem*)sequencingItem;

-(void)tracksUpdatedFrom:(NSArray*)fromTracks;

-(void)sequencingModeChanged;

@end
