//
//  NKAudioFormat.h
//  NapsterKit
//
//  Created by Emanuel Kotzayan on 9/1/16.
//  Copyright © 2016 Napster International. All rights reserved.
//

@interface NKAudioFormat : NSObject<NSCopying>

+(instancetype)AACPlus64;
+(instancetype)AAC192;
+(instancetype)AAC320;

-(NSComparisonResult)compare:(NKAudioFormat*)other;

@end