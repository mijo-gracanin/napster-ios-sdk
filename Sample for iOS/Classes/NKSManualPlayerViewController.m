//
//  NKSManualPlayerViewController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSManualPlayerViewController.h"
#import "NKTrackListPlayer.h"

@interface NKSManualPlayerViewController ()

@property (nonatomic, strong) NKTrackListPlayer *trackListPlayer;

@property (weak, nonatomic) IBOutlet UIButton* repeatButton;
@property (weak, nonatomic) IBOutlet UIButton* shuffleButton;
@property (weak, nonatomic) IBOutlet UIButton* previousButton;
@property (weak, nonatomic) IBOutlet UIButton* nextButton;
@property (weak, nonatomic) IBOutlet UIButton* playButton;
@property (weak, nonatomic) IBOutlet UIButton* pauseButton;
@property (weak, nonatomic) IBOutlet UISlider* playheadSlider;
@property (weak, nonatomic) IBOutlet UIProgressView* trackProgressView;
@property (nonatomic) NSTimer* levelsMeteringTimer;
@property (weak, nonatomic) IBOutlet UIView* leftAverageMeter;
@property (weak, nonatomic) IBOutlet UIView* leftPeakMeter;
@property (weak, nonatomic) IBOutlet UIImageView* leftMeterImageView;
@property (weak, nonatomic) IBOutlet UIView* rightAverageMeter;
@property (weak, nonatomic) IBOutlet UIView* rightPeakMeter;
@property (weak, nonatomic) IBOutlet UIImageView* rightMeterImageView;

@end

@implementation NKSManualPlayerViewController

- (id)initWithTrackListPlayer:(NKTrackListPlayer *)trackListPlayer
{
    self = [super initWithNibName:@"NKSPlayerViewController" bundle:nil];
    if (!self) return nil;
    
    self.trackListPlayer = trackListPlayer;
    
    [self setTitle:NSLocalizedString(@"Now Playing", nil)];
    
    return self;
}

- (void)dealloc
{
    [[self levelsMeteringTimer] invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self playheadSlider] setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [[self playheadSlider] setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    
    [self configureForPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange:) name:NKNotificationPlaybackStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackDidChange:) name:NKNotificationCurrentTrackChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackIndexDidChange:) name:NKTrackListNotificationCurrentTrackChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackDurationDidChange:) name:NKNotificationCurrentTrackDurationChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playheadPositionDidChange:) name:NKNotificationPlayheadPositionChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tracksDidChange:) name:NKTrackListNotificationTracksChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shuffleModeDidChange:) name:NKTrackListNotificationShuffleModeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repeatModeDidChange:) name:NKTrackListNotificationRepeatModeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentTrackAmoundDownloadedDidChange:) name:NKNotificationCurrentTrackAmountDownloadedChanged object:nil];
    
    [[self leftMeterImageView] setImage:[[[self leftMeterImageView] image] resizableImageWithCapInsets:UIEdgeInsetsZero]];
    [[self rightMeterImageView] setImage:[[[self rightMeterImageView] image] resizableImageWithCapInsets:UIEdgeInsetsZero]];
    
    [self configureLevelsMeteringTimer];
    
    [self configureTrackProgressView];
}

- (void)setTrackListPlayer:(NKTrackListPlayer *)trackListPlayer {
    _trackListPlayer = trackListPlayer;
}

#pragma mark - Notification handlers

- (void)playbackStateDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
    [self configureLevelsMeteringTimer];
}

- (void)playerTracksDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
}

- (void)currentTrackDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
}

- (void)currentTrackIndexDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
}

- (void)currentTrackAmoundDownloadedDidChange:(NSNotification*)notification
{
    [self configureTrackProgressView];
}

- (void)playheadPositionDidChange:(NSNotification*)notification
{
    [self configurePlayheadSlider];
}

- (void)currentTrackDurationDidChange:(NSNotification*)notification
{
    [self configurePlayheadSlider];
}

- (void)tracksDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
}

- (void)shuffleModeDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
}

- (void)repeatModeDidChange:(NSNotification*)notification
{
    [self configureForPlayer];
}

#pragma mark - Actions

- (IBAction)repeatButtonTapped:(id)sender
{
    NKRepeatMode repeatMode;
    switch (self.trackListPlayer.repeatMode) {
        case NKRepeatModeNone:
            repeatMode = NKRepeatModeAllTracks;
            break;
        case NKRepeatModeAllTracks:
            repeatMode = NKRepeatModeSingleTrack;
            break;
        case NKRepeatModeSingleTrack:
            repeatMode = NKRepeatModeNone;
            break;
    }
    
    self.trackListPlayer.repeatMode = repeatMode;
}

- (IBAction)shuffleButtonTapped:(id)sender
{
    self.trackListPlayer.shuffling = !self.trackListPlayer.shuffling;
}

- (IBAction)previousButtonTapped:(id)sender
{
    if ([[self playheadSlider] value] >= 5 || !self.trackListPlayer.canSkipToPreviousTrack) {
        [self.trackListPlayer.trackPlayer seekTo:0];
    } else {
        [self.trackListPlayer playPreviousTrack];
    }
}

- (IBAction)stopButtonPressed:(id)sender {
    [self.trackListPlayer stopPlayback];
}

- (IBAction)nextButtonTapped:(id)sender
{
    [self.trackListPlayer playNextTrack];
}

- (IBAction)playButtonTapped:(id)sender
{
    [self.trackListPlayer.trackPlayer resumePlayback];
}

- (IBAction)pauseButtonTapped:(id)sender
{
    [self.trackListPlayer.trackPlayer pausePlayback];
}

- (IBAction)playheadSliderBeganDrag:(id)sender
{
    [self.trackListPlayer.trackPlayer setScrubbing:YES];
}

- (IBAction)playheadSliderDragged:(id)sender
{
    NSTimeInterval playheadPosition = [self.trackListPlayer.trackPlayer seekTo:[[self playheadSlider] value]];
    [[self playheadSlider] setValue:playheadPosition];
}

- (IBAction)playheadSliderEndedDrag:(id)sender
{
    [self.trackListPlayer.trackPlayer setScrubbing:NO];
}

#pragma mark - Helpers

- (void)configureForPlayer
{
    NKTrackPlayer *player = self.trackListPlayer.trackPlayer;
    switch (player.playbackState) {
        case NKPlaybackStateStopped:
        case NKPlaybackStateFinished:
        case NKPlaybackStatePaused:
            [[self playButton] setHidden:NO];
            [[self pauseButton] setHidden:YES];
            break;
        case NKPlaybackStateBuffering:
        case NKPlaybackStatePlaying:
            [[self playButton] setHidden:YES];
            [[self pauseButton] setHidden:NO];
            break;
    }
    
    BOOL isStopped = player.playbackState == NKPlaybackStateStopped;
    
    [[self playButton] setEnabled:!isStopped];
    [[self previousButton] setEnabled:!isStopped];
    [[self nextButton] setEnabled:!isStopped && self.trackListPlayer.canSkipToNextTrack];
    [[self shuffleButton] setEnabled:!isStopped];
    [[self shuffleButton] setSelected:self.trackListPlayer.shuffling];
    [[self repeatButton] setEnabled:!isStopped];
    
    NSString* repeatButtonImageName = nil;
    switch (self.trackListPlayer.repeatMode) {
        case NKRepeatModeNone:
            repeatButtonImageName = @"PlayerRepeat";
            break;
        case NKRepeatModeAllTracks:
            repeatButtonImageName = @"PlayerRepeatAllTracks";
            break;
        case NKRepeatModeSingleTrack:
            repeatButtonImageName = @"PlayerRepeatSingleTrack";
            break;
    }
    if (![[self repeatButton] isEnabled]) {
        repeatButtonImageName = @"PlayerRepeat";
    }
    [[self repeatButton] setImage:[UIImage imageNamed:repeatButtonImageName] forState:UIControlStateNormal];
    
    [self configurePlayheadSlider];
}

- (void)configurePlayheadSlider
{
    NKTrackPlayer *player = self.trackListPlayer.trackPlayer;
    NSTimeInterval duration = [player currentTrackDuration];
    [[self playheadSlider] setMaximumValue:duration];
    [[self playheadSlider] setValue:player.playheadPosition];
    [[self playheadSlider] setEnabled:player.playbackState != NKPlaybackStateStopped && duration != 0];
}

- (void)configureLevelsMeteringTimer
{
    NKTrackPlayer *player = self.trackListPlayer.trackPlayer;
    switch (player.playbackState) {
        case NKPlaybackStateStopped:
        case NKPlaybackStateFinished:
        case NKPlaybackStatePaused:
        case NKPlaybackStateBuffering:
            [[self levelsMeteringTimer] invalidate];
            [self setLevelsMeteringTimer:nil];
            [self configureLevelsMeter];
            break;
        case NKPlaybackStatePlaying:
            if ([self levelsMeteringTimer]) return;
            [self setLevelsMeteringTimer:[NSTimer timerWithTimeInterval:0.08 target:self selector:@selector(configureLevelsMeter) userInfo:nil repeats:YES]];
            [[NSRunLoop currentRunLoop] addTimer:[self levelsMeteringTimer] forMode:NSRunLoopCommonModes];
            break;
    }
}

- (void)configureLevelsMeter
{
    float leftAverage;
    float leftPeak;
    float rightAverage;
    float rightPeak;
    
    NKTrackPlayer *player = self.trackListPlayer.trackPlayer;
    
    [player leftChannelAverageDecibels:&leftAverage leftChannelPeakDecibels:&leftPeak rightChannelAverageDecibels:&rightAverage rightChannelPeakDecibels:&rightPeak];
    
    float leftAverageAmplitude = [self amplitudeForDecibels:leftAverage];
    float leftPeakAmplitude = [self amplitudeForDecibels:leftPeak];
    float rightAverageAmplitude = [self amplitudeForDecibels:rightAverage];
    float rightPeakAmplitude = [self amplitudeForDecibels:rightPeak];
        
    static CGFloat leftAverageMaxHeight;
    static CGFloat leftPeakMaxHeight;
    static CGFloat rightAverageMaxHeight;
    static CGFloat rightPeakMaxHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leftAverageMaxHeight = CGRectGetHeight([[self leftAverageMeter] frame]);
        leftPeakMaxHeight = CGRectGetHeight([[self leftPeakMeter] frame]);
        rightAverageMaxHeight = CGRectGetHeight([[self rightAverageMeter] frame]);
        rightPeakMaxHeight = CGRectGetHeight([[self rightPeakMeter] frame]);
    });
    
    CGFloat leftAverageHeight = MAX(1, leftAverageAmplitude * leftAverageMaxHeight);
    CGRect leftAverageFrame = [[self leftAverageMeter] frame];
    leftAverageFrame.origin.y -= leftAverageHeight - leftAverageFrame.size.height;
    leftAverageFrame.size.height = leftAverageHeight;
    [[self leftAverageMeter] setFrame:leftAverageFrame];

    CGFloat leftPeakHeight = MAX(1, leftPeakAmplitude * leftPeakMaxHeight);
    CGRect leftPeakFrame = [[self leftPeakMeter] frame];
    leftPeakFrame.origin.y -= leftPeakHeight - leftPeakFrame.size.height;
    leftPeakFrame.size.height = leftPeakHeight;
    [[self leftPeakMeter] setFrame:leftPeakFrame];

    CGFloat rightAverageHeight = MAX(1, rightAverageAmplitude * rightAverageMaxHeight);
    CGRect rightAverageFrame = [[self rightAverageMeter] frame];
    rightAverageFrame.origin.y -= rightAverageHeight - rightAverageFrame.size.height;
    rightAverageFrame.size.height = rightAverageHeight;
    [[self rightAverageMeter] setFrame:rightAverageFrame];

    CGFloat rightPeakHeight = MAX(1, rightPeakAmplitude * rightPeakMaxHeight);
    CGRect rightPeakFrame = [[self rightPeakMeter] frame];
    rightPeakFrame.origin.y -= rightPeakHeight - rightPeakFrame.size.height;
    rightPeakFrame.size.height = rightPeakHeight;
    [[self rightPeakMeter] setFrame:rightPeakFrame];
}

- (float)amplitudeForDecibels:(float)decibels
{
    return pow(10.0, 0.05 * decibels);
}

- (void)configureTrackProgressView
{
    NKTrackPlayer *player = self.trackListPlayer.trackPlayer;
    
    [[self trackProgressView] setProgress:player.currentTrackAmountDownloaded];
}

@end
