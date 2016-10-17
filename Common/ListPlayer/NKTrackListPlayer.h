//
//  NKSManualPlayerController.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@class NKNapster;
@class NKTrackPlayer;

@interface NKTrackListPlayer : NSObject

@property (nonatomic, readonly) NKNapster           *napster;
@property (nonatomic, readonly) NKTrackPlayer        *trackPlayer;
@property (nonatomic, readonly) NSNotificationCenter  *notificationCenter;

@property (nonatomic, readonly, assign)     NSUInteger              sequencingContextSize;
@property (nonatomic, readonly, copy)       NSString                *containerID;

- (instancetype)initWithNapster:(NKNapster*)napster
                     containerID:(NSString*)containerID
        andSequencingContextSize:(NSUInteger)sequencingContextSize;

#pragma mark - Tracks

@property (nonatomic, strong, readonly)     NKTrack                         *currentTrack;
@property (nonatomic, strong, readonly)     NSArray/*id<NKTrack>*/          *nextTracks;
@property (nonatomic, strong, readonly)     NSArray/*id<NKTrack>*/          *previousTracks;

@property (nonatomic, copy)                 NSArray                          *tracks;

#pragma mark - Modes

typedef NS_ENUM(NSInteger, NKRepeatMode) {
    NKRepeatModeNone,
    NKRepeatModeAllTracks,
    NKRepeatModeSingleTrack,
};

@property (nonatomic, assign)               BOOL            shuffling;
@property (nonatomic, assign)               NKRepeatMode    repeatMode;

#pragma mark - Playback

@property (nonatomic, strong, readonly)     id              playbackContext;

@property (nonatomic, readonly)             BOOL            canSkipToNextTrack;
@property (nonatomic, readonly)             BOOL            canSkipToPreviousTrack;

- (void)playTrack:(NKTrack*)track;

- (void)playNextTrack;

- (void)playPreviousTrack;

- (void)playTracks:(NSArray/*id<NKTrack>*/*)tracks
      startingWith:(NKTrack*)track
       fromContext:(id)playbackContext;

- (BOOL)isPlayingTrack:(NKTrack*)playableTrack;

- (void)stopPlayback;

#pragma mark - Notifications

extern NSString* const NKTrackListNotificationTracksChanged;
extern NSString* const NKTrackListNotificationCurrentTrackChanged;
extern NSString* const NKTrackListNotificationPlaybackContextChanged;
extern NSString* const NKTrackListNotificationShuffleModeChanged;
extern NSString* const NKTrackListNotificationRepeatModeChanged;

@end
