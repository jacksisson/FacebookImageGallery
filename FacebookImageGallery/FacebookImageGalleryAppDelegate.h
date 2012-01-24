//
//  JSAppDelegate.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FBLoginViewController.h"

@class FBThumbGalleryViewController;

@interface FacebookImageGalleryAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBLoginViewControllerDelegate>{
    Facebook *facebook;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (nonatomic, retain) Facebook *facebook;

-(void)setupFacebook;

@end
