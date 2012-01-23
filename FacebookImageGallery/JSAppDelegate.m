//
//  JSAppDelegate.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSAppDelegate.h"
#import "FBThumbGalleryViewController.h"
#import "Defines.h"
#import "FBLoginViewController.h"

@implementation JSAppDelegate

@synthesize window;
@synthesize navController;
@synthesize facebook;

#pragma mark - Launch and Memory
- (void)dealloc
{
    [window release];
    [navController release];
    [facebook release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Init View Controller with appropriate nib
    FBThumbGalleryViewController *rootViewController = [[FBThumbGalleryViewController alloc] initWithNibName:@"FBThumbGalleryViewController_iPhone" bundle:nil];
    
    //Create Nav Controller with the above view controller as root
    UINavigationController *localNavController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.navController = localNavController;
    [localNavController release];
    [rootViewController release];
    
    //Create Window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    //Additional App Setup
    [self setupFacebook];

    return YES;
}

#pragma mark - Facebook
-(void)setupFacebook{
    
    //Load Facebook object, and autohrize if necessary
    facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![facebook isSessionValid]) {
        FBLoginViewController *loginVC = [[FBLoginViewController alloc] init];
        loginVC.delegate = self;
        [navController presentModalViewController:loginVC animated:NO];
        [loginVC release];
    }else{
        [self startLoadRequestInMainViewController];
    }
}

#pragma mark - Facebook overrides for openURL methods

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

#pragma mark - Facebook Session Delegate
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self startLoadRequestInMainViewController];
}

-(void)startLoadRequestInMainViewController{
    FBThumbGalleryViewController *viewController = [[navController viewControllers] objectAtIndex:0];
    [viewController getFirstTaggedPhotosFromFacebook];
}

#pragma mark - FBLoginDelegate
-(void)loginViewControllerDidRequestLogin:(FBLoginViewController *)loginVC{
    NSArray *permissions = [NSArray arrayWithObjects:@"user_photo_video_tags", nil];
    [facebook authorize:permissions];
    [navController dismissModalViewControllerAnimated:YES];
}

@end
