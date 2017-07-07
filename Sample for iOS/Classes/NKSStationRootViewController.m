//
//  NKSStationRootViewController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSStationRootViewController.h"
#import "NKSStationPicker.h"

@interface NKSStationRootViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)    NSString               *stationID;
@property (nonatomic, strong)    NKStationPlayer       *stationPlayer;

@property(nonatomic, readonly)  NSNotificationCenter    *notificationCenter;

#pragma mark - View Properties

@property (nonatomic, weak) IBOutlet    UILabel             *outletTrackNameOutlet;
@property (nonatomic, weak) IBOutlet    UILabel             *outletArtistNameOutlet;

@property (nonatomic, weak) IBOutlet    UIButton            *outletLikeButton;
@property (nonatomic, weak) IBOutlet    UIButton            *outletDislikeButton;
@property (nonatomic, weak) IBOutlet    UIButton            *outletPlayButton;
@property (nonatomic, weak) IBOutlet    UIButton            *outletNextButton;

@property (nonatomic, weak) IBOutlet    UILabel             *outletSkipLimit;

@property (nonatomic, weak) IBOutlet    UISlider            *outletTuning;

@property (nonatomic, weak) IBOutlet    UIActivityIndicatorView *outletLoading;

@property (nonatomic, weak) IBOutlet    UISlider            *outletPlayheadSlider;
@property (nonatomic, weak) IBOutlet    UIProgressView      *outletTrackDownloadProgress;

@property (nonatomic, weak) IBOutlet    UITableView         *outletUpcomingTracks;

@property (nonatomic, strong)           NKRequest           *playerCreatingRequest;

@property (nonatomic, strong)           NSTimer             *updateInterfaceTimer;

#pragma mark - Cached Model Values

@property (nonatomic, strong)           NSArray             *tracks;
@property (nonatomic, assign)           NKVariety           variety;
@property (nonatomic, assign)           BOOL                tuningInProgress;

/**
 *  This timer is being used for most simple retry logic.
 */
@property (nonatomic, strong)           NSTimer             *stationPlayerRetrySynchronizeTimer;

@end

@implementation NKSStationRootViewController

-(NSNotificationCenter*)notificationCenter {
    return self.napster.notificationCenter;
}

-(instancetype)initWithNapster:(NKNapster*)napster {
    self = [super initWithNapster:napster andNibNamed:@"NKSStationRootView"];
    if (!self) return nil;

    self.navigationItem.title = NSLocalizedString(@"Station Player", nil);
    
    [self.notificationCenter addObserver:self
                                selector:@selector(currentTrackAmoundDownloadedDidChange:)
                                    name:NKNotificationCurrentTrackAmountDownloadedChanged
                                  object:nil];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(playbackStateChanged:)
                                    name:NKNotificationPlaybackStateChanged
                                  object:nil];

    [self.notificationCenter addObserver:self
                                selector:@selector(playheadPositionDidChange:)
                                    name:NKNotificationPlayheadPositionChanged
                                  object:nil];

    [self.notificationCenter addObserver:self
                                selector:@selector(sessionChanged:)
                                    name:NKNotificationSessionChanged
                                  object:nil];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(trackListChanged:)
                                    name:NKNotificationStationTracksChanged
                                  object:nil];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(trackLikeStateChanged:)
                                    name:NKNotificationStationCurrentTrackPreferenceChanged
                                  object:nil];

    [self.notificationCenter addObserver:self
                                selector:@selector(currentTrackChanged:)
                                    name:NKNotificationCurrentTrackChanged
                                  object:nil];

    [self.notificationCenter addObserver:self
                                selector:@selector(updateSkipLimit)
                                    name:NKNotificationStationSkipLimitChanged
                                  object:nil];
    
    self.variety = 0.5;
    
    return self;
}

-(void)reportError:(NSError*)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"There were some problems playing the station, please try again later."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.napster.session.isOpen) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Please Sign In to use station player", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    // fix navigation bar
    {
        CGRect navigationFrame = self.navigationController.navigationBar.frame;
        CGFloat bottomNavigationFrame = CGRectGetMaxY(navigationFrame);
        self.outletUpcomingTracks.contentInset = UIEdgeInsetsMake(bottomNavigationFrame, 0, 0, 0);
    }
    
    // add gradient for skip limit badge
    {
        CALayer *limitsLayer = self.outletSkipLimit.superview.layer;
        limitsLayer.borderColor = [UIColor whiteColor].CGColor;
        limitsLayer.borderWidth = 2;
        limitsLayer.masksToBounds = YES;
        limitsLayer.cornerRadius = 14;

        NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:1.0].CGColor];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = colors;
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.locations = @[@(0.0), @(0.4)];
        gradientLayer.frame = limitsLayer.bounds;
        
        [limitsLayer insertSublayer:gradientLayer atIndex:0];
    }
    
    self.outletUpcomingTracks.editing = YES;
    
    [self updateView];
}

-(void)updateStationPicker {
    UIBarButtonItem* buttonItem = self.napster.isSessionOpen
        ?  [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Pick Station", nil)
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(pickStation)]
        : nil;
    [[self navigationItem] setLeftBarButtonItem:buttonItem];
}

-(void)pickStation {
    NKSStationPicker *stationPicker = [[NKSStationPicker alloc] initWithNapster:self.napster
                                                        stationSelectedHandler:^(NSString *station) {
                                                            [self updateStationPlayer:station];
                                                        }];
    
    UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:stationPicker];
    
    stationPicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:rootController animated:YES completion:^{ }];
}

-(void)ensureStationPlayerSynchronized {
    [self.stationPlayerRetrySynchronizeTimer invalidate];
    self.stationPlayerRetrySynchronizeTimer = nil;
    
    if (self.stationPlayer == nil) {
        return;
    }
    
    @rs_weakify(self);
    [self.stationPlayer synchronizeWithCompletion:^(NSError *error) {
        @rs_strongify(self);
        if (error) {
            NSLog(@"Station player synchronize failed: %@", error);
            self.stationPlayerRetrySynchronizeTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                                                       target:self
                                                                                     selector:@selector(stationPlayerTimerFired:)
                                                                                     userInfo:nil
                                                                                      repeats:NO];
                                                       
        }
    }];
}

-(void)stationPlayerTimerFired:(NSTimer*)timer {
    NSLog(@"Automatically retrying station player synchronize");
    [self ensureStationPlayerSynchronized];
}

-(void)updateStationPlayer:(NSString*)stationID {
    BOOL stationChanged = ![self.stationID isEqualToString:stationID];
    
    self.stationID = stationID;
    
    if (self.napster.session.isOpen && (stationChanged || self.stationPlayer == nil)) {
        @rs_weakify(self);
        self.stationPlayer = nil;
        [self updateView];
        
        if (self.playerCreatingRequest) {
            return;
        }
        
        if (self.stationID != nil) {
            self.playerCreatingRequest = [self.napster createStationPlayerFor:self.stationID
                                                                      complete:^(NKStationPlayer *stationPlayer, NSError *error) {
                @rs_strongify(self);
                if (stationPlayer == nil) {
                    [self reportError:error];
                }
        
                self.playerCreatingRequest = nil;
                self.stationPlayer = stationPlayer;
                [self updateView];
            }];
        }
    }
    else {
        self.stationPlayer = nil;
        [self updateView];
    }
}

/**
 Throttles server calls
 */
-(void)tryToSetVariety:(NKVariety)variety {
    if (self.tuningInProgress) {
        return;
    }
    
    if (fabs(variety - self.variety) < 0.05) {
        return;
    }
    
    self.tuningInProgress = YES;
    
    @rs_weakify(self);
    [self.stationPlayer tuneStationPopularity:(1 - variety)
                                      variety:variety
                                   completion:
     ^(NKStation *station, NSError *error) {
         @rs_strongify(self);
         
         self.tuningInProgress = NO;
         self.variety = self.stationPlayer.variety;
                 
         [self updateTuning];
    }];
    
    [self updateTuning];
}

-(void)dealloc {
    [self.notificationCenter removeObserver:self];
    [self.updateInterfaceTimer invalidate];
}

#pragma mark - Actions

-(IBAction)clickStop:(id)sender {
    [self.stationPlayer stopPlayback];
    [self ensureStationPlayerSynchronized];
}

-(IBAction)clickNext:(id)sender {
    [self.stationPlayer skipForward];
    [self ensureStationPlayerSynchronized];
}

-(IBAction)clickPrevious:(id)sender {
}

-(IBAction)clickLike:(id)sender {
    NKStationTrackPreference preference;
    if (self.stationPlayer.currentTrackPreference == NKStationTrackLike) {
        preference = NKStationTrackIndifferent;
    }
    else {
        preference = NKStationTrackLike;
    }
    
    self.stationPlayer.currentTrackPreference = preference;
}

-(IBAction)clickDislike:(id)sender {
    NKStationTrackPreference preference;
    if (self.stationPlayer.currentTrackPreference == NKStationTrackLike) {
        preference = NKStationTrackIndifferent;
    }
    else {
        preference = NKStationTrackDislike;
    }
    
    self.stationPlayer.currentTrackPreference = preference;
    
    if (preference == NKStationTrackDislike) {
        [self.stationPlayer skipForward];
    }
}

-(IBAction)clickPlay:(id)sender {
    if (self.stationPlayer.playbackState == NKPlaybackStatePlaying) {
        [self.stationPlayer pausePlayback];
    }
    else if (self.stationPlayer.playbackState == NKPlaybackStatePaused) {
        [self.stationPlayer resumePlayback];
    }
}

-(IBAction)playheadSliderBeganDrag:(id)sender
{
    [self.stationPlayer setScrubbing:YES];
}

-(IBAction)playheadSliderDragged:(id)sender
{
    NSTimeInterval playheadPosition = [self.stationPlayer seekTo:self.outletPlayheadSlider.value];
    self.outletPlayheadSlider.value = playheadPosition;
}

-(IBAction)playheadSliderEndedDrag:(id)sender
{
    [self.stationPlayer setScrubbing:NO];
}

-(IBAction)playheadSliderTuning:(id)sender
{
    NKVariety variety = self.outletTuning.value;
 
    [self tryToSetVariety:variety];
}

#pragma mark - Notifications

-(void)sessionChanged:(NSNotification*)sessionChanged {
    NKSession *oldSession = sessionChanged.userInfo[NKNotificationSessionChangedFormerSessionKey];
    NKSession *newSession = self.napster.session;
    
    BOOL justLoggedIn = !oldSession.isOpen && newSession.isOpen;
    
    [self updateStationPlayer:self.stationID];
    
    if (justLoggedIn) {
        [self pickStation];
    }
}

-(void)currentTrackAmoundDownloadedDidChange:(NSNotification*)notification {
    [self updateProgressView];
}

-(void)playheadPositionDidChange:(NSNotification*)notification {
    [self updatePlayheadSlider];
}

-(void)trackListChanged:(NSNotification*)trackListChanged {
    [self updateUpcomingTracks];
}

-(void)trackLikeStateChanged:(NSNotification*)notification {
    [self updateLikeButtons];
}

-(void)currentTrackChanged:(NSNotification*)notification {
    [self updateView];
}

-(void)playbackStateChanged:(NSNotification*)notification {
    [self updatePlayButtons];
}

#pragma mark - Update View

-(void)updateView {
    [self updatePlayheadSlider];
    [self updateProgressView];
    [self updateUpcomingTracks];
    [self updateLikeButtons];
    [self updatePlayButtons];
    [self updateTuning];
    [self updateStationPicker];
    
    //self.outletStationName.text = self.stationPlayer.station
    NKTrack *track  = self.stationPlayer.currentTrack;
    self.outletTrackNameOutlet.text = track.name;
    self.outletArtistNameOutlet.text = track.artist.name;
}

-(void)updatePlayButtons {
    [self updateSkipLimit];
    
    self.outletPlayButton.selected = self.stationPlayer.playbackState == NKPlaybackStatePlaying;
    
    NSNumber *skipsRemaining = self.stationPlayer.skipsRemaining;
    BOOL canSkip = skipsRemaining != nil
        ? skipsRemaining.integerValue > 0
        : YES;
    
    self.outletNextButton.enabled = canSkip;
}

-(void)updateLikeButtons {
    BOOL enabled = self.stationPlayer.isTunable && self.stationPlayer != nil;;
    
    BOOL hasSkipsLeft = self.stationPlayer.skipsRemaining == nil || self.stationPlayer.skipsRemaining.integerValue > 0;
    BOOL dislikeEnabled = enabled && hasSkipsLeft;
    
    self.outletLikeButton.selected = self.stationPlayer.currentTrackPreference == NKStationTrackLike && enabled;
    
    self.outletLikeButton.enabled = enabled;
    self.outletDislikeButton.enabled = dislikeEnabled;
}

-(void)updateProgressView {
    self.outletTrackDownloadProgress.progress = self.stationPlayer.currentTrackAmountDownloaded;
}

- (void)updatePlayheadSlider {
    NSTimeInterval duration = self.stationPlayer.currentTrackDuration;
    
    self.outletPlayheadSlider.maximumValue = duration;
    self.outletPlayheadSlider.value = self.stationPlayer.playheadPosition;
    self.outletPlayheadSlider.enabled = self.stationPlayer.playbackState != NKPlaybackStateStopped && duration != 0;
}

+(id)previewTrackID:(NKPreviewTrack*)previewTrack {
    return previewTrack.track.ID != nil
        ? previewTrack.track.ID
        : previewTrack.artist.ID;
}

-(void)updateUpcomingTracks {
    NSArray *previousTracks = self.tracks;
    
    self.tracks = self.stationPlayer.previewTracks;
    
    if (previousTracks == nil || previousTracks.count == 0) {
        [self.outletUpcomingTracks reloadData];
        return;
    }
    
    [self.outletUpcomingTracks beginUpdates];
    
    NSArray *previousTrackIDs = [previousTracks rk_map:^id(NKPreviewTrack *previewTrack) {
        return [NKSStationRootViewController previewTrackID:previewTrack];
    }];
    
    NSArray *newTrackIDs = [self.tracks rk_map:^id(NKPreviewTrack *previewTrack) {
        return [NKSStationRootViewController previewTrackID:previewTrack];
    }];
    
    NSSet *previousTracksLookup = [NSSet setWithArray:previousTrackIDs];
    NSSet *newTracksLookup = [NSSet setWithArray:newTrackIDs];
    
    for (NSInteger i = 0; i < previousTrackIDs.count; ++i) {
        id oldTrackID = previousTrackIDs[i];
        if (![newTracksLookup containsObject:oldTrackID]) {
            NSIndexPath *deletePath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.outletUpcomingTracks deleteRowsAtIndexPaths:@[deletePath]
                                             withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    for (NSInteger i = 0; i < newTrackIDs.count; ++i) {
        id newTrackID = newTrackIDs[i];
        if (![previousTracksLookup containsObject:newTrackID]) {
            NSIndexPath *newPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.outletUpcomingTracks insertRowsAtIndexPaths:@[newPath]
                                             withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [self.outletUpcomingTracks endUpdates];
}

-(void)updateSkipLimit {
    [self.updateInterfaceTimer invalidate];
    
    NSNumber *skipLimit = self.stationPlayer.skipsRemaining;
    
    self.outletUpcomingTracks.editing = skipLimit == nil || skipLimit.integerValue > 0;
    self.outletSkipLimit.text = [NSString stringWithFormat:@"%@", skipLimit];
    self.outletSkipLimit.superview.hidden = skipLimit == nil;
    
    if (skipLimit == nil) {
        return;
    }
    
    NSDate *skipChangeTime = self.stationPlayer.skipChangeTime;
    
    if (skipChangeTime == nil) {
        return;
    }
    
    NSTimeInterval timeTillChange = [skipChangeTime timeIntervalSinceNow];
    
    self.updateInterfaceTimer = [NSTimer scheduledTimerWithTimeInterval:timeTillChange
                                                                 target:self
                                                               selector:@selector(updatePlayButtons)
                                                               userInfo:nil
                                                                repeats:NO];
}

-(void)updateTuning {
    self.outletTuning.enabled = self.stationPlayer.isTunable;
    
    if (!self.tuningInProgress) {
        [self.outletLoading stopAnimating];
    }
    else {
        [self.outletLoading startAnimating];
    }
    
    self.outletLoading.hidden = !self.tuningInProgress;
}

#pragma mark - UpcomingTracks

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stationPlayer.previewTracks.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpcomingTrack"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UpcomingTrack"];
    }
    
    NKPreviewTrack *track = self.stationPlayer.previewTracks[indexPath.row];
    
    cell.textLabel.text = track.track.name != nil
        ? track.track.name
        : [NSString stringWithFormat:@"%@'s track", track.artist.name];
    cell.detailTextLabel.text = track.artist.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.stationPlayer playPreviewTrackAtIndex:indexPath.row];
    [self ensureStationPlayerSynchronized];
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.stationPlayer deletePreviewTrackAtIndex:indexPath.row];
    [self ensureStationPlayerSynchronized];
}

#pragma mark - Lock Screen Events

-(void)playNextTrack {
    [self.stationPlayer skipForward];
}

@end
