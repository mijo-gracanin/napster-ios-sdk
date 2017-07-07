//
//  NKSTrackPlaybackRootViewController.m
//  NapsterKit
//
//  Copyright (c) 2014 Napster International Inc. All rights reserved.
//


#import "NKSTrackPlaybackRootViewController.h"
#import "NKSManualPlayerViewController.h"
#import "NKSAlertView.h"
#import "NKSLoadingOverlay.h"
#import "NKSQueueTableCell.h"
#import "NKTrackListPlayer.h"
#import "NKSNetworkActivityIndicatorController.h"
#import "NKSFavoritesViewController.h"
#import "NKAPI+Parsing.h"
#import "NKNapster+Extensions.h"
#import "NKSAppDelegate.h"

// Number of songs that will be calculated using TrackListPlayer
// It is the number of forward and backward songs that the
// sequencers will calculate.
#define NUMBER_OF_CONTEXT_SONGS     2

@interface NKSTrackPlaybackRootViewController ()

@property (weak, nonatomic    ) IBOutlet UIView       *contentContainer;
@property (weak, nonatomic    ) IBOutlet UIView       *playerContainer;

@property (nonatomic, strong  ) NKTrackListPlayer    *trackListPlayer;

@property (nonatomic          ) NSMutableArray        *tracks;
@property (weak, nonatomic    ) NKSLoadingOverlay      *loadingOverlay;

@property (nonatomic, readonly) NKTrackPlayer        *player;

@property (weak, nonatomic    ) IBOutlet UITableView  *tableView;

@property (weak, nonatomic    ) NKSManualPlayerViewController  *playerVC;

@end

@implementation NKSTrackPlaybackRootViewController

- (instancetype)initWithNapster:(NKNapster*)napster
{
    self = [super initWithNapster:napster andNibNamed:@"NKSTrackPlaybackRootView"];
    if (!self) return nil;

    self.title = NSLocalizedString(@"Queue", nil);
    
    self.trackListPlayer = [[NKTrackListPlayer alloc] initWithNapster:self.napster
                                                           containerID:nil
                                              andSequencingContextSize:NUMBER_OF_CONTEXT_SONGS];
    
    self.tracks = [NSMutableArray new];
    
    [self.napster.notificationCenter addObserver:self
                                         selector:@selector(currentTrackDidChange:)
                                             name:NKNotificationCurrentTrackChanged
                                           object:nil];
    [self.napster.notificationCenter addObserver:self
                                         selector:@selector(currentTrackDidChange:)
                                             name:NKTrackListNotificationCurrentTrackChanged
                                           object:nil];
    return self;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateVisibleCells];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NKSManualPlayerViewController* playerViewController = [[NKSManualPlayerViewController alloc] initWithTrackListPlayer:self.trackListPlayer];
    
    [self addChildViewController:playerViewController];
    playerViewController.view.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:playerViewController.view];
    [playerViewController didMoveToParentViewController:self];
    
    self.playerVC = playerViewController;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorites", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showFavorites:)];
    
    [[self tableView] registerNib:[UINib nibWithNibName:@"NKSQueueTableCell" bundle:nil] forCellReuseIdentifier:@"NKSQueueTableCell"];
    [[self tableView] setBackgroundColor:[UIColor rs_backgroundColor]];
    [[self tableView] setEditing:YES];
    
    [self setLoadingOverlay:[NKSLoadingOverlay overlayAddedToView:[self view]]];
    
    NKNapster *napster = self.trackListPlayer.napster;
    
    [napster requestForMethod:NKHTTPMethodGET
                          path:@"tracks/top"
                 authenticated:NO
                        params:@{ @"limit": @(10), @"offset" : @(0), @"include":@"artists,albums"}
                    completion:^(NSDictionary* tracksDict, NSError* error) {
        __weak NKSTrackPlaybackRootViewController* viewController = self;
                        
        [NKSNetworkActivityIndicatorController decrementActivities];
        [[viewController loadingOverlay] setHidden:YES];
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
                        
        NSArray* tracks = [tracksDict objectForKey: @"tracks"];
        if (!tracks) {
            NSLog(@"Error: no tracks");
            return;
        }
                        
        for (NSDictionary *trackJson in tracks) {
            NKTrack *track = [NKTrack parseFromJson:trackJson];
            
            if (track != nil) {
                [viewController.tracks addObject:track];
            }
        }
        [viewController.tableView reloadData];
    }];
    
}

-(void)dealloc {
    [self.napster.notificationCenter removeObserver:self];
}

#pragma mark - Actions

- (IBAction)showFavorites:(id)sender
{
    if (!self.napster.isSessionOpen) {
        NKSAlertView* alertView = [NKSAlertView new];
        [alertView setMessage:NSLocalizedString(@"Sign in with your Napster account to view your favorites. Or download the Napster app to sign up.", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"Sign In", nil) clicked:^{
            [self signIn];
        }];
        [alertView addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [alertView show];
        return;
    }
    
    NKSFavoritesViewController* favoritesViewController = [[NKSFavoritesViewController alloc] initWithNapster:self.napster
                                                                                     selectedTrackListPlayer:^(NKTrackListPlayer *trackListPlayer) {
        self.trackListPlayer = trackListPlayer;
        self.tracks = trackListPlayer.tracks.mutableCopy;
        [self.playerVC setTrackListPlayer: trackListPlayer];
        [self.tableView reloadData];
    }];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];
    [[self navigationController] presentViewController:navController animated:YES completion:nil];
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
    NKSQueueTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NKSQueueTableCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath
{
    if ([sourceIndexPath isEqual:destinationIndexPath]) return;
        
    NKTrack* movedTrack = [[self tracks] objectAtIndex:[sourceIndexPath row]];
    NSInteger sourceRow = sourceIndexPath.row;
    NSInteger destinationRow = destinationIndexPath.row;
    [self.tracks removeObjectAtIndex:sourceRow];
    [self.tracks insertObject:movedTrack atIndex:destinationRow];

    self.trackListPlayer.tracks = self.tracks;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [[self tracks] removeObjectAtIndex:[indexPath row]];
    [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.trackListPlayer.tracks = self.tracks;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NKTrack *track = [self.tracks objectAtIndex:indexPath.row];
    [self.trackListPlayer playTracks:self.tracks
                        startingWith:track
                         fromContext:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
    NKTrack* track = [[self tracks] objectAtIndex:[indexPath row]];
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak id wSelf = self;
    
    UIAlertAction* addAction = [UIAlertAction actionWithTitle:@"Add to Favorites" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          id sSelf = wSelf;
                                                          [sSelf addTrackToFavorites:track];
                                                      }];
    
    [actionSheet addAction:addAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action) {  }];
    
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Notification handlers

- (void)currentTrackDidChange:(NSNotification*)notification
{
    [self.view setNeedsLayout];
}

#pragma mark - Helpers

- (void)configureCell:(NKSQueueTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NKTrack* track = [[self tracks] objectAtIndex:[indexPath row]];
    [cell setTrack:track];
    
    BOOL isPlayingTrack = [self.trackListPlayer isPlayingTrack:track];
    
    [[cell playingIndicator] setHidden:!isPlayingTrack];
    
    [cell setNeedsLayout];
}

- (void)updateVisibleCells
{
    NSArray* cells = [[self tableView] visibleCells];
    for (NKSQueueTableCell* cell in cells) {
        NSIndexPath* indexPath = [[self tableView] indexPathForCell:cell];
        [self configureCell:cell atIndexPath:indexPath];
    }
}

- (void)addTrackToFavorites:(NKTrack*)track
{
    if (!self.napster.isSessionOpen) {
        NKSAlertView* alertView = [NKSAlertView new];
        [alertView setMessage:NSLocalizedString(@"Sign in with your Napster account to add to your favorites. Or download the Napster app to sign up.", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"Sign In", nil) clicked:^{
            [self signIn];
        }];
        [alertView addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [alertView show];
        return;
    }
    
    [self.napster rs_addToFavoritesWithTrackID:track.ID completion:^(NSError *error) {
        if (error) {
            NSLog(@"Failed to add %@ to favorites. Error: %@", track.ID, error);
            return;
        }
        NSLog(@"Added %@ to favorites.", track.ID);

    }];
    
}

@end
