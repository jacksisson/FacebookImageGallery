//
//  JSViewController.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBThumbGalleryViewController.h"
#import "JSAppDelegate.h"
#import "ImageViewPopulator.h"
#import "FBDetailViewController.h"

@interface FBThumbGalleryViewController()
-(void)getNextPageOfTaggedPhotosFromFacebook;
@end

@implementation FBThumbGalleryViewController

@synthesize tableView, tmpCell, cellNib;
@synthesize taggedPhotosInfoArray;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.taggedPhotosInfoArray = [NSMutableArray array];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure table view
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 79;
    
    // Set own title
    self.title = @"Photos Of You";
    
    // Setup cellNib
    self.cellNib = [UINib nibWithNibName:@"FBImageTableViewCell" bundle:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.cellNib = nil;
    self.tableView = nil;
    self.tmpCell = nil;
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

#pragma mark - facebook image loading
-(void)getFirstTaggedPhotosFromFacebook{
    
    //Request the json for 25 photos.
    Facebook *facebook = ((JSAppDelegate*)[UIApplication sharedApplication].delegate).facebook;
    [facebook requestWithGraphPath:@"me/photos" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"25", @"limit",nil] andDelegate:self];
    currentOffset=25;
}

-(void)getNextPageOfTaggedPhotosFromFacebook{
    
    //Request the next 25 photos if they are available.
    Facebook *facebook = ((JSAppDelegate*)[UIApplication sharedApplication].delegate).facebook;
    [facebook requestWithGraphPath:@"me/photos" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"25", @"limit", [NSString stringWithFormat:@"%d", currentOffset], @"offset",nil] andDelegate:self];
    currentOffset+=25;
}

-(void)request:(FBRequest *)request didLoad:(id)result{
    [taggedPhotosInfoArray addObjectsFromArray:[result objectForKey:@"data"]];
    [tableView reloadData];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Failed load with error: %@", error);
}

#pragma mark - Table View Data Source
-(int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return taggedPhotosInfoArray.count / 4;
}

-(UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get dequeued cell or make a new one. 
    FBImageTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell){
        [cellNib instantiateWithOwner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
    }
    
    //Setup the cell.
    cell.cellStartingIndex = indexPath.row * 4;
    cell.delegate = self;
    
    // Figure out how many views to fill, and request more photos if we are getting near the end.
    int diff =  taggedPhotosInfoArray.count - indexPath.row * 4;
    if(diff < 12){
        [self getNextPageOfTaggedPhotosFromFacebook];
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
    [fbdvc.view subviews];
    fbdvc.scrollViewCenterIndex = index;
    fbdvc.taggedImagesInfoArray = taggedPhotosInfoArray;
    [self.navigationController pushViewController:fbdvc animated:YES];
    [fbdvc release];
}


@end
