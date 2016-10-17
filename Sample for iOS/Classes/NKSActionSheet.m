//
//  NKSActionSheet.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSActionSheet.h"

@interface NKSActionSheet () <UIActionSheetDelegate>

@property (nonatomic) UIActionSheet* actionSheet;
@property (nonatomic) NSMutableDictionary* clickedHandlersByButtonIndex;
@property (nonatomic) NSMutableDictionary* willDismissHandlersByButtonIndex;
@property (nonatomic) NSMutableDictionary* didDismissHandlersByButtonIndex;

@end

@implementation NKSActionSheet

+ (NSMutableSet*)actionSheets
{
    static NSMutableSet* _actionSheets = nil;
    if (!_actionSheets) {
        _actionSheets = [NSMutableSet set];
    }
    return _actionSheets;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    [self setClickedHandlersByButtonIndex:[NSMutableDictionary dictionary]];
    [self setWillDismissHandlersByButtonIndex:[NSMutableDictionary dictionary]];
    [self setDidDismissHandlersByButtonIndex:[NSMutableDictionary dictionary]];
    [self setActionSheet:[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]];
    
    return self;
}

- (void)setTitle:(NSString*)title
{
    [[self actionSheet] setTitle:title];
}

- (NSString*)title
{
    return [[self actionSheet] title];
}

- (BOOL)isVisible
{
    return [[self actionSheet] isVisible];
}

- (void)setActionSheetStyle:(UIActionSheetStyle)actionSheetStyle
{
    [[self actionSheet] setActionSheetStyle:actionSheetStyle];
}

- (UIActionSheetStyle)actionSheetStyle
{
    return [[self actionSheet] actionSheetStyle];
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
    NSInteger buttonIndex = [[self actionSheet] addButtonWithTitle:title];
        
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

- (NSInteger)numberOfButtons
{
    return [[self actionSheet] numberOfButtons];
}

- (NSString*)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    return [[self actionSheet] buttonTitleAtIndex:buttonIndex];
}

- (NSInteger)cancelButtonIndex
{
    return [[self actionSheet] cancelButtonIndex];
}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex
{
    [[self actionSheet] setCancelButtonIndex:cancelButtonIndex];
}

- (NSInteger)destructiveButtonIndex
{
    return [[self actionSheet] destructiveButtonIndex];
}

- (void)setDestructiveButtonIndex:(NSInteger)destructiveButtonIndex
{
    [[self actionSheet] setDestructiveButtonIndex:destructiveButtonIndex];
}

- (NSInteger)firstOtherButtonIndex
{
    return [[self actionSheet] firstOtherButtonIndex];
}

- (void)showFromTabBar:(UITabBar*)view
{
    [[[self class] actionSheets] addObject:self];
    [[self actionSheet] showFromTabBar:view];
}

- (void)showFromToolbar:(UIToolbar*)view
{
    [[[self class] actionSheets] addObject:self];
    [[self actionSheet] showFromToolbar:view];
}

- (void)showInView:(UIView*)view
{
    [[[self class] actionSheets] addObject:self];
    [[self actionSheet] showInView:view];
}

- (void)showFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated
{
    [[[self class] actionSheets] addObject:self];
    [[self actionSheet] showFromBarButtonItem:item animated:animated];
}

- (void)showFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated
{
    [[[self class] actionSheets] addObject:self];
    [[self actionSheet] showFromRect:rect inView:view animated:animated];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [[self actionSheet] dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^handler)() = [self clickedHandlersByButtonIndex][@(buttonIndex)];
    if (handler) handler();
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self willDismissHandler]) [self willDismissHandler](buttonIndex);
    
    void (^handler)() = [self willDismissHandlersByButtonIndex][@(buttonIndex)];
    if (handler) handler();
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self didDismissHandler]) [self didDismissHandler](buttonIndex);
    
    void (^handler)() = [self didDismissHandlersByButtonIndex][@(buttonIndex)];
    if (handler) handler();
    
    [[[self class] actionSheets] removeObject:self];
}

@end
