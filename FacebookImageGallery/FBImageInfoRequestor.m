//
//  FBImageInfoRequestor.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBImageInfoRequestor.h"
#import "FacebookImageGalleryAppDelegate.h"

@interface FBImageInfoRequestor()
@property (nonatomic) NSInteger currentOffset;
@end

@implementation FBImageInfoRequestor

@synthesize taggedPhotosInfoArray;
@synthesize currentOffset;

#pragma mark - memory
static FBImageInfoRequestor *sharedInstance;
+(FBImageInfoRequestor*)sharedInstance{
    if(!sharedInstance){
        sharedInstance = [[FBImageInfoRequestor alloc] init];
        sharedInstance.taggedPhotosInfoArray = [NSMutableArray array];
        sharedInstance.currentOffset = 0;
    }
    return sharedInstance;
}

-(void)dealloc{
    [super dealloc];
    [taggedPhotosInfoArray release];
}

#pragma mark - public methods

-(void)getFirstTaggedPhotosFromFacebook{
    //Request the json for 25 photos.
    Facebook *facebook = ((FacebookImageGalleryAppDelegate*)[UIApplication sharedApplication].delegate).facebook;
    [facebook requestWithGraphPath:@"me/photos" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"25", @"limit",nil] andDelegate:self];
    currentOffset=25;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_STARTED_GETTING_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_WILL_GET_MORE_INFO_NOTIFICATION object:nil];
}

-(void)getNextPageOfTaggedPhotosFromFacebook{
    
    //Request the next 25 photos if they are available.
    Facebook *facebook = ((FacebookImageGalleryAppDelegate*)[UIApplication sharedApplication].delegate).facebook;
    [facebook requestWithGraphPath:@"me/photos" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"25", @"limit", [NSString stringWithFormat:@"%d", currentOffset], @"offset",nil] andDelegate:self];
    currentOffset+=25;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_WILL_GET_MORE_INFO_NOTIFICATION object:nil];
}

#pragma mark - fb request delegate

-(void)request:(FBRequest *)request didLoad:(id)result{
    NSArray *dataArray = [result objectForKey:@"data"];
    if(dataArray && dataArray.count > 0){
        [taggedPhotosInfoArray addObjectsFromArray:dataArray];
        [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_GOT_MORE_INFO_NOTIFICATION object:nil];
    }else{
        if(taggedPhotosInfoArray.count > 0){
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_FINISHED_GETTING_INFO_NOTIFICATION object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_FAILED_GETTING_ANY_INFO_NOTIFICATION object:nil];
        }
    }
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Failed load with error: %@", error);
    if(taggedPhotosInfoArray.count==0){
        [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_REQUESTOR_FAILED_GETTING_ANY_INFO_NOTIFICATION object:nil];
    }
}


@end
