//
//  NKSManualPlayerController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//

#import "NKTrackListPlayer.h"
#import "NKNaturalSequencing.h"
#import "NKShuffledSequencing.h"
#import "NKSequenceItem.h"
#import "NKSequencingContext.h"
#import "NKTrackListPlayer_Private.h"
#import "NSArray+NKExtensions.h"

#if DEBUG
#   define QUEUE_LOG NSLog
#else
#   define QUEUE_LOG(...)
#endif

@interface NKTrackListPlayer ()

#pragma mark - Read/Write Public Properties

@property (nonatomic, strong)   NKNapster              *napster;
@property (nonatomic, strong)   NSNotificationCenter    *notificationCenter;

@property (nonatomic, strong)   id                      playbackContext;

@property (nonatomic)           NSUInteger              sequencingContextSize;

@property (nonatomic, copy)     NSString                *containerID;

#pragma mark - Private Properties

@property (nonatomic)           NSDictionary            *sequencerByMode;

@property (nonatomic, readonly) NKSequencingContext     *currentSequenceContext;

@property (nonatomic, readonly) id<NKSequencingAlgorithm> currentSequenceAlgorithm;

#pragma mark

@end

@implementation NKTrackListPlayer

NSString* const NKTrackListNotificationTracksChanged = @"NKTrackListNotificationTracksChanged";
NSString* const NKTrackListNotificationCurrentTrackChanged = @"NKTrackListNotificationCurrentTrackChanged";
NSString* const NKTrackListNotificationPlaybackContextChanged = @"NKTrackListNotificationPlaybackContextChanged";
NSString* const NKTrackListNotificationShuffleModeChanged = @"NKTrackListNotificationShuffleModeChanged";
NSString* const NKTrackListNotificationRepeatModeChanged = @"NKTrackListNotificationRepeatModeChanged";

- (instancetype)initWithNapster:(NKNapster*)napster
                     containerID:(NSString*)containerID
        andSequencingContextSize:(NSUInteger)sequencingContextSize
{
    self = [super init];
    if (!self) return nil;
    
    self.napster = napster;
    
    self.playbackContext = [NSObject new];
    
    self.currentSequenceItem = nil;
    self.sequencingContextSize = sequencingContextSize;
    self.containerID = containerID;
    
    self.sequencerByMode = @{
                             @(NO)  : [[NKNaturalSequencing alloc] initWithTrackListPlayer:self],
                             @(YES) : [[NKShuffledSequencing alloc] initWithTrackListPlayer:self]
                           };

    [self.notificationCenter addObserver:self
                                selector:@selector(playbackStateChanged:)
                                    name:NKNotificationPlaybackStateChanged
                                  object:nil];

    self.tracks = @[];

    return self;
}

- (void)dealloc {
    if ([self.trackPlayer.playbackContext isEqual:self.playbackContext]) {
        [self.trackPlayer stopPlayback];
    }
    [self.notificationCenter removeObserver:self];
}

#pragma mark - Read Only Properties

- (NKTrack*)currentTrack {
    return self.currentSequenceItem.track;
}

- (NSArray*)nextTracks {
    return [self.currentSequenceContext.nextItems rk_map:^id(NKSequenceItem *sequenceItem) {
        return sequenceItem.track;
    }];
}

- (NSArray*)previousTracks {
    return [self.currentSequenceContext.previousItems rk_map:^id(NKSequenceItem *sequenceItem) {
        return sequenceItem.track;
    }];
}

- (NKTrackPlayer*)trackPlayer {
    return self.napster.player;
}

- (NSNotificationCenter*)notificationCenter {
    return self.napster.notificationCenter;
}

- (id<NKSequencingAlgorithm>)currentSequenceAlgorithm {
    return [self.sequencerByMode objectForKey:@(self.shuffling)];
}

- (NKSequencingContext*)currentSequenceContext {
    NKSequencingContext *sequenceContext = self.currentSequenceAlgorithm.currentSequencingContext;
    
    // sequencers don't handle one track repeat mode, because it's the same logic
    if (self.repeatMode == NKRepeatModeSingleTrack) {
        NSMutableArray *others = nil;
        
        if (sequenceContext.currentItem) {
            others = [NSMutableArray array];
            
            for (NSUInteger i = 0; i < self.sequencingContextSize; ++i) {
                [others addObject:sequenceContext.currentItem];
            }
        }
        
        sequenceContext = [NKSequencingContext sequencingContextWithPreviousItems:others
                                                                     currrentItem:sequenceContext.currentItem
                                                                        nextItems:others];
    }
    
    return sequenceContext;
}

#pragma mark - Playback

- (BOOL)canSkipToNextTrack
{
    return self.currentSequenceContext.nextItems.count > 0;
}

- (void)playNextTrack
{
    if (![self canSkipToNextTrack]) return;
    
    NKSequenceItem *nextItem = [self.currentSequenceContext.nextItems objectAtIndex:0];
    
    [self playSequenceItem:nextItem];
}

- (BOOL)canSkipToPreviousTrack
{
    return self.previousTracks.count > 0;
}

- (void)playPreviousTrack
{
    if (![self canSkipToPreviousTrack]) return;
    
    NKSequenceItem *previousItem = [self.currentSequenceContext.previousItems objectAtIndex:0];
    
    [self playSequenceItem:previousItem];
}

- (void)playSequenceItem:(NKSequenceItem*)item {
    [self setTracks:self.tracks
currentSequenceItem:item
          shuffling:self.shuffling
         repeatMode:self.repeatMode
    playbackContext:self.playbackContext
beforeNotifications:nil];
}

- (void)updatePlayerForCurrentTrack {
    [self.trackPlayer playTrack:self.currentTrack
                    containerID:self.containerID
             eagerlyCacheTracks:self.nextTracks
                playbackContext:self.playbackContext];
}

- (void)playTrack:(NKTrack*)track
{
    NKSequenceItem *externalSequenceItem = [NKSequenceItem sequenceItemWithTrack:track];
    [self playSequenceItem:externalSequenceItem];
}

- (void)playTracks:(NSArray*)tracks
      startingWith:(NKTrack*)track
       fromContext:(id)playbackContext;
{
    if (playbackContext == nil) {
        playbackContext = [NSObject new];
    }
    
    NKSequenceItem *item = [NKSequenceItem sequenceItemWithTrack:track];
    
    [self setTracks:tracks
currentSequenceItem:item
          shuffling:self.shuffling
         repeatMode:self.repeatMode
    playbackContext:playbackContext
beforeNotifications:nil];
}

- (void)setTracks:(NSArray *)tracks
{
    [self setTracks:tracks
currentSequenceItem:self.currentSequenceItem
          shuffling:self.shuffling
         repeatMode:self.repeatMode
    playbackContext:self.playbackContext
beforeNotifications:nil];
    
}

- (BOOL)isPlayingTrack:(NKTrack*)playableTrack {
    return [self.trackPlayer.playbackContext isEqual:self.playbackContext] && self.currentSequenceItem.track == playableTrack;
}

- (void)setShuffling:(BOOL)shuffling
{
    if (shuffling == _shuffling) return;
   
    [self setTracks:self.tracks
currentSequenceItem:self.currentSequenceItem
          shuffling:shuffling
         repeatMode:self.repeatMode
    playbackContext:self.playbackContext
beforeNotifications:nil];
}

- (void)setRepeatMode:(NKRepeatMode)repeatMode
{
    if (repeatMode == _repeatMode) return;
    
    [self setTracks:self.tracks
currentSequenceItem:self.currentSequenceItem
          shuffling:self.shuffling
         repeatMode:repeatMode
    playbackContext:self.playbackContext
beforeNotifications:nil];
}

// To keep our properties in a consistent state, we set them in one go so that all the values are updated by the time we post notifications for each change.
- (void)    setTracks:(NSArray*)tracks
  currentSequenceItem:(NKSequenceItem*)sequenceItem
            shuffling:(BOOL)shuffling
           repeatMode:(NKRepeatMode)repeatMode
      playbackContext:(id<NSCopying>)playbackContext
  beforeNotifications:(void (^)(void))beforeNotifications
{
    BOOL tracksChanged = ![self.tracks isEqual:tracks];
    [self willChangeValueForKey:@"tracks"];
    
    if (tracksChanged) {
        id<NKSequencingAlgorithm> currentAlgorithm = self.currentSequenceAlgorithm;
        sequenceItem = [currentAlgorithm sequencingItemAfterUpdateToTracks:tracks
                                                            andCurrentItem:sequenceItem];
    }
    
    BOOL currentTrackChanged = self.currentSequenceItem.track != sequenceItem.track;
    BOOL shufflingChanged = shuffling != _shuffling;
    BOOL repeatModeChanged = repeatMode != _repeatMode;
    BOOL playbackContextChanged = ![self.playbackContext isEqual:playbackContext];
    
    if (currentTrackChanged)    [self willChangeValueForKey:@"currentTrack"];
    if (shufflingChanged)       [self willChangeValueForKey:@"shuffling"];
    if (repeatModeChanged)      [self willChangeValueForKey:@"repeatMode"];
    if (playbackContextChanged) [self willChangeValueForKey:@"playbackContext"];
    
    NSArray *_originalTracks = _tracks;
    
    _currentSequenceItem = sequenceItem;
    _shuffling = shuffling;
    _repeatMode = repeatMode;
    _playbackContext = playbackContext;
    _tracks = [tracks copy];
    
    // To keep our controller's properties consistent with the player's own properties, we shouldn't post our notifications until we've made the appropriate calls to the player. This way, by the time we post our notifications, the player will have updated its values and posted its own notifications.
    if (beforeNotifications) beforeNotifications();
   
    if (tracksChanged) {
        for (id<NKSequencingAlgorithm> sequenceAlgorithm in self.sequencerByMode.allValues) {
            [sequenceAlgorithm tracksUpdatedFrom:_originalTracks];
        }
        [self didChangeValueForKey:@"tracks"];
        [self.notificationCenter postNotificationName:NKTrackListNotificationTracksChanged object:self];
    }
    
    if (currentTrackChanged) {
        
        if (self.currentSequenceItem == nil || self.currentSequenceItem.track == nil) {
            [self.trackPlayer stopPlayback];
        }
        else {
            [self updatePlayerForCurrentTrack];
        }
        
        for (id<NKSequencingAlgorithm> sequencingAlgorithm in self.sequencerByMode.allValues) {
            [sequencingAlgorithm currentItemChangedFrom:self.currentSequenceItem];
        }
    }
    // this could happen for example in case of one track repeat
    else if (self.trackPlayer.playbackState != NKPlaybackStatePlaying) {
        [self updatePlayerForCurrentTrack];
    }
    
    if (shufflingChanged) {
        for (id<NKSequencingAlgorithm> sequencingAlgorithm in self.sequencerByMode.allValues) {
            [sequencingAlgorithm sequencingModeChanged];
        }
    }
    
    if (currentTrackChanged) {
        [self didChangeValueForKey:@"currentTrack"];
        [self.notificationCenter postNotificationName:NKTrackListNotificationCurrentTrackChanged object:self];
    }
    if (shufflingChanged) {
        [self didChangeValueForKey:@"shuffling"];
        [self.notificationCenter postNotificationName:NKTrackListNotificationShuffleModeChanged object:self];
    }
    if (repeatModeChanged) {
        [self didChangeValueForKey:@"repeatMode"];
        [self.notificationCenter postNotificationName:NKTrackListNotificationRepeatModeChanged object:self];
    }
    if (playbackContextChanged) {
        [self didChangeValueForKey:@"playbackContext"];
        [self.notificationCenter postNotificationName:NKTrackListNotificationPlaybackContextChanged object:self];
    }
}

- (void)stopPlayback {
    [self.trackPlayer stopPlayback];
}

#pragma mark - Notification handlers

- (void)playbackStateChanged:(NSNotification*)notification
{
    switch (self.trackPlayer.playbackState) {
        case NKPlaybackStateBuffering:
        case NKPlaybackStatePlaying:
        case NKPlaybackStatePaused:
            return;
        case NKPlaybackStateStopped:
            [self setTracks:self.tracks
        currentSequenceItem:nil
                  shuffling:self.shuffling
                 repeatMode:self.repeatMode
            playbackContext:self.playbackContext
        beforeNotifications:nil];
            return;
        case NKPlaybackStateFinished:
            [self playNextTrack];
            break;
    }
    
    QUEUE_LOG(@"Preparing next track.");
}

@end
