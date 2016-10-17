//
//  NKStationPlayer.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NKTrackPlayer.h"

extern NSString * const NKNotificationStationCurrentTrackChanged;
extern NSString * const NKNotificationStationTracksChanged;
extern NSString * const NKNotificationStationCurrentTrackPreferenceChanged;
extern NSString * const NKNotificationStationSkipLimitChanged;

typedef double NKPopularity;
typedef double NKVariety;

typedef NS_ENUM(NSInteger, NKStationTrackPreference) {
    NKStationTrackDislike     = -1,
    NKStationTrackIndifferent = 0,
    NKStationTrackLike        = 1
};

@class NKTrackPlayer;
@class NKNapster;
@class NKTrack;
@class NKStation;

@class NKPreviewTrack;

typedef void (^TuneStationCompletionHandler)(NKStation *station, NSError *error);
typedef void (^SynchronizeCompletionHandler)(NSError *error);

@interface NKStationPlayer : NSObject

/**
 *  Public interface for player methods
 */

/**
 * Pauses playback.
 */
- (void)pausePlayback;

/**
 * Resumes playback.
 */
- (void)resumePlayback;

/**
 * Stops playback, clears the current track and cancels caching of upcoming tracks.
 */
- (void)stopPlayback;

/**
 * The current track's duration calculated from the loaded audio data.
 * Observe NKNotificationCurrentTrackDurationChanged to be notified when this value changes.
 */
@property (nonatomic, readonly) NSTimeInterval currentTrackDuration;

/**
 * The amount of the current track that has been downloaded, from 0 to 1.
 * Observe NKNotificationCurrentTrackAmountDownloadedChanged to be notified when this value changes.
 */
@property (nonatomic, readonly) float currentTrackAmountDownloaded;

/**
 * The playhead location in the current track. Its value is updated each second.
 * Observe NKNotificationPlayheadPositionChanged to be notified when this value changes.
 */
@property (nonatomic, readonly) NSTimeInterval playheadPosition;


/**
 * The current playback state. Observe NKNotificationPlaybackStateChanged to be notified when this value changes.
 */
@property (nonatomic, readonly) NKPlaybackState playbackState;

/**
 * Description of next tracks in playback queue. This property is key value observable.
 */
@property (nonatomic, copy, readonly  ) NSArray *previewTracks;


/**
 *  Current track that is being played. These properties are key value observable.
 */
@property (nonatomic, copy, readonly  ) NKTrack                   *currentTrack;
@property (nonatomic, assign          ) NKStationTrackPreference   currentTrackPreference;

/**
 * Changes the playhead position for the current track.
 *
 * If given a position beyond the maxSeekPosition, the playhead position will be set to maxSeekPosition.
 *
 *  @return The resulting playhead position.
 */
- (NSTimeInterval)seekTo:(NSTimeInterval)position;

/**
 * Sets whether or not the user is scrubbing. For example, enable scrubbing when the user begins dragging,
 * then call seekTo: while dragging and finally disable scrubbing when the user finishes dragging.
 */
- (void)setScrubbing:(BOOL)scrubbing;

/**
 *  If there is a limitation on the number of skips that can be performed, these 
 *  properties contain number of skips remaining for a specific station and
 *  when the first skip will expire.
 *  In case there is no limitation, these properties return `nil`.
 *
 *  These properties support key value observing. And key value observing will be
 *  triggered in case performing an action changes these properties. In case
 *  these properties change because of elapsed time period, key value observing
 *  mechanism will not be triggered.
 */
@property (nonatomic, copy, readonly  ) NSNumber                   *skipsRemaining;
@property (nonatomic, copy, readonly  ) NSDate                     *skipChangeTime;

// does it skip intermediate tracks?
// it skips tracks in between
-(void)playPreviewTrackAtIndex:(NSUInteger)trackIndex;

-(void)deletePreviewTrackAtIndex:(NSUInteger)trackIndex;

-(void)skipForward;

/**
 *  This method synchronizes `self` with server model.
 *
 *  This process includes:
 *      * sending like/dislike feedback
 *      * fetching preview tracks
 *      * refresh other station parameters
 *  
 *  This method will be automatically called at most once  on important events like:
 *      * performing `skipForward`
 *      * performing `playPreviewTrackAtIndex`
 *      * ...
 *
 *  Calling this method when there is nothing to synchronize won't cause unnecessary
 *  server API calls.
 */
-(void)synchronizeWithCompletion:(SynchronizeCompletionHandler)completion;

#pragma mark - Tuning

@property (nonatomic, readonly        ) BOOL                        isTunable;

@property (nonatomic, readonly        ) NKPopularity               popularity;
@property (nonatomic, readonly        ) NKVariety                  variety;

-(void)tuneStationPopularity:(NKPopularity)popularity
                     variety:(NKVariety)variety
                  completion:(TuneStationCompletionHandler)completion;

@end
