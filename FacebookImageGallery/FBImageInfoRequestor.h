//
//  FBImageInfoRequestor.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

//Notifications that will be issued
#define IMAGE_REQUESTOR_STARTED_GETTING_INFO_NOTIFICATION       @"ImageRequestorStartedGettingInfo"
#define IMAGE_REQUESTOR_WILL_GET_MORE_INFO_NOTIFICATION         @"ImageRequestorWillGetMoreInfo"
#define IMAGE_REQUESTOR_GOT_MORE_INFO_NOTIFICATION              @"ImageRequestorGotMoreInfo"
#define IMAGE_REQUESTOR_FINISHED_GETTING_INFO_NOTIFICATION      @"ImageRequestorFinishedGettingInfo"
#define IMAGE_REQUESTOR_FAILED_GETTING_ANY_INFO_NOTIFICATION    @"ImageRequestorFailed"

@interface FBImageInfoRequestor : NSObject <FBRequestDelegate>{
    NSMutableArray *taggedPhotosInfoArray;
    NSInteger currentOffset;
}

@property (nonatomic, retain) NSMutableArray *taggedPhotosInfoArray;

// Get Singleton Instance
+(FBImageInfoRequestor*)sharedInstance;

//Fetching
-(void)getFirstTaggedPhotosFromFacebook;
-(void)getNextPageOfTaggedPhotosFromFacebook;


@end
