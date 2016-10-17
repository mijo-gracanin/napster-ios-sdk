//
//  NKSLoadingOverlay.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface NKSLoadingOverlay : UIView

+ (NKSLoadingOverlay*)overlay;
+ (NKSLoadingOverlay*)overlayAddedAboveView:(UIView*)siblingView;
+ (NKSLoadingOverlay*)overlayAddedToView:(UIView*)view;

@end
