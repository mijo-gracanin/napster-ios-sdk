//
//  NKSequencingContext.m
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import "NKSequencingContext.h"

@interface NKSequencingContext()

@property (nonatomic, copy)   NSArray *previousItems;
@property (nonatomic, copy)   NKSequenceItem *currentItem;
@property (nonatomic, copy)   NSArray *nextItems;

@end

@implementation NKSequencingContext

+(NKSequencingContext*)sequencingContextWithPreviousItems:(NSArray*)previousItems
                                             currrentItem:(NKSequenceItem*)currentItem
                                                nextItems:(NSArray*)nextItems {
    NKSequencingContext *context = [[self alloc] init];
    
    context.previousItems = previousItems;
    context.currentItem = currentItem;
    context.nextItems = nextItems;
    
    return context;
}

@end
