//
//  NKSStationPicker.h
//  Station Sample
//
//  Created by Krunoslav Zaher on 1/2/15.
//  Copyright (c) 2015 Napster International. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NKStation;

typedef void (^StationSelectedHandler)(NSString *station);

@interface NKSStationPicker : UIViewController

-(instancetype)initWithNapster:(NKNapster*)napster
         stationSelectedHandler:(StationSelectedHandler)stationSelected;

@end
