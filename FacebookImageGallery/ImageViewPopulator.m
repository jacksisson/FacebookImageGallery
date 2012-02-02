//
//  ImageViewPopulator.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewPopulator.h"

@implementation ImageViewPopulator

@synthesize imageView;
@synthesize imageFetcher;


#pragma mark - memory
-(id)initWithImageView:(UIImageView*)_imageView{
    self = [super init];
    if(self){
        self.imageView = _imageView;
    }
    
    return self;
}

-(void)dealloc{
    [imageView release];
    [imageFetcher stop];
    [imageFetcher release];
    [super dealloc];
}

#pragma mark - population

-(void)populateImageViewWithURLString:(NSString*)urlString{
    // Fetch the image
    ImageFetcher *_imageFetcher = [[ImageFetcher alloc] initWithDelegate:self];
    [_imageFetcher fetchImageAtURLPath:urlString];
    self.imageFetcher = _imageFetcher;
    [_imageFetcher release];
    
    // Retain self so delegate doesn't have to.
    [self retain];
}

#pragma mark - image fetcher delegate

-(void)imageFetcherWillBeginDownload:(ImageFetcher *)imageFetcher{
    // Add an activity indicator to the image view.
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
    [imageView addSubview:activityIndicator];
    [activityIndicator release];
}

-(void)imageFetcher:(ImageFetcher *)imageFetcher didSucceedWithFetchedPhotoPath:(NSString *)fetcherPhotoPath{
    // Remove the activity indicator we added if we added one
    for(UIView *subview in imageView.subviews){
        [subview removeFromSuperview];
    }
    
    // Get the image, or the placeholder if invalid
    UIImage *image = [UIImage imageWithContentsOfFile:fetcherPhotoPath];
    if(!image){
        image = [UIImage imageNamed:@"MISSING_IMAGE"];
    }
    
    // Set the image and release self.
    imageView.image = image;
    [self release];
}

-(void)imageFetcher:(ImageFetcher *)imageFetcher didFailWithError:(NSError *)error{
    // Remove the activity indicator we added if we added one
    for(UIView *subview in imageView.subviews){
        [subview removeFromSuperview];
    }
    
    // Set the placeholder image and release self.
    UIImage *image = [UIImage imageNamed:@"MISSING_IMAGE"];
    imageView.image = image;
    [self release];
}

@end
