//
//  UIColor+NKSExtensions.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "UIColor+NKSExtensions.h"

@implementation UIColor (NKSExtensions)

+ (UIColor*)rs_highlightColor
{
    static UIColor* highlightColor = nil;
    if (!highlightColor) {
        highlightColor = [UIColor colorWithRed:0x1F/255.0 green:0xA1/255.0 blue:0xF0/255.0 alpha:1];
    }
    return highlightColor;
}

+ (UIColor*)rs_backgroundColor
{
    static UIColor* color = nil;
    if (!color) {
        color = [UIColor colorWithRed:0xF0/255.0 green:0xEF/255.0 blue:0xEE/255.0 alpha:1];
    }
    return color;
}

@end
