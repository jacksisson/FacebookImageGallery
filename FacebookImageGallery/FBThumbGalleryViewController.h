//
//  JSViewController.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "FBImageTableViewCell.h"

@interface FBThumbGalleryViewController : UIViewController<FBRequestDelegate, FBImageTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>{
    int currentOffset;
    UITableView *tableView;
    NSMutableArray *taggedPhotosInfoArray;
    FBImageTableViewCell *tmpCell;
    UINib *cellNib;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *taggedPhotosInfoArray;
@property (nonatomic, retain) IBOutlet FBImageTableViewCell *tmpCell;
@property (nonatomic, retain) UINib *cellNib;


-(void)getFirstTaggedPhotosFromFacebook;

@end
