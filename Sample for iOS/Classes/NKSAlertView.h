//
//  NKSAlertView.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NKSAlertView : NSObject

@property (nonatomic) UIAlertViewStyle alertViewStyle;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic, copy) void (^willDismissHandler)(NSInteger buttonIndex);
@property (nonatomic, copy) void (^didDismissHandler)(NSInteger buttonIndex);
@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;

- (NSInteger)addButtonWithTitle:(NSString*)title;
- (NSInteger)addButtonWithTitle:(NSString*)title clicked:(void (^)())handler;
- (NSInteger)addButtonWithTitle:(NSString*)title willDismiss:(void (^)())handler;
- (NSInteger)addButtonWithTitle:(NSString*)title didDismiss:(void (^)())handler;
- (NSInteger)addButtonWithTitle:(NSString*)title
                        clicked:(void (^)())clicked
                    willDismiss:(void (^)())willDismiss
                     didDismiss:(void (^)())didDismiss;
- (NSInteger)addCancelButtonWithTitle:(NSString*)title;

- (NSString*)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (UITextField*)textFieldAtIndex:(NSInteger)textFieldIndex;
- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end
