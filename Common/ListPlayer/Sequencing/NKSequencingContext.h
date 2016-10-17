//
//  NKSequencingContext.h
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NKSequenceItem;

@interface NKSequencingContext : NSObject

@property (nonatomic, copy, readonly)   NSArray *previousItems;
@property (nonatomic, copy, readonly)   NKSequenceItem *currentItem;
@property (nonatomic, copy, readonly)   NSArray *nextItems;

+(NKSequencingContext*)sequencingContextWithPreviousItems:(NSArray*)previousItems
                                             currrentItem:(NKSequenceItem*)currentItem
                                                nextItems:(NSArray*)nextItems;

@end
