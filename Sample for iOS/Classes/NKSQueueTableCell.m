//
//  NKSQueueTableCell.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSQueueTableCell.h"

@interface NKSQueueTableCell ()

@property (weak, nonatomic) IBOutlet UILabel* trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* albumNameLabel;

@end

@implementation NKSQueueTableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setBackgroundView:[[UIView alloc] init]];
    [[self backgroundView] setBackgroundColor:[UIColor rs_backgroundColor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect trackFrame = [[self trackNameLabel] frame];
    CGRect artistFrame = [[self artistNameLabel] frame];
    CGRect albumFrame = [[self albumNameLabel] frame];
    CGRect playingIndicatorFrame = [[self playingIndicator] frame];
    
    static CGFloat trackNameToPlayingIndicatorPadding;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trackNameToPlayingIndicatorPadding = CGRectGetMinX(playingIndicatorFrame) - CGRectGetMaxX(trackFrame);
    });
    
    if ([[self playingIndicator] isHidden]) {
        trackFrame.size.width = CGRectGetMaxX(playingIndicatorFrame) - CGRectGetMinX(trackFrame);
    } else {
        trackFrame.size.width = CGRectGetMinX(playingIndicatorFrame) - trackNameToPlayingIndicatorPadding - CGRectGetMinX(trackFrame);
    }
    
    artistFrame.size.width = trackFrame.size.width;
    albumFrame.size.width = trackFrame.size.width;
    
    [[self trackNameLabel] setFrame:trackFrame];
    [[self artistNameLabel] setFrame:artistFrame];
    [[self albumNameLabel] setFrame:albumFrame];
}

- (void)setTrack:(NKTrack*)track
{
    _track = track;
    
    self.trackNameLabel.text = track.name;
    self.artistNameLabel.text = track.artist.name;
    self.albumNameLabel.text = track.album.name;
}

@end
