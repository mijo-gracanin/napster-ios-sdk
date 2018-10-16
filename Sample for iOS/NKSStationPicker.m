//
//  NKSStationPicker.m
//  Station Sample
//
//  Created by Krunoslav Zaher on 1/2/15.
//  Copyright (c) 2015 Napster International. All rights reserved.
//

#import "NKSStationPicker.h"
#import "NSArray+NKExtensions.h"

@interface NKSStationPicker () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NKNapster               *napster;
@property (nonatomic, copy)   StationSelectedHandler    stationSelected;

#pragma mark - Views

@property (nonatomic, weak)   IBOutlet UITableView   *tableView;

#pragma mark - Model

@property (nonatomic, strong) NSArray       *artistStations;

@property (nonatomic, strong) NSArray       *trackStations;

@property (nonatomic, strong) NSArray       *topStations;

@property (nonatomic, readonly) NSArray     *allStations;

@end

@implementation NKSStationPicker

-(instancetype)initWithNapster:(NKNapster*)napster
         stationSelectedHandler:(StationSelectedHandler)stationSelected {
    self = [super initWithNibName:@"NKSStationPicker" bundle:nil];
    if (!self) return nil;
 
    self.napster        = napster;
    self.stationSelected = stationSelected;
    
    self.navigationItem.title = @"Pick Station";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancel:)];
 
    [self.napster requestForMethod:NKHTTPMethodGET
                               path:@"stations/top"
                      authenticated:NO params:@{
                                                @"limit": @(5)
                                                }
                         completion:^(NSDictionary *topStationsJson, NSError *error) {
                             if (!topStationsJson) {
                                 [self errorFetching:error];
                                 return;
                             }
                             
                             NSArray* topStations = [topStationsJson objectForKey:@"stations"];

                             if (!topStations) {
                                 [self errorFetching:error];
                                 return;
                             }
                             
                             NSArray *parsedStations = [topStations rk_map:^id(id obj) {
                                 return [NKStation parseFromJson:obj];
                             }];
                             
                             [self fetchedTopStations:parsedStations];
                         }];
    
    [self.napster requestForMethod:NKHTTPMethodGET
                               path:@"artists/top"
                      authenticated:NO params:@{
                                                @"limit": @(5)
                                                }
                         completion:^(NSDictionary *artistsJson, NSError *error) {
                             if (!artistsJson) {
                                 [self errorFetching:error];
                                 return;
                             }
                             
                             NSArray* topArtists = [artistsJson objectForKey:@"artists"];
                             
                             if (!topArtists) {
                                 [self errorFetching:error];
                                 return;
                             }
                             
                             NSArray *parsedArtists = [topArtists rk_map:^(id json) {
                                 NSString* artistID = [json objectForKey: @"id"];
                                 NSString* artistName = [json objectForKey: @"name"];
                                 
                                 return [[NKArtistStub alloc] initWithID: artistID name: artistName];
                             }];
                             
                             [self fetchedTopArtists:parsedArtists];
                         }];
    
    [self.napster requestForMethod:NKHTTPMethodGET
                               path:@"tracks/top"
                      authenticated:NO
                             params:@{
                                      @"limit": @(5),
                                      @"include": @"artists,albums"
                                      }
                         completion:^(NSDictionary *tracksJson, NSError *error) {
                             if (!tracksJson) {
                                 [self errorFetching:error];
                                 return;
                             }
                             
                             NSArray* topTracks = [tracksJson objectForKey:@"tracks"];
                             
                             if (!topTracks) {
                                 [self errorFetching:error];
                                 return;
                             }
                             
                             NSArray *parsedTracks = [topTracks rk_map:^(id json) {
                                 NKTrack *track = [NKTrack parseFromJson:json error:nil];
                                 return track;
                             }];
                             
                             [self fetchedTopTracks:parsedTracks];
                         }];
    
    
    self.artistStations = @[];
    self.trackStations  = @[];
    self.topStations    = @[];
    
    return self;
}

-(void)errorFetching:(NSError*)error {
    NSLog(@"Error while fetching data: %@", error);
}

-(void)fetchedTopArtists:(NSArray*)topArtists {
    self.artistStations = topArtists;
    
    [self updateView];
}

-(void)fetchedTopTracks:(NSArray*)topTracks {
    self.trackStations = topTracks;
    
    [self updateView];
}

-(void)fetchedTopStations:(NSArray*)topStations {
    self.topStations = topStations;
    
    [self updateView];
}

-(void)updateView {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)cancel:(id)sender {
    [self close];
}

-(void)close {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

-(NSArray*)allStations {
    return @[self.artistStations, self.trackStations, self.topStations];
}

-(id)stationForIndexPath:(NSIndexPath*)indexPath {
    NSArray *stations = self.allStations[indexPath.section];
    return stations[indexPath.row];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    id station = [self stationForIndexPath:indexPath];
   
    NSString *text = nil;
    
    if ([station isKindOfClass:NKArtistStub.class]) {
        text = ((NKArtistStub*)station).name;
    }
    else if ([station isKindOfClass:NKTrack.class]) {
        text = ((NKTrack*)station).name;
    }
    else if ([station isKindOfClass:NKStation.class]) {
        text = ((NKStation*)station).name;
    }
    else {
        NSAssert(0, @"");
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.artistStations.count;
    }
    else if (section == 1) {
        return self.trackStations.count;
    }
    else if (section == 2) {
        return self.topStations.count;
    }
    else {
        NSAssert(section <= 2, @"Index path wrong");
        return 0;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Artist stations";
    }
    else if (section == 1) {
        return @"Track stations";
    }
    else if (section == 2) {
        return @"Top Stations";
    }
    else {
        NSAssert(section <= 2, @"Index path wrong");
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id station = [self stationForIndexPath:indexPath];
    NSString *stationID = nil;
    
    if ([station isKindOfClass:NKArtistStub.class]) {
        stationID = ((NKArtistStub*)station).ID;
    }
    else if ([station isKindOfClass:NKTrack.class]) {
        stationID = ((NKTrack*)station).ID;
    }
    else if ([station isKindOfClass:NKStation.class]) {
        stationID = ((NKStation*)station).ID;
    }
    else {
        NSAssert(0, @"");
    }
    
    self.stationSelected(stationID);
    [self close];
}

@end
