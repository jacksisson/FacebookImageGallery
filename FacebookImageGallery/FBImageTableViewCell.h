//
//  FBImageTableViewCell.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FBImageTableViewCellDelegate;

@interface FBImageTableViewCell : UITableViewCell{
    //ivars to hold tap state
    UIImageView *tappedImageView;
    int tappedIndex;
    
    //image views
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
    
    //other
    NSInteger cellStartingIndex;
    id<FBImageTableViewCellDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (nonatomic, retain) IBOutlet UIImageView *imageView2;
@property (nonatomic, retain) IBOutlet UIImageView *imageView3;
@property (nonatomic, retain) IBOutlet UIImageView *imageView4;
@property (nonatomic) NSInteger cellStartingIndex;
@property (nonatomic, assign) id<FBImageTableViewCellDelegate> delegate;

-(void)clearAllImageViews;
-(IBAction)imageButtonPressed:(id)sender;

@end

@protocol FBImageTableViewCellDelegate <NSObject>

-(void)fbImageTableViewCell:(FBImageTableViewCell*)cell didTapImageViewWithIndex:(int)index;

@end
