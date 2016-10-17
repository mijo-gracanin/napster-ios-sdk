//
//  NKAudioFormat.h
//  NapsterKit
//
//  Created by Emanuel Kotzayan on 9/1/16.
//  Copyright © 2016 Napster International. All rights reserved.
//

#import "NKAudioFormat.h"

@interface NKAudioFormat()

@property (nonatomic, copy)   NSString        *codec;

@property (nonatomic)         NSInteger       bitrate;

-(instancetype)initWithCodec:(NSString*)codec bitrate:(NSInteger)bitrate;

-(NSComparisonResult)compare:(NKAudioFormat*)other;

+(NKAudioFormat*)bestFormatWithDesiredFormat: (NKAudioFormat*)desiredFormat availableFormats: (NSArray*) availableFormats;

@end