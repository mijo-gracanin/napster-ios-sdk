//
//  NKSFavoritesViewController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSFavoritesViewController.h"
#import "NKSLoadingOverlay.h"
#import "NKSFavoriteTrackTableCell.h"
#import "NKSAlertView.h"
#import "NKSAppDelegate.h"
#import "NKNapster+Extensions.h"
#import "NKTrackListPlayer.h"

@interface NKSFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) NKSLoadingOverlay* loadingOverlay;
@property (nonatomic) NSArray* tracks;

@property (nonatomic, strong) NKNapster *napster;

@property (nonatomic, copy) NKSFavoritesViewControllerSelectedListPlayer selectedTrackListPlayer;

@end

@implementation NKSFavoritesViewController

- (id)initWithNapster:(NKNapster*)napster selectedTrackListPlayer:(NKSFavoritesViewControllerSelectedListPlayer)trackListPlayer
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    
    [self setTitle:NSLocalizedString(@"Favorites", nil)];
    
    self.napster = napster;
    self.selectedTrackListPlayer = trackListPlayer;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonTapped:)]];
    
    [[self tableView] registerNib:[UINib nibWithNibName:@"NKSFavoriteTrackTableCell" bundle:nil] forCellReuseIdentifier:@"NKSFavoriteTrackTableCell"];
    [[self tableView] setBackgroundColor:[UIColor rs_backgroundColor]];
    
    [self setLoadingOverlay:[NKSLoadingOverlay overlayAddedToView:[self view]]];
    
    __weak NKSFavoritesViewController* viewController = self;

    [self.napster rs_favoritesInLibrary:^(NSArray *tracks, NSError *error) {
        
        [self.loadingOverlay removeFromSuperview];
        [self setLoadingOverlay: nil];
        
        [viewController setTracks: tracks];
        [[viewController tableView] reloadData];

    }];
}

#pragma mark - Table view data source / delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tracks] count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NKSFavoriteTrackTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NKSFavoriteTrackTableCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NKTrackListPlayer *trackListPlayer = [[NKTrackListPlayer alloc] initWithNapster:self.napster
                                                                           containerID:nil
                                                              andSequencingContextSize:2];
    
    [trackListPlayer playTracks:self.tracks
                        startingWith:self.tracks[indexPath.row]
                         fromContext:nil];

    self.selectedTrackListPlayer(trackListPlayer);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)dismissButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers

- (void)configureCell:(NKSFavoriteTrackTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NKTrack* track = [[self tracks] objectAtIndex:[indexPath row]];
    [[cell trackNameLabel] setText:[track name]];
    [[cell artistNameLabel] setText:[[track artist] name]];
    [[cell albumNameLabel] setText:[[track album] name]];
}

@end
