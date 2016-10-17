//
//  NKNaturalSequencing.h
//  Sample
//
//  Created by Krunoslav Zaher on 9/3/14.
//  Copyright (c) 2014 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKSequencingAlgorithm.h"

@interface NKNaturalSequencing : NSObject<NKSequencingAlgorithm>

-(instancetype)initWithTrackListPlayer:(NKTrackListPlayer*)trackListPlayer;

@end
