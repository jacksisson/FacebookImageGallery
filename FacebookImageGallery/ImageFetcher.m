//
//  ImageFetcher.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageFetcher.h"
#import "Defines.h"

@interface ImageFetcher()
-(void)startActualFetchForURLPath;
-(void)removeFromQueueAndDequeueNextFetcherIfNecessary;
-(void)callSuccessDelegate;
-(void)callFailureDelegateWithError:(NSError*)error;
@end

@implementation ImageFetcher

@synthesize delegate;
@synthesize urlPath;
@synthesize pathToSaveImage;
@synthesize urlConnection;
@synthesize fileHandle;

static NSMutableArray *activeFileFetchersQueue;

-(id)initWithDelegate:(id<ImageFetcherDelegate>)_delegate{
    self = [super init];
    if(self){
        self.delegate = _delegate;
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
    [delegate release];
    [urlPath release];
//    [pathToSaveImage release]; // This causes a bad access for some reason. 
    [urlConnection release];
}

-(void)fetchImageAtURLPath:(NSString*)_urlPath{
    
    // Retain self so that delegate doesn't have to hold our reference.
    [self retain];
    
    // Store URL path and Configure path for saving.
    self.urlPath = _urlPath;
    NSString *imageName = [urlPath lastPathComponent];
    self.pathToSaveImage = [CACHES_DIRECTORY_PATH stringByAppendingPathComponent:imageName];
    
    // If a valid image exists at the pathToSaveImage, just pass that to the delegate
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:pathToSaveImage]){
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathToSaveImage];
        if(!image){
            [fileManager removeItemAtPath:pathToSaveImage error:nil];
        }else{
            [image release];
            [self performSelectorOnMainThread:@selector(callSuccessDelegate) withObject:nil waitUntilDone:NO];
            return;
        }
    }
    
    // Create the file fetcher queue if it does not exist already.
    if(!activeFileFetchersQueue){
        activeFileFetchersQueue = [[NSMutableArray alloc] init];
    }
    
    // Check to see if there is already an Image Fetcher running for the urlPath
    BOOL isDuplicate = NO;
    for(ImageFetcher *fetcher in activeFileFetchersQueue){
        if([fetcher.urlPath isEqualToString:self.urlPath]){
            isDuplicate = YES;
            break;
        }
    }
    
    // If its not a duplicate, add it to the queue. If it is, fail with appropriate error.
    if(!isDuplicate){
        [activeFileFetchersQueue addObject:self];
    }else{
        NSError *error = [NSError errorWithDomain:@"ImageFetcher" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Reason", @"There is already a fetcher downloading this image", nil]];
        [self performSelectorOnMainThread:@selector(callFailureDelegateWithError:) withObject:error waitUntilDone:NO];
        return;
    }
    
    // If there aren't more than the max number of image requests running already, start.
    if(activeFileFetchersQueue.count<=MAX_NUMBER_OF_SIMULTANEOUS_IMAGE_REQUESTS){
        [self startActualFetchForURLPath];
    }
    
    // Tell the delegate we'll be downloading the file.
    if([delegate respondsToSelector:@selector(imageFetcherWillBeginDownload:)]){
        [delegate imageFetcherWillBeginDownload:self];
    }
}


-(void)startActualFetchForURLPath{
    // Create an empty file and a file handle.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:pathToSaveImage contents:nil attributes:nil];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:pathToSaveImage];
    
    // Start a url connection for our iVar urlPath's url.
    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [urlConnection start];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [fileHandle writeData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [fileHandle closeFile];
    self.fileHandle = nil;
    [self performSelectorOnMainThread:@selector(callSuccessDelegate) withObject:nil waitUntilDone:NO];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self performSelectorOnMainThread:@selector(callFailureDelegateWithError:) withObject:error waitUntilDone:NO];
}

#pragma mark - Delegate Calling
-(void)callSuccessDelegate{
    // Tell the delegate the file's done, and start another download if necessary.
    if([delegate respondsToSelector:@selector(imageFetcher:didSucceedWithFetchedPhotoPath:)]){
        [delegate imageFetcher:self didSucceedWithFetchedPhotoPath:pathToSaveImage];
    }
    [self removeFromQueueAndDequeueNextFetcherIfNecessary];
    [self release];
}

-(void)callFailureDelegateWithError:(NSError*)error{
    // Tell the delegate the download failed, and start another download if necessary.
    if([delegate respondsToSelector:@selector(imageFetcher:didFailWithError:)]){
        [delegate imageFetcher:self didFailWithError:error];
    }
    [self removeFromQueueAndDequeueNextFetcherIfNecessary];
    [self release];
}

#pragma mark - dequeueing
-(void)removeFromQueueAndDequeueNextFetcherIfNecessary{
    [activeFileFetchersQueue removeObject:self];
    if(activeFileFetchersQueue.count >= MAX_NUMBER_OF_SIMULTANEOUS_IMAGE_REQUESTS){
        ImageFetcher *fetcher = [activeFileFetchersQueue objectAtIndex:MAX_NUMBER_OF_SIMULTANEOUS_IMAGE_REQUESTS-1];
        [fetcher startActualFetchForURLPath];
    }
}

#pragma mark -stop
-(void)stop{
    [self release];
}

@end
