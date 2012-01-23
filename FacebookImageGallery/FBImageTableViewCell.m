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
    [super dealloc];
    [imageView1 release];
    [imageView2 release];
    [imageView3 release];
    [imageView4 release];
}

#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    // Store the image view and index that are initially touched
    CGPoint touchStartPoint = [[touches anyObject] locationInView:self];
    if(CGRectContainsPoint(imageView1.frame, touchStartPoint)){
        tappedImageView = imageView1;
        tappedIndex = 0;
    }else if(CGRectContainsPoint(imageView2.frame, touchStartPoint)){
        tappedImageView = imageView2;
        tappedIndex = 1;
    }else if(CGRectContainsPoint(imageView3.frame, touchStartPoint)){
        tappedImageView = imageView3;
        tappedIndex = 2;
    }else if(CGRectContainsPoint(imageView4.frame, touchStartPoint)){
        tappedImageView = imageView4;
        tappedIndex = 3;
    }else{
        tappedImageView = nil;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    // If there was an image view that was tapped, call the delegate if the image view was
    // "touched up inside"
    if(!tappedImageView) return;
    CGPoint touchEndPoint = [[touches anyObject] locationInView:self];
    if(CGRectContainsPoint(tappedImageView.frame, touchEndPoint)){
        if([delegate respondsToSelector:@selector(fbImageTableViewCell:didTapImageViewWithIndex:)]){
            [delegate fbImageTableViewCell:self didTapImageViewWithIndex:cellStartingIndex + tappedIndex];
        }
    }
}

@end
