//
//  NKShuffledSequencing.m
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import "NKShuffledSequencing.h"
#import "NKSequencingContext.h"
#import "NKSequenceItem.h"
#import "NSArray+NKExtensions.h"

#import "NKTrackListPlayer_Private.h"

#define DONT_CHOOSE_LAST_TRACKS_FACTOR      0.6
#define NUMBER_OF_TRACKS_TO_TRACK(COUNT, SEQ_CONTEXT_SIZE)    (2 * (COUNT) + (SEQ_CONTEXT_SIZE) * 2 + 1)

@interface NKShuffledSequencing()

@property (nonatomic, weak)     NKTrackListPlayer   *trackListPlayer;

#pragma mark - State

@property (nonatomic, strong)   NSMutableArray      *listeningHistory;

@end

@implementation NKShuffledSequencing

-(instancetype)initWithTrackListPlayer:(NKTrackListPlayer *)trackListPlayer {
    self = [super init];
    if (!self) return nil;
    
    self.trackListPlayer = trackListPlayer;
    self.listeningHistory = [NSMutableArray array];
    
    return self;
}

#pragma mark - Private methods

-(NSUInteger)itemIndex:(NKSequenceItem*)item {
    NSUInteger index = NSNotFound;
    
    if (item) {
        index = [self.listeningHistory indexOfObject:item];
    }
    
    if (index != NSNotFound) {
        return index;
    }
    
    index = [self.listeningHistory.rk_reverse indexOfObjectPassingTest:^BOOL(NKSequenceItem *obj, NSUInteger idx, BOOL *stop) {
        return obj.track == item.track;
    }];

    return index;
}

-(void)enqueueHistoryItem:(NKSequenceItem*)sequenceItem {
    [self.listeningHistory addObject:sequenceItem];
}

-(NSArray*)generateNextItems:(NSInteger)numberToGenerate
                  fromTracks:(NSArray*)tracks {
    NSInteger recentSongsCount = MIN(tracks.count * DONT_CHOOSE_LAST_TRACKS_FACTOR, self.listeningHistory.count);
    NSRange lastSongsRange = NSMakeRange(self.listeningHistory.count - recentSongsCount, recentSongsCount);
    NSArray *songsThatWereRecentlyPlayed = [self.listeningHistory subarrayWithRange:lastSongsRange];
    
    NSArray *referencesOfTracksThatShouldntBePlayedAgain = [songsThatWereRecentlyPlayed rk_map:^id(NKSequenceItem* obj) {
        return [NSValue valueWithNonretainedObject:obj.track];
    }];
    
    NSSet *tracksThatShouldntBePlayedAgain = [NSSet setWithArray:referencesOfTracksThatShouldntBePlayedAgain];
    
    NSMutableArray *tracksToChooseFrom = [tracks rk_map:^id(id<NKPlayableTrack> obj) {
        NSValue *trackReference = [NSValue valueWithNonretainedObject:obj];
        if ([tracksThatShouldntBePlayedAgain containsObject:trackReference]) {
            return nil;
        }
        
        return obj;
    }].mutableCopy;
   
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger toAdd = numberToGenerate; toAdd > 0 && tracksToChooseFrom.count > 0; --toAdd) {
        NSUInteger index = arc4random_uniform((uint32_t)tracksToChooseFrom.count);
        NKTrack *track = tracksToChooseFrom[index];
        
        NKSequenceItem *sequenceItem = [NKSequenceItem sequenceItemWithTrack:track];
        [result addObject:sequenceItem];
        
        [tracksToChooseFrom removeObjectAtIndex:index];
    }
    
    return result;
}

-(void)ensureThereIsItem:(NKSequenceItem*)item
  withNextItemsGenerated:(BOOL)withNextItemsGenerated
              fromTracks:(NSArray*)tracks
     sequenceContextSize:(NSUInteger)sequenceContextSize {
    if (item == nil) {
        return;
    }
    
    NSUInteger currentItemIndex = [self itemIndex:item];
 
    if (currentItemIndex == NSNotFound) {
        [self enqueueHistoryItem:item];
    }
 
    NSUInteger shouldBeAtLeastLong = currentItemIndex + self.trackListPlayer.sequencingContextSize;
    NSUInteger toAdd = MAX(shouldBeAtLeastLong -  self.listeningHistory.count, 0);
    
    if (toAdd > 0 && withNextItemsGenerated) {
        NSArray *nextItems = [self generateNextItems:toAdd fromTracks:tracks];
        [self.listeningHistory addObjectsFromArray:nextItems];
    }
    
    NSInteger numberOfTracksToTrack = NUMBER_OF_TRACKS_TO_TRACK(tracks.count, sequenceContextSize);
    NSInteger numberToRemove = MAX(self.listeningHistory.count - (NSInteger)numberOfTracksToTrack, 0);
    if (numberToRemove > 0) {
        [self.listeningHistory removeObjectsInRange:NSMakeRange(0, numberToRemove)];
    }
}


+(NSSet*)setOfTrackPointers:(NSArray*)tracks {
    NSSet *tracksLookup = [NSSet setWithArray:[tracks rk_map:^id(NKTrack *obj) {
        return [NSValue valueWithNonretainedObject:obj];
    }]];
    
    return tracksLookup;
}

#pragma mark - Public Methods

-(NKSequencingContext*)currentSequencingContext {
    NKSequenceItem *currentSequenceItem = self.trackListPlayer.currentSequenceItem;
    
    if (currentSequenceItem == nil) {
        return [NKSequencingContext sequencingContextWithPreviousItems:@[]
                                                          currrentItem:nil
                                                             nextItems:@[]];
    }
    
    NSUInteger currentItemIndex = [self itemIndex:currentSequenceItem];
   
    NSParameterAssert(currentItemIndex != NSNotFound);

    NSUInteger sequenceContextSize = self.trackListPlayer.sequencingContextSize;
    NSUInteger previousNItems = MIN(currentItemIndex, sequenceContextSize);
    NSUInteger nextNItems = MIN(self.listeningHistory.count - (currentItemIndex + 1), sequenceContextSize);
    
    NSRange previousRange = NSMakeRange(currentItemIndex - previousNItems, previousNItems);
    NSRange nextRange = NSMakeRange(currentItemIndex + 1, nextNItems);
    
    NSArray *previousItems = [self.listeningHistory subarrayWithRange:previousRange];
    NSArray *nextItems = [self.listeningHistory subarrayWithRange:nextRange];
    
    previousItems = [previousItems rk_reverse];
    
    NKSequencingContext *sequenceContext = [NKSequencingContext sequencingContextWithPreviousItems:previousItems
                                                      currrentItem:currentSequenceItem
                                                         nextItems:nextItems];
    
    return sequenceContext;
}

-(void)currentItemChangedFrom:(NKSequenceItem *)fromItem {
    [self ensureThereIsItem:self.trackListPlayer.currentSequenceItem
     withNextItemsGenerated:self.trackListPlayer.shuffling
                 fromTracks:self.trackListPlayer.tracks
        sequenceContextSize:self.trackListPlayer.sequencingContextSize];
}

-(NKSequenceItem*)sequencingItemAfterUpdateToTracks:(NSArray*)nextTracks
                                     andCurrentItem:(NKSequenceItem*)sequencingItem {
    NSUInteger indexInHistory = [self itemIndex:sequencingItem];
    
    NSSet *setOfCurrentTracksInHistory = [NKShuffledSequencing setOfTrackPointers:nextTracks];
    
    if (indexInHistory == NSNotFound) {
        return [self generateNextItems:1 fromTracks:nextTracks].rk_firstOrNil;
    }
    
    NSRange nextItemsRange = NSMakeRange(indexInHistory, self.listeningHistory.count - indexInHistory);
    NSArray *nextItems = [self.listeningHistory subarrayWithRange:nextItemsRange];
    
    NSArray *leftItems = [nextItems rk_filter:^(NKSequenceItem *item) {
        NSValue *trackKey = [NSValue valueWithNonretainedObject:item.track];
        
        return [setOfCurrentTracksInHistory containsObject:trackKey];
    }];

    if (leftItems.count == 0) {
        return [self generateNextItems:1 fromTracks:nextTracks].rk_firstOrNil;
    }
    
    return leftItems[0];
}

-(void)tracksUpdatedFrom:(NSArray *)fromTracks {
    NSSet *setOfCurrentTracksInHistory = [NKShuffledSequencing setOfTrackPointers:self.trackListPlayer.tracks];
    
    NSArray *tracksThatAreLeft = [self.listeningHistory rk_filter:^BOOL(NKSequenceItem *item) {
        NSValue *trackKey = [NSValue valueWithNonretainedObject:item.track];
        
        return [setOfCurrentTracksInHistory containsObject:trackKey];
    }];
    
    [self.listeningHistory removeAllObjects];
    [self.listeningHistory addObjectsFromArray:tracksThatAreLeft];

    [self ensureThereIsItem:self.trackListPlayer.currentSequenceItem
     withNextItemsGenerated:self.trackListPlayer.shuffling
                 fromTracks:self.trackListPlayer.tracks
        sequenceContextSize:self.trackListPlayer.sequencingContextSize];
    
}

-(void)sequencingModeChanged {
    if (self.trackListPlayer.shuffling) {
        [self ensureThereIsItem:self.trackListPlayer.currentSequenceItem
         withNextItemsGenerated:YES
                     fromTracks:self.trackListPlayer.tracks
            sequenceContextSize:self.trackListPlayer.sequencingContextSize];
    }
}


@end
