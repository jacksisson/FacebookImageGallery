//
//  FBImageTableViewCell.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBImageTableViewCell.h"

#define TOUCH_MOVEMENT_TOLERANCE

@implementation FBImageTableViewCell
@synthesize imageView1, imageView2, imageView3, imageView4;
@synthesize cellStartingIndex;
@synthesize delegate;

#pragma mark - memory
-(void)dealloc{
    [imageView1 release];
    [imageView2 release];
    [imageView3 release];
    [imageView4 release];  
    [super dealloc];
}

#pragma mark - methods
-(void)clearAllImageViews{
    self.imageView1.image = nil;
    self.imageView2.image = nil;
    self.imageView3.image = nil;
    self.imageView4.image = nil;
}

-(void)imageButtonPressed:(id)sender{
    int index = ((UIButton*)sender).tag;
    
    if([delegate respondsToSelector:@selector(fbImageTableViewCell:didTapImageViewWithIndex:)]){
        [delegate fbImageTableViewCell:self didTapImageViewWithIndex:cellStartingIndex + index];
    }
}

@end
