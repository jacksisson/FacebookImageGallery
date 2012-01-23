//
//  ImageFetcher.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageFetcherDelegate;

@interface ImageFetcher : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    id<ImageFetcherDelegate> delegate;
    NSString *urlPath;
    NSString *pathToSaveImage;
    NSURLConnection *urlConnection;
    NSFileHandle *fileHandle;
}

@property (nonatomic, retain) id<ImageFetcherDelegate> delegate;
@property (nonatomic, retain) NSString *urlPath;
@property (nonatomic, retain) NSString *pathToSaveImage;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSFileHandle *fileHandle;

// Default Initializer.
-(id)initWithDelegate:(id<ImageFetcherDelegate>)_delegate;

// Call this to fetch the image file asychronously.
// If the file is cached, this will call back to the delegate synchronously
// with the path of the cached file. 
-(void)fetchImageAtURLPath:(NSString*)urlPath;

@end

@protocol ImageFetcherDelegate <NSObject>

//Called when we know that the file will be downloaded (i.e., its not cached)
-(void)imageFetcherWillBeginDownload:(ImageFetcher*)imageFetcher;

//Called when the download fails. 
-(void)imageFetcher:(ImageFetcher*)imageFetcher didFailWithError:(NSError*)error;

//Called when the download succeeds. 
-(void)imageFetcher:(ImageFetcher*)imageFetcher didSucceedWithFetchedPhotoPath:(NSString*)fetcherPhotoPath;

@end