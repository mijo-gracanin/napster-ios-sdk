//
//  NKSNetworkActivityIndicatorController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSNetworkActivityIndicatorController.h"

@interface NKSNetworkActivityIndicatorController ()

@property (assign, nonatomic) NSUInteger activitiesCount;
@property (nonatomic) NSDate* lastUpdatedIndicatorAt;

@end

@implementation NKSNetworkActivityIndicatorController

+ (NKSNetworkActivityIndicatorController*)shared
{
    static NKSNetworkActivityIndicatorController* _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [self new];
    });
    return _shared;
}

+ (void)incrementActivities
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NKSNetworkActivityIndicatorController* controller = [self shared];
        [controller setActivitiesCount:[controller activitiesCount] + 1];
    });
}

+ (void)decrementActivities
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NKSNetworkActivityIndicatorController* controller = [self shared];
        [controller setActivitiesCount:[controller activitiesCount] - 1];
    });
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(napsterNetworkActivityBegan:) name:NKNotificationNetworkRequestBegan object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(napsterNetworkActivityEnded:) name:NKNotificationNetworkRequestEnded object:nil];
    
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setActivitiesCount:(NSUInteger)activitiesCount
{
    if (activitiesCount == [self activitiesCount]) return;
    _activitiesCount = activitiesCount;
    [self activitiesCountDidChange];
}

- (void)activitiesCountDidChange
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateIndicator) object:nil];
    
    BOOL shouldIndicatorBeVisible = [self activitiesCount] > 0;
    UIApplication* application = [UIApplication sharedApplication];
    if ([application isNetworkActivityIndicatorVisible] == shouldIndicatorBeVisible) {
        return;
    }
    
    NSTimeInterval minTimeHidingIndicator = 0.5;
    NSTimeInterval minTimeShowingIndicator = 1.0;
    NSTimeInterval minDelayBeforeHiding = 0.5; // When hiding we don't hide the indicator immediately (even if the minimum time has passed since showing the indicator) so that if another request starts very soon, the indicator will remain visible until that new request finishes.
    
    NSTimeInterval timeSinceLastUpdate;
    if ([self lastUpdatedIndicatorAt]) {
        timeSinceLastUpdate = -[[self lastUpdatedIndicatorAt] timeIntervalSinceNow];
    } else {
        timeSinceLastUpdate = NSTimeIntervalSince1970;
    }
    
    NSTimeInterval delay = 0;
    if (shouldIndicatorBeVisible && timeSinceLastUpdate < minTimeHidingIndicator) {
        delay = minTimeHidingIndicator - timeSinceLastUpdate;
    } else if (!shouldIndicatorBeVisible && timeSinceLastUpdate < minTimeShowingIndicator) {
        delay = minTimeShowingIndicator - timeSinceLastUpdate;
    }
    if (!shouldIndicatorBeVisible && delay <= minDelayBeforeHiding) {
        delay = minDelayBeforeHiding;
    }
    
    [self performSelector:@selector(updateIndicator) withObject:nil afterDelay:delay];
}

- (void)updateIndicator
{
    [self setLastUpdatedIndicatorAt:[NSDate date]];
    UIApplication* application = [UIApplication sharedApplication];
    [application setNetworkActivityIndicatorVisible:[self activitiesCount] > 0];
}

#pragma mark - Notification handlers

+ (void)napsterNetworkActivityBegan:(NSNotification*)notification
{
    [self incrementActivities];
}

+ (void)napsterNetworkActivityEnded:(NSNotification*)notification
{
    [self decrementActivities];
}

@end
