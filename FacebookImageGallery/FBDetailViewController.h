//
//  FBDetailViewController.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ImageTypeThumb,
    ImageTypeFullSize
}ImageType;

@interface FBDetailViewController : UIViewController<UIScrollViewDelegate>{
    UIScrollView *scrollView;
    UITextView *textView;
    NSMutableArray *arrayOfImageViews;
    NSInteger scrollViewCenterIndex;
    BOOL hasFinishedLoading;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSMutableArray *arrayOfImageViews;
@property (nonatomic) NSInteger scrollViewCenterIndex;
@property (nonatomic) BOOL hasFinishedLoading;

@end
