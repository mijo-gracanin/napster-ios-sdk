//
//  NKSFavoriteTrackTableCell.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface NKSFavoriteTrackTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* albumNameLabel;

@end
