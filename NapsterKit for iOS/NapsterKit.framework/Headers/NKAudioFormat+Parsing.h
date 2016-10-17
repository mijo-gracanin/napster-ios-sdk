//
//  NKAudioFormat+Parsing.h
//  NapsterKit
//
//  Created by Emanuel Kotzayan on 9/8/16.
//  Copyright © 2016 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKAudioFormat.h"

@interface NKAudioFormat (Parsing)

+(instancetype)parseFromJson:(id)json;

@end
