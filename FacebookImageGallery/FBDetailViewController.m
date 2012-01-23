//
//  FBDetailViewController.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBDetailViewController.h"
#import "ImageViewPopulator.h"

@interface FBDetailViewController()

// Image Views
-(void)loadImageViewsIntoScrollView;
-(void)setImageViewsForCenterIndex:(NSInteger)centerIndex;
-(void)setImageForImageView:(UIImageView*)imageView withDictionary:(NSDictionary*)dictionary imageType:(ImageType)imageType;

// Comments
-(void)showCommentsForIndex:(int)index;
-(void)hideComments;
@end

@implementation FBDetailViewController

@synthesize scrollView;
@synthesize arrayOfImageViews;
@synthesize taggedImagesInfoArray;
@synthesize scrollViewCenterIndex;
@synthesize textView;

#pragma mark - memory 
-(void)dealloc{
    [super dealloc];
    [scrollView release];
    [arrayOfImageViews release];
    [taggedImagesInfoArray release];
    [textView release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Additional setup
    self.arrayOfImageViews = [NSMutableArray array];
    self.scrollViewCenterIndex = scrollViewCenterIndex; // 
    [self loadImageViewsIntoScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.scrollView = nil;
    self.textView = nil;
    self.arrayOfImageViews = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - imageViews
-(void)loadImageViewsIntoScrollView{
    //Create 3 image views and put them in the scroll view.
    for(int i = 0; i < 3; i++){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [scrollView addSubview:imageView];
        [arrayOfImageViews addObject:imageView];
        [imageView release];
    }
}

-(void)setImageViewsForCenterIndex:(NSInteger)centerIndex{
    // Populate the image views with the appropriate images
    CGRect scrollViewFrame = scrollView.bounds;
    int actualCenterIndex = (centerIndex==0 ? 0 : (centerIndex==taggedImagesInfoArray.count-1 ? 2 : 1));
    for(int i = 0; i < 3; i++){
        UIImageView *imageView = [arrayOfImageViews objectAtIndex:i];
        CGRect imageFrame = scrollViewFrame;
        imageFrame.origin.x += (scrollViewFrame.size.width * (i-actualCenterIndex));
        imageView.frame = imageFrame;  
        NSDictionary *dict = [taggedImagesInfoArray objectAtIndex:centerIndex + i - actualCenterIndex];
        [self setImageForImageView:imageView withDictionary:dict imageType:i==actualCenterIndex?ImageTypeFullSize:ImageTypeThumb];
    }
    
    [self showCommentsForIndex:centerIndex];
}

-(void)setImageForImageView:(UIImageView*)imageView withDictionary:(NSDictionary*)dictionary imageType:(ImageType)imageType{
    ImageViewPopulator *ivp = [[ImageViewPopulator alloc] initWithImageView:imageView];
    [ivp populateImageViewWithURLString:(imageType==ImageTypeThumb)?[dictionary objectForKey:@"picture"]:[dictionary objectForKey:@"source"]];
    [ivp release];
}

#pragma mark - setter overrides
-(void)setScrollViewCenterIndex:(NSInteger)_scrollViewCenterIndex{
    scrollViewCenterIndex = _scrollViewCenterIndex;
    [scrollView setContentOffset:CGPointMake(scrollViewCenterIndex * scrollView.frame.size.width, 0) animated:NO];
}

-(void)setTaggedImagesInfoArray:(NSArray *)_taggedImagesInfoArray{
    if(taggedImagesInfoArray == _taggedImagesInfoArray) return;
    taggedImagesInfoArray = [_taggedImagesInfoArray retain];
    int count = taggedImagesInfoArray.count;
    [scrollView setContentSize:CGSizeMake(count * scrollView.frame.size.width, scrollView.frame.size.height)];
    [self setImageViewsForCenterIndex:scrollViewCenterIndex];
    self.title = [NSString stringWithFormat:@"Photo %d of %d", scrollViewCenterIndex, taggedImagesInfoArray.count];
}

#pragma mark - scroll view delegate

-(void)scrollViewDidScroll:(UIScrollView *)_scrollView{    
    CGRect scrollViewFrame = scrollView.bounds;
    scrollViewFrame.origin.x = 0;
    float startingPos = scrollViewCenterIndex * _scrollView.bounds.size.width;
    
    // If we are far enough left, take the last image view, and slide it around to the left
    if(scrollView.contentOffset.x < startingPos - _scrollView.bounds.size.width / 2){
        int floppedIndex = scrollViewCenterIndex - 2;
        if(floppedIndex < 0) return;
        if(scrollViewCenterIndex != taggedImagesInfoArray.count - 1){
            UIImageView *imageView = [[arrayOfImageViews lastObject] retain];
            [arrayOfImageViews removeLastObject];
            [arrayOfImageViews insertObject:imageView atIndex:0];
            CGRect imageFrame = scrollViewFrame;
            imageFrame.origin.x += (scrollViewFrame.size.width * floppedIndex);
            imageView.frame = imageFrame;  
            NSDictionary *dict = [taggedImagesInfoArray objectAtIndex:floppedIndex];
            [self setImageForImageView:imageView withDictionary:dict imageType:ImageTypeThumb];
            [imageView release];
        }
        scrollViewCenterIndex--;
    }
    
    // If we are far enough right, take the first image view, and slide it around to the right. 
    else if(scrollView.contentOffset.x > startingPos + _scrollView.bounds.size.width / 2){
        int floppedIndex = scrollViewCenterIndex + 2;
        if(floppedIndex >= taggedImagesInfoArray.count) return;
        if(scrollViewCenterIndex != 0){
            UIImageView *imageView = [[arrayOfImageViews objectAtIndex:0] retain];
            [arrayOfImageViews removeObjectAtIndex:0];
            [arrayOfImageViews addObject:imageView];
            CGRect imageFrame = scrollViewFrame;
            imageFrame.origin.x += (scrollViewFrame.size.width * floppedIndex);
            imageView.frame = imageFrame;  
            NSDictionary *dict = [taggedImagesInfoArray objectAtIndex:floppedIndex];
            [self setImageForImageView:imageView withDictionary:dict imageType:ImageTypeThumb];
            [imageView release];
        }
        scrollViewCenterIndex++;
    }else{
        return;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideComments];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView{
    
    //Load Higher quality image.
    int currentIndex = (int)scrollView.contentOffset.x / (int)scrollView.bounds.size.width;
    int position = currentIndex == 0 ? 0 : (currentIndex==taggedImagesInfoArray.count-1 ? 2 : 1);
    UIImageView *imageView = [arrayOfImageViews objectAtIndex:position];
    NSDictionary *dict = [taggedImagesInfoArray objectAtIndex:currentIndex];
    [self setImageForImageView:imageView withDictionary:dict imageType:ImageTypeFullSize];
    [self showCommentsForIndex:currentIndex];
    
    //Set title to reflect
    self.title = [NSString stringWithFormat:@"Photo %d of %d", scrollViewCenterIndex + 1, taggedImagesInfoArray.count];
}

#pragma mark - comments
-(void)showCommentsForIndex:(int)index{
    textView.alpha = 0.0;
    textView.hidden = NO;
    NSDictionary *dict = [taggedImagesInfoArray objectAtIndex:scrollViewCenterIndex];
    NSArray *commentsArray = [[dict objectForKey:@"comments"] objectForKey:@"data"];
    if(!commentsArray || commentsArray.count ==0 ){
        textView.text = @"No Comments.";
    }else{    
        //Generate Comments String
        NSMutableString *string = [NSMutableString string];
        for(NSDictionary *commentDict in commentsArray){
            NSString *name = [[commentDict objectForKey:@"from"] objectForKey:@"name"];
            NSString *message = [commentDict objectForKey:@"message"];
            [string appendFormat:@"%@:%@\n\n", name, message];
        }
        textView.text = string; 
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        textView.alpha = 1.0;
    }];
}

-(void)hideComments{
    [UIView animateWithDuration:0.3 animations:^{
        textView.alpha = 0.0;
    } completion:^(BOOL finished){
        textView.hidden = YES;
        textView.text = nil;
    }];
}

@end
