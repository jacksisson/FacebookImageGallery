//
//  JSViewController.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBImageTableViewCell.h"

@interface FBThumbGalleryViewController : UIViewController<FBImageTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>{
    int currentOffset;
    UITableView *tableView;
    UIView *loadingView;
    UIView *failedView;
    FBImageTableViewCell *tmpCell;
    UINib *cellNib;
    BOOL hasLoadedAllImages;
    BOOL isCurrentlyLoadingImages;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIView *failedView;

@property (nonatomic, retain) IBOutlet FBImageTableViewCell *tmpCell;
@property (nonatomic, retain) UINib *cellNib;

//IBActions
-(IBAction)retryFacebookLoadButtonPressed:(id)sender;


@end
