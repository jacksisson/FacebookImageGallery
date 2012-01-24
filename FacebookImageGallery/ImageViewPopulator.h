//
//  ImageViewPopulator.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageFetcher.h"

@interface ImageViewPopulator : NSObject<ImageFetcherDelegate>{
    UIImageView *imageView;
    ImageFetcher *imageFetcher;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) ImageFetcher *imageFetcher;


// Default Initializer
-(id)initWithImageView:(UIImageView*)_imageView;

// Call this to asynchronously populater the image
// view ivar with the image at the URL. If the image 
// is not available, a placeholder image will be shown. 
-(void)populateImageViewWithURLString:(NSString*)urlString;

@end
