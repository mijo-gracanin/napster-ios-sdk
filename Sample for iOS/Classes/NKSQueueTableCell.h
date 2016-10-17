//
//  NKSQueueTableCell.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@class NKTrack;

@interface NKSQueueTableCell : UITableViewCell

@property (nonatomic) NKTrack* track;
@property (weak, nonatomic) IBOutlet UIImageView* playingIndicator;

@end
