//
//  NKSTrack+Favorites.h
//  Track Playback Sample
//
//  Created by Emanuel Kotzayan on 9/7/16.
//  Copyright © 2016 Napster International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKTrack (Favorites)

+(instancetype)parseFromFavoriteJson:(NSDictionary*)json;

@end
