//
//  SplashViewController.h
//  iTennis
//
//  Created by Brandon Trebitowski on 3/18/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "SystemConfiguration/CaptiveNetwork.h"
#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "NavigationViewController.h"
#import "TrackControlView.h"
#import "constants.h"
#import "Reachability.h"
#import "NetworkCheck.h"
#import "DeviceProperties.h"
#import "UITaggedButton.h"

@interface SplashViewController : UIViewController <UINavigationControllerDelegate> {
	NSTimer *timer;
	NSTimer *timer2;

	UINavigationController *navigationController1;

	UIImageView *splashImageView;
	UIImageView *loadingContentImageView;
	UIImageView *chooseModeImageView;
	UIImageView *chooseAppVersionImageView;

	
	MainViewController *mainViewController;
	NavigationViewController *navigationViewController;


	
	UILabel *measureLabel;
	UILabel *statusLabel;

	UIImageView* networkImage;
	UIImage* networkReachableImage;
	UIImage* networkNotReachableImage;
	
	UIToolbar *bar;
	
	
	UIPickerView * piecePicker;

	UIBarButtonItem *pieceBarItem;

	UIBarButtonItem * connectedItem;
    UIBarButtonItem *goLiveButton;
	BOOL toolbarVisible;


	NSMutableArray * currentViewControllers;
    BOOL alertsPresent;
    BOOL onlineMode;
    int kWIDTH;
    int kHEIGHT;
}

-(void) updateMeasure;

@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) NSTimer *timer2;

@property(nonatomic,retain) UIImageView *splashImageView;
@property(nonatomic,retain) UIImageView *loadingContentImageView;
@property(nonatomic,retain) UIImageView *chooseModeImageView;

@property(retain) MainViewController *mainViewController;
@property(retain) NavigationViewController *navigationViewController;
@property(retain) UITabBarController *trackTabBar;
@property(retain) UIToolbar *bar;
@property(retain) 	UIBarButtonItem *pieceBarItem;
@property(retain) 	UIBarButtonItem *connectedItem;
@property(retain) 	UIBarButtonItem *goLiveButton;
@property(assign) BOOL toolbarVisible;
@property(nonatomic, assign) BOOL alertsPresent;
@property(assign) BOOL onlineMode;
@property(retain) UINavigationController *navigationController1;

@end
