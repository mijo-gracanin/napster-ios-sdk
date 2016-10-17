//
//  NSArray+NKSExtensions.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSArray (NKExtensions)

- (NSArray*)rk_map:(id (^)(id obj))selector;

- (NSArray*)rk_filter:(BOOL (^)(id obj))condition;

- (NSArray*)rk_take:(NSUInteger)takeFirst;

- (NSArray*)rk_reverse;

- (id)rk_firstOrNil;

@end
