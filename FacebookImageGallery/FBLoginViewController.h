//
//  FBLoginViewController.h
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FBLoginViewControllerDelegate;


@interface FBLoginViewController : UIViewController

@property (nonatomic, assign) id<FBLoginViewControllerDelegate> delegate;

-(IBAction)loginButtonPressed:(id)sender;

@end


@protocol FBLoginViewControllerDelegate <NSObject>

-(void)loginViewControllerDidRequestLogin:(FBLoginViewController*)loginVC;

@end
