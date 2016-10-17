//
//  NSArray+NKSExtensions.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NSArray+NKExtensions.h"

@implementation NSArray (NKExtensions)

- (NSArray*)rk_map:(id (^)(id obj))selector
{
    NSMutableArray* result = [NSMutableArray array];
    
    for(id obj in self) {
        id mapped = selector(obj);
        if (mapped) {
            [result addObject:mapped];
        }
    }
    
    return result;
}

- (NSArray*)rk_filter:(BOOL (^)(id obj))condition {
    NSMutableArray* result = [NSMutableArray array];
    
    for(id obj in self) {
        if (condition(obj)) {
            [result addObject:obj];
        }
    }
    
    return result;
}

- (NSArray*)rk_take:(NSUInteger)take {
    return [self subarrayWithRange:NSMakeRange(0, MIN(take, self.count))];
}

- (NSArray*)rk_reverse {
    NSMutableArray* result = [NSMutableArray array];
    
    for (id object in self.reverseObjectEnumerator) {
        [result addObject:object];
    }
    
    return result;
}

- (id)rk_firstOrNil {
    if (self.count == 0) {
        return nil;
    }
    
    return self[0];
}

@end
