//
//  NKStation.h
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NKStation : NSObject<NSCopying>

@property (nonatomic, copy, readonly)   NSString        *ID;

@property (nonatomic, copy, readonly)   NSString        *name;

@property (nonatomic, copy, readonly)   NSString        *type;

@property (nonatomic, copy, readonly)   NSString        *artists;

@property (nonatomic, copy, readonly)   NSString        *summary;

@property (nonatomic, copy, readonly)   NSString        *stationDescription;

@property (nonatomic, copy, readonly)   NSDictionary    *imageURLs;

-(instancetype)initWithID:(NSString*)ID
                     name:(NSString*)name
                     type:(NSString*)type
                  artists:(NSString*)artists
                  summary:(NSString*)summary
       stationDesctiption:(NSString*)stationDescription
                imageURLs:(NSDictionary*)imageURLs;

@end
