//
//  FBLoginViewController.m
//  FacebookImageGallery
//
//  Created by Jack Sisson on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FBLoginViewController.h"

@implementation FBLoginViewController

@synthesize delegate;

#pragma mark - View
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction
-(IBAction)loginButtonPressed:(id)sender{
    if([delegate respondsToSelector:@selector(loginViewControllerDidRequestLogin:)]){
        [delegate loginViewControllerDidRequestLogin:self];
    }
}

@end
