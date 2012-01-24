//
//  JSViewController.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBThumbGalleryViewController.h"
#import "FacebookImageGalleryAppDelegate.h"
#import "ImageViewPopulator.h"
#import "FBDetailViewController.h"
#import "FBImageInfoRequestor.h"

@interface FBThumbGalleryViewController()

//Notification Selectors
-(void)imageRequestorStartedGettingInfo:(NSNotification*)notification;
-(void)imageRequestorWillGetMoreInfo:(NSNotification*)notification;
-(void)imageRequestorGotMoreInfo:(NSNotification*)notification;
-(void)imageRequestorFinishedGettingInfo:(NSNotification*)notification;
-(void)imageRequestorFailed:(NSNotification*)notification;

@end

@implementation FBThumbGalleryViewController

@synthesize tableView, loadingView, failedView, tmpCell, cellNib;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tableView release];
    [loadingView release];
    [failedView release];
    [tmpCell release];
    [cellNib release];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure table view
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 79;
    
    // Configure indication views
    failedView.hidden = YES;
    loadingView.hidden = YES;
    
    // Set own title
    self.title = @"Photos Of You";
    
    // Setup cellNib
    self.cellNib = [UINib nibWithNibName:@"FBImageTableViewCell" bundle:nil];
    
    // Register For Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRequestorStartedGettingInfo:) name:IMAGE_REQUESTOR_STARTED_GETTING_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRequestorWillGetMoreInfo:) name:IMAGE_REQUESTOR_WILL_GET_MORE_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRequestorGotMoreInfo:) name:IMAGE_REQUESTOR_GOT_MORE_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRequestorFinishedGettingInfo:) name:IMAGE_REQUESTOR_FINISHED_GETTING_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRequestorFailed:) name:IMAGE_REQUESTOR_FAILED_GETTING_ANY_INFO_NOTIFICATION object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    self.cellNib = nil;
    self.tableView = nil;
    self.tmpCell = nil;
    self.loadingView = nil;
    self.failedView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - ibactions
-(void)retryFacebookLoadButtonPressed:(id)sender{
    failedView.hidden = YES;
    [[FBImageInfoRequestor sharedInstance] getFirstTaggedPhotosFromFacebook];
}

#pragma mark - Notification Selectors
-(void)imageRequestorStartedGettingInfo:(NSNotification*)notification{
    self.loadingView.hidden = NO;
    hasLoadedAllImages = NO;
    isCurrentlyLoadingImages = YES;
}

-(void)imageRequestorWillGetMoreInfo:(NSNotification*)notification{
    isCurrentlyLoadingImages = YES;
}

-(void)imageRequestorGotMoreInfo:(NSNotification*)notification{
    self.loadingView.hidden = YES;
    isCurrentlyLoadingImages = NO;
    [tableView reloadData];
}

-(void)imageRequestorFinishedGettingInfo:(NSNotification*)notification{
    hasLoadedAllImages = YES;
    [tableView reloadData];
}

-(void)imageRequestorFailed:(NSNotification*)notification{
    loadingView.hidden = YES;
    failedView.hidden = NO;
}

#pragma mark - Table View Data Source
-(int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ceil([FBImageInfoRequestor sharedInstance].taggedPhotosInfoArray.count / 4.0);
}

-(UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *taggedPhotosInfoArray = [FBImageInfoRequestor sharedInstance].taggedPhotosInfoArray;
    
    // If its the last cell, and all the images aren't loaded, show an activity indicator
    if(indexPath.row == taggedPhotosInfoArray.count / 4 && !hasLoadedAllImages){
        UITableViewCell *activityCell = [_tableView dequeueReusableCellWithIdentifier:@"Activity"];
        if(!activityCell){
            //This should only happen once, so more efficient to init / release here
            UINib *nib = [UINib nibWithNibName:@"FBActivityTableViewCell" bundle:nil];
            [nib instantiateWithOwner:self options:nil];
            activityCell = tmpCell;
            self.tmpCell = nil;
        }
        return activityCell;
    }
    
    
    
    // Get dequeued cell or make a new one. 
    FBImageTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell){
        [cellNib instantiateWithOwner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
    }
    
    //Setup the cell.
    int newStartingIndex = indexPath.row * 4;
    if(newStartingIndex != cell.cellStartingIndex){
        [cell clearAllImageViews];
    }
    cell.cellStartingIndex = newStartingIndex;
    cell.delegate = self;
    
    // Figure out how many views to fill, and request more photos if we are getting near the end.
    int diff =  taggedPhotosInfoArray.count - indexPath.row * 4;
    if(diff < 12 && !isCurrentlyLoadingImages && !hasLoadedAllImages){
        [[FBImageInfoRequestor sharedInstance] getNextPageOfTaggedPhotosFromFacebook];
    }
    int numberToPopulate = (diff > 0) ? ((diff > 4) ? 4 : diff) : 0;
    
    // Populate all the image views with the image urls from the dictionary. 
    NSArray *arrayOfCellImageViews = [NSArray arrayWithObjects:cell.imageView1, cell.imageView2, cell.imageView3, cell.imageView4, nil];
    for (int i = 0; i<arrayOfCellImageViews.count; i++){
        UIImageView *imageView = [arrayOfCellImageViews objectAtIndex:i];
        if(i < numberToPopulate){
            imageView.hidden = NO;
            NSDictionary *dictionary = [taggedPhotosInfoArray objectAtIndex:indexPath.row * 4 + i];
            NSString *urlPath = [dictionary objectForKey:@"picture"];
            
            ImageViewPopulator *ivp = [[ImageViewPopulator alloc] initWithImageView:imageView];
            [ivp populateImageViewWithURLString:urlPath];
            [ivp release];

        }else{
            imageView.hidden = YES;
        }
    }
    
    return cell;
}

#pragma mark - fbimagetableviewcell delegate
-(void)fbImageTableViewCell:(FBImageTableViewCell *)cell didTapImageViewWithIndex:(int)index{
    
    //Push a detail view controller onto the stack. 
    FBDetailViewController *fbdvc = [[FBDetailViewController alloc] init];
    fbdvc.scrollViewCenterIndex = index;
    fbdvc.hasFinishedLoading = hasLoadedAllImages;
    [self.navigationController pushViewController:fbdvc animated:YES];
    [fbdvc release];
}


@end
