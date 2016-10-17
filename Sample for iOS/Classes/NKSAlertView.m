//
//  NKSAlertView.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSAlertView.h"

@interface NKSAlertView () <UIAlertViewDelegate>

@property (nonatomic) UIAlertView* alertView;
@property (nonatomic) NSMutableDictionary* clickedHandlersByButtonIndex;
@property (nonatomic) NSMutableDictionary* willDismissHandlersByButtonIndex;
@property (nonatomic) NSMutableDictionary* didDismissHandlersByButtonIndex;

@end

@implementation NKSAlertView

+ (NSMutableSet*)alertViews
{
    static NSMutableSet* _alertViews = nil;
    if (!_alertViews) {
        _alertViews = [NSMutableSet set];
    }
    return _alertViews;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    [self setClickedHandlersByButtonIndex:[NSMutableDictionary dictionary]];
    [self setWillDismissHandlersByButtonIndex:[NSMutableDictionary dictionary]];
    [self setDidDismissHandlersByButtonIndex:[NSMutableDictionary dictionary]];
    [self setAlertView:[[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil]];
    
    return self;
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
    [[self alertView] setAlertViewStyle:alertViewStyle];
}

- (UIAlertViewStyle)alertViewStyle
{
    return [[self alertView] alertViewStyle];
}

- (void)setTitle:(NSString*)title
{
    [[self alertView] setTitle:title];
}

- (NSString*)title
{
    return [[self alertView] title];
}

- (void)setMessage:(NSString*)message
{
    [[self alertView] setMessage:message];
}

- (NSString*)message{
    return [[self alertView] message];
}

- (BOOL)isVisible
{
    return [[self alertView] isVisible];
}

- (NSInteger)numberOfButtons
{
    return [[self alertView] numberOfButtons];
}

- (NSString*)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    return [[self alertView] buttonTitleAtIndex:buttonIndex];
}

- (UITextField*)textFieldAtIndex:(NSInteger)textFieldIndex
{
    return [[self alertView] textFieldAtIndex:textFieldIndex];
}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex
{
    [[self alertView] setCancelButtonIndex:cancelButtonIndex];
}

- (NSInteger)cancelButtonIndex
{
    return [[self alertView] cancelButtonIndex];
}

- (NSInteger)firstOtherButtonIndex
{
    return [[self alertView] firstOtherButtonIndex];
}

- (void)show
{
    [[self alertView] show];
    [[[self class] alertViews] addObject:self];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [[self alertView] dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

- (NSInteger)addButtonWithTitle:(NSString*)title
{
    return [self addButtonWithTitle:title clicked:nil willDismiss:nil didDismiss:nil];
}

- (NSInteger)addButtonWithTitle:(NSString*)title clicked:(void (^)())handler
{
    return [self addButtonWithTitle:title clicked:handler willDismiss:nil didDismiss:nil];
}

- (NSInteger)addButtonWithTitle:(NSString*)title willDismiss:(void (^)())handler
{
    return [self addButtonWithTitle:title clicked:nil willDismiss:handler didDismiss:nil];
}

- (NSInteger)addButtonWithTitle:(NSString*)title didDismiss:(void (^)())handler
{
    return [self addButtonWithTitle:title clicked:nil willDismiss:nil didDismiss:handler];
}

- (NSInteger)addButtonWithTitle:(NSString*)title
                 clicked:(void (^)())clickedHandler
             willDismiss:(void (^)())willDismissHandler
              didDismiss:(void (^)())didDismissHandler
{
    NSInteger buttonIndex = [[self alertView] addButtonWithTitle:title];
        
    [self setHandler:clickedHandler buttonIndex:buttonIndex dictionary:[self clickedHandlersByButtonIndex]];
    [self setHandler:willDismissHandler buttonIndex:buttonIndex dictionary:[self willDismissHandlersByButtonIndex]];
    [self setHandler:didDismissHandler buttonIndex:buttonIndex dictionary:[self didDismissHandlersByButtonIndex]];
    
    return buttonIndex;
}

- (NSInteger)addCancelButtonWithTitle:(NSString*)title
{
    NSUInteger buttonIndex = [self addButtonWithTitle:title];
    [self setCancelButtonIndex:buttonIndex];
    return buttonIndex;
}

- (void)setHandler:(void (^)())handler buttonIndex:(NSInteger)buttonIndex dictionary:(NSMutableDictionary*)dictionary
{
    if (handler) {
        dictionary[@(buttonIndex)] = [handler copy];
    } else {
        [dictionary removeObjectForKey:@(buttonIndex)];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^handler)() = [self clickedHandlersByButtonIndex][@(buttonIndex)];
    if (handler) handler();
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self willDismissHandler]) [self willDismissHandler](buttonIndex);
    
    void (^handler)() = [self willDismissHandlersByButtonIndex][@(buttonIndex)];
    if (handler) handler();
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self didDismissHandler]) [self didDismissHandler](buttonIndex);
    
    void (^handler)() = [self didDismissHandlersByButtonIndex][@(buttonIndex)];
    if (handler) handler();
    
    [[[self class] alertViews] removeObject:self];
}

@end
