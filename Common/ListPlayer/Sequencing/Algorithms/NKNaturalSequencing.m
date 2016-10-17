//
//  NKNaturalSequencing.m
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import "NKNaturalSequencing.h"
#import "NKSequenceItem.h"
#import "NKSequencingContext.h"

#import "NKTrackListPlayer_Private.h"
#import "NSArray+NKExtensions.h"

// limits the index to interval from [0, max>
#define RANGE(index, max) ((index) < 0) \
    ? (index) + (max)\
    :   (\
            (index) >= (max) \
                ? (index) - (max)\
                : (index) \
        )

@interface NKNaturalSequencing()

@property (nonatomic, weak)     NKTrackListPlayer *trackListPlayer;

@end

@implementation NKNaturalSequencing

-(instancetype)initWithTrackListPlayer:(NKTrackListPlayer*)trackListPlayer {
    self = [super init];
    if (!self) return nil;
    
    self.trackListPlayer = trackListPlayer;
    
    return self;
}

#pragma mark - Public methods

-(NSArray*)tracksWithRange:(NSInteger)from to:(NSInteger)to {
    NSMutableArray *returnArray = [NSMutableArray array];
    NSArray *tracks = self.trackListPlayer.tracks;
    
    for ( ; from != to; from < to ? from++ : from--) {
        NSInteger index = RANGE(from, tracks.count);
        [returnArray addObject:tracks[index]];
    }
    
    return returnArray;
}

-(NKSequencingContext*)currentSequencingContext {
    NSUInteger currentIndex = NSNotFound;
    
    if (self.trackListPlayer.currentTrack == nil) {
        return [NKSequencingContext sequencingContextWithPreviousItems:@[] currrentItem:nil nextItems:@[]];
    }
    
    NKSequenceItem *currentItem = self.trackListPlayer.currentSequenceItem;
    currentIndex = [self.trackListPlayer.tracks indexOfObject:currentItem.track];
    
    if (currentIndex == NSNotFound) {
        return [NKSequencingContext sequencingContextWithPreviousItems:@[] currrentItem:nil nextItems:@[]];
    }

    NSArray *tracks = self.trackListPlayer.tracks;
    
    // next items
    NSArray *nextItems = nil;
    {
        NSInteger nextTracksStartIndex = currentIndex + 1;
        NSInteger nextLimit = nextTracksStartIndex + self.trackListPlayer.sequencingContextSize;
        
        if (self.trackListPlayer.repeatMode != NKRepeatModeAllTracks) {
            nextLimit = MIN(nextLimit, tracks.count);
        }
        
        NSArray *tracks = [self tracksWithRange:nextTracksStartIndex to:nextLimit];
        
        nextItems = [tracks rk_map:^id(NKTrack *nextTrack) {
            return [NKSequenceItem sequenceItemWithTrack:nextTrack];
        }];
    }
 
    
    // previous items
    NSArray *previousItems = nil;
    {
        NSInteger previousTracksStartIndex = currentIndex - 1;
        NSInteger previousLimit = previousTracksStartIndex - self.trackListPlayer.sequencingContextSize;
        
        if (self.trackListPlayer.repeatMode != NKRepeatModeAllTracks) {
            previousLimit = MAX(previousLimit, -1);
        }
        
        NSArray *tracks = [self tracksWithRange:previousTracksStartIndex to:previousLimit];
        
        previousItems = [tracks rk_map:^id(NKTrack *nextTrack) {
            return [NKSequenceItem sequenceItemWithTrack:nextTrack];
        }];
    }
    
    return [NKSequencingContext sequencingContextWithPreviousItems:previousItems
                                                      currrentItem:self.trackListPlayer.currentSequenceItem
                                                         nextItems:nextItems];
}

-(void)currentItemChangedFrom:(NKSequenceItem*)fromItem {
    
}

-(void)tracksUpdatedFrom:(NSArray*)fromTracks {
    
}

-(NKSequenceItem*)sequencingItemAfterUpdateToTracks:(NSArray*)nextTracks
                                     andCurrentItem:(NKSequenceItem*)sequencingItem {
    if (sequencingItem == nil || sequencingItem.track == nil) {
        return sequencingItem;
    }
    
    if ([nextTracks containsObject:sequencingItem.track]) {
        return sequencingItem;
    }

    NSArray *currentTracks = self.trackListPlayer.tracks;
    
    NSInteger index = [currentTracks indexOfObject:sequencingItem.track];
        
    NSAssert(index != NSNotFound, @"Track was not member of previous tracks");
    
    if (nextTracks.count == 0) {
        return nil;
    }
    
    NSInteger resultIndex = MIN(index, nextTracks.count - 1);
    
    if (resultIndex < 0) {
        return nil;
    }
    
    return [NKSequenceItem sequenceItemWithTrack:nextTracks[resultIndex]];
}

-(void)sequencingModeChanged {
    
}


@end
