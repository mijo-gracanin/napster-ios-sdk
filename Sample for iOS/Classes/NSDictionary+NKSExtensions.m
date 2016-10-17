//
//  NSDictionary+NKSExtensions.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NSDictionary+NKSExtensions.h"

@implementation NSDictionary (NKSExtensions)

+ (NSDictionary*)rs_dictionaryWithQuery:(NSString*)query
{
    NSArray* pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:[pairs count]];
    for (NSString* pair in pairs) {
        NSArray* components = [pair componentsSeparatedByString:@"="];
        if ([components count] != 2) continue;
        NSString* name = [[components objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString* value = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id existingValue = [params objectForKey:name];
        if (!existingValue) {
            [params setObject:value forKey:name];
            continue;
        }
        if ([existingValue isKindOfClass:[NSArray class]]) {
            NSArray* values = [existingValue arrayByAddingObject:value];
            [params setObject:values forKey:name];
            continue;
        }
        NSArray* values = @[existingValue, value];
        [params setObject:values forKey:name];
    }
    return params;
}

@end
