//
//  NKSLoadingOverlay.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSLoadingOverlay.h"
#import "UIColor+NKSExtensions.h"

@interface NKSLoadingOverlay ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NKSLoadingOverlay

+ (NKSLoadingOverlay*)overlay
{
    NKSLoadingOverlay* overlay = [[[NSBundle mainBundle] loadNibNamed:@"NKSLoadingOverlay" owner:self options:nil] objectAtIndex:0];
    [overlay setBackgroundColor:[UIColor rs_backgroundColor]];
    return overlay;
}

+ (NKSLoadingOverlay*)overlayAddedAboveView:(UIView*)siblingView
{
    NKSLoadingOverlay* overlay = [self overlay];
    UIView* view = [siblingView superview];
    [view insertSubview:overlay aboveSubview:siblingView];
    [overlay setFrame:[view bounds]];
    return overlay;
}

+ (NKSLoadingOverlay*)overlayAddedToView:(UIView*)view
{
    NKSLoadingOverlay* overlay = [self overlay];
    [view addSubview:overlay];
    [overlay setFrame:[view bounds]];
    return overlay;
}

@end
