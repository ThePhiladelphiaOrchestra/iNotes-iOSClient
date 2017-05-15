//
//  SplashViewController.m
//  iTennis
//
//  Created by Brandon Trebitowski on 3/18/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "SplashViewController.h"
#import "Test1AppDelegate.h"
#import <TargetConditionals.h>

@implementation SplashViewController

@synthesize timer,timer2, splashImageView, mainViewController,toolbarVisible,navigationController1,navigationViewController;
@synthesize bar,loadingContentImageView,chooseModeImageView, pieceBarItem,connectedItem, goLiveButton, alertsPresent, onlineMode;


Test1AppDelegate *appDelegate;
NSString * SERVER_IP_SPLASH = ADDRESS_OF_SERVER;

- (id) init
{
	self = [super init];
	if (self != nil) {
		appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        NSString* ssid;
        
#if TARGET_IPHONE_SIMULATOR // Simulator specific code
        
        ssid = SSID;
        NSLog(@"SSID: %@",ssid);
        
        if([ssid isEqualToString:SSID])
        {
            NSLog(@"Proper Network Connected!");
            onlineMode = true;
        }
        else
        {
            UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"You are not connected to the iNotes Network. Exit and close the app and connect to the correct Network through your device's wireless network settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            alertsPresent = true;
            onlineMode = false;
            [anAlert show];
            
        }
#else // Using actual device
        
        
        int status = [NetworkCheck whatIsMyConnectionType];
        
        if(status == 0)
        {
            // No internet
            
            
            UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"Live Stream Not Connected" message:@"If you are at an enhanced concert, close the app and connect to the correct network in your device's Wireless Network Settings to receive the live stream. The app will continue in offline mode." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            alertsPresent = true;
            onlineMode = false;
            anAlert.tag = @"NetworkError";
            [anAlert show];
            
            
        }
        else if (status == 1)
        {
            // on WiFi
            
            ssid =  [NetworkCheck whatIsMySSID];
            
            //check ssid
            if([ssid isEqualToString:SSID])
            {
                onlineMode = true;
            }
            
            //not the right network for multicast
            else
            {
                
                
                UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"Live Stream Not Connected" message:@"If you are at an enhanced concert connect to the correct network in your device's Wireless Network Settings to receive the live stream. The app will continue in offline mode." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                anAlert.tag = @"NetworkError";
                alertsPresent = true;
                onlineMode = false;
                [anAlert show];
                
                
            }
            
            
        }
        else
        {
            // Cell Network (3G, onlineMode=2)
            UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"Live Stream Not Connected" message:@"If you are at an enhanced concert, turn on Wifi and connect to the correct network in your device's Wireless Network Settings to receive the live stream. The app will continue in offline mode." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            alertsPresent = true;
            onlineMode = false;
            [anAlert show];
            
        }
        
        
#endif // TARGET_IPHONE_SIMULATOR
        
        
        
    }
    
    return self;
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
    kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
    currentViewControllers = [[NSMutableArray alloc] init];
	// Init the view
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        appFrame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
    }
	UIView *view = [[UIView alloc] initWithFrame:appFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	
    
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    
    NSString* loadFileName;
    if([DeviceProperties getDeviceResolutionLandscape].width == 480) // Juliesays : tofix. We already made a variable kWIDTH let's use it
    {
        loadFileName = SPLASH_IMAGE_32;
    }
    else{
        loadFileName = SPLASH_IMAGE_169;
    }
    
    NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"http://%@/images/AppAssets/%@",SERVER_IP_SPLASH,loadFileName];
    

    
    NSLog(@"%@",tempImageStrUrltemp);
    NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"();+,[] ", kCFStringEncodingISOLatin1));
    NSURL *url = [NSURL URLWithString:tempImageStrUrl];

    
    //QUICK OFFLINE FIX MP
    NSData* data;
    
    //if on no network or cell network, dont load content
    if(([NetworkCheck whatIsMyConnectionType] == 0)||([NetworkCheck whatIsMyConnectionType] == 2))
    {
        data = nil;
    }
    else //only load if on wifi
    {
        // Load image for first screen
        data = [NSData dataWithContentsOfURL:url];
    }
    
    
    if(data==nil)
    {
        // If no connection, go get image in the project
        data = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], loadFileName]];
    }
    
    
    UIImage *splashImageJawn = [[UIImage alloc] initWithData:data];
    
	// Splash screen view
	splashImageView = [[UIImageView alloc] initWithImage:splashImageJawn];
	splashImageView.frame = CGRectMake(0, 32, kWIDTH, kHEIGHT-32);
	splashImageView.alpha = 1.0;
	
	// Mode choosing view
	chooseModeImageView = [[UIImageView alloc] initWithImage:splashImageJawn];
	chooseModeImageView.frame = CGRectMake(0, 32, kWIDTH, kHEIGHT-32);
	chooseModeImageView.alpha = 1.0;
	
	// Loading content view
	loadingContentImageView = [[UIImageView alloc] initWithImage:splashImageJawn];
	loadingContentImageView.frame = CGRectMake(0, 32, kWIDTH, kHEIGHT-32);
	loadingContentImageView.alpha = 1.0;
	
    
    // Juliesays : seems unused, statusLabel never gets added to the view
	statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 100)];
	statusLabel.center = CGPointMake(loadingContentImageView.frame.size.width/2, loadingContentImageView.frame.size.height/4);
	statusLabel.textAlignment = NSTextAlignmentCenter;
	statusLabel.font = [UIFont systemFontOfSize:28.0f];
	statusLabel.textColor = [UIColor whiteColor];
	statusLabel.backgroundColor = [UIColor clearColor];
	statusLabel.adjustsFontSizeToFitWidth = NO;
	statusLabel.text = @"";
	
	mainViewController = [[MainViewController alloc] initWithTitle:@"Loading..."];
	mainViewController.view.alpha = 0.0;
	mainViewController.tabBarItem.image = [UIImage imageNamed:@"menu.png"];


	toolbarVisible = TRUE;
	
	// Create toolbar at top
	bar = [UIToolbar new];
	bar.barStyle = UIBarStyleBlackOpaque;
	
	// size up the toolbar and set its frame
	[bar sizeToFit];
	CGFloat toolbarHeight = 30.0f;
	[bar setFrame:CGRectMake(0,
							 0,
							 appFrame.size.height,
							 toolbarHeight)];
	
	//add button
	// create a bordered style button with custom image
    // Juliesays : seems unused, never added to the view
	measureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 15)];
	measureLabel.textAlignment = NSTextAlignmentCenter;
	measureLabel.font = [UIFont systemFontOfSize:13.0f];
	measureLabel.textColor = [UIColor whiteColor];
	measureLabel.backgroundColor = [UIColor clearColor];
	measureLabel.adjustsFontSizeToFitWidth = NO;
	measureLabel.text = @"Orchestra Companion";
	
    // Juliesays : seems unused
	networkReachableImage = [UIImage imageNamed:@"green_button.png"];
	networkNotReachableImage = [UIImage imageNamed:@"red_button.png"];
	networkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
	[networkImage setImage:networkNotReachableImage];

    // Juliesays : seems unused, never added to the view
	connectedItem = [[UIBarButtonItem alloc] initWithCustomView:networkImage];
	connectedItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	
	
	navigationController1 = [[UINavigationController alloc] initWithRootViewController:mainViewController];
	
   
    
    if([DeviceProperties isIOS7])
    {
       navigationController1.navigationBar.barTintColor = [UIColor clearColor];
       navigationController1.navigationBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        navigationController1.navigationBar.tintColor = [UIColor blackColor];
    }
    [navigationController1.navigationBar setTranslucent:NO];
	navigationController1.delegate = self;
	navigationController1.view.clipsToBounds = YES;

	NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               [UIColor clearColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    [navigationController1.navigationBar setBackgroundImage:[UIImage imageNamed:@"titleSmall32.png"] forBarMetrics:UIBarMetricsDefault];
    
	[self.view addSubview:navigationController1.view];
	
	[self.view addSubview:loadingContentImageView];
    
	
    // Juliesays : unused, SHOW_DREXELCAST_OPTION = 0
	if(SHOW_DREXELCAST_OPTION)
		[self.view addSubview:chooseModeImageView];
    
    sleep(2);
    [self.view addSubview:splashImageView];
	

	if(!SHOW_DREXELCAST_OPTION){
        // wait one second before calling fadeInLoadingScreen
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fadeInLoadingScreen) userInfo:nil repeats:NO];
		appDelegate.mode = LIVE_MODE;
		appDelegate.USE_SLIDE_FORMAT = YES;
		appDelegate.APPLICATION_STARTED = YES;
	}
	else{
		timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fadeInOptionScreen) userInfo:nil repeats:NO];

	}
	
}



#pragma mark -
#pragma mark UINavigationController delegate methods

- (void)navigationController:(UINavigationController *)anavigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
	anavigationController.navigationBar.frame = CGRectMake(0, 0, kWIDTH, 32);

    // Juliesays : TOFIX, there is a "if" statement, but it does the same thing in "else"
	if([viewController isKindOfClass:[UITabBarController class]]){
		anavigationController.navigationBar.alpha = 1.0;
	}
	else if([viewController isKindOfClass:[GlossaryViewController class]]){
		anavigationController.navigationBar.alpha = 1.0;
	}
}

- (void)navigationController:(UINavigationController *)anavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

BOOL pickerVisible = FALSE;
-(void) setConnected:(NSNumber *)connected {
	if ([connected boolValue]){
		networkImage.image = networkReachableImage;
	}
	else{
		networkImage.image = networkNotReachableImage;
	}
	
}

-(void) updateMeasure {
	if(appDelegate.APPLICATION_STARTED){
        
        if([mainViewController.labelViewBarsArray count]>1)
        {
            for(int i = 0; i< [mainViewController.labelViewBarsArray count];i++)
            {
                if([appDelegate.CURRENT_PIECE isEqualToString:[mainViewController.theAlbumNamesFull objectAtIndex:i]])
                {
                    [[mainViewController.labelViewBarsArray objectAtIndex:i] setLive:YES];
                }
                else
                {
                    [[mainViewController.labelViewBarsArray objectAtIndex:i] setLive:NO];
                }
            }
        }
        // Juliesays : seems unused, measureLabel is not used
        int currentMeasure = appDelegate.CURRENT_MEASURE;
		int totalMeasure = appDelegate.TOTAL_MEASURES;
		NSString * mString = [NSString stringWithFormat:@"%d / %d", currentMeasure, totalMeasure];
		measureLabel.text = mString;
	}
}

- (void)fadeInLoadingScreen
{
	[UIView beginAnimations:nil context:nil];  // begins animation block
	[UIView setAnimationDuration:1.0];         // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(startLoadingContent)];   // calls the finishedFading method when the animation is done (or done fading out)

	splashImageView.alpha = 0.0;
    

	if(SHOW_DREXELCAST_OPTION)
		chooseModeImageView.alpha = 0.0;
		
	loadingContentImageView.alpha = 1.0;
	
	[UIView commitAnimations];   // commits the animation block.  This Block is done.

}
-(void) finishedTitleScreen {
   //sleep(2);
	[splashImageView removeFromSuperview];
}

- (void)fadeInOptionScreen
{
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:1.0];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishedTitleScreen)];   // calls the finishedFading method when the animation is done (or done fading out)	
	
	splashImageView.alpha = 0.0;
	
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
}

- (void)fadeInMainScreen
{
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:1.0];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];   // calls the finishedFading method when the animation is done (or done fading out)	
	
	loadingContentImageView.alpha = 0.0;
	mainViewController.view.alpha = 1.0;
	
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
}

-(void) startLoadingContent {
	[NSThread detachNewThreadSelector: @selector(startConnectThread:) toTarget:mainViewController withObject:[NSNumber numberWithInt:5]];//initialize a thread that will poll server and send data based on change
	//BOOL connected = [mainViewController startConnectThread:[NSNumber numberWithInt:5]];
	statusLabel.text = @""; //Juliesays : seems unused
    //    [mainViewController createNewNavView];

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertsPresent = false;
}

-(void) finishedFading {
    
	[loadingContentImageView removeFromSuperview];

}

- (void) notifyFinished:(NSNumber *) success
{
	if ([success boolValue]){
		[mainViewController.tableView reloadData];
		[mainViewController.tableView scrollRectToVisible:CGRectMake(0, 1, kWIDTH, kHEIGHT) animated:NO];
		[self fadeInMainScreen];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error:" message:@"Unable to contact the database server at this time. Check your internet settings. You may still browse the app, which notify you when/if a connection is made." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Exit", nil];
		[alert show];
	}
	
	[NSThread detachNewThreadSelector: @selector(startConnectThread:) toTarget:mainViewController withObject:[NSNumber numberWithInt:0]];//initialize a thread that will poll server and send data based on change

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [[UIScreen mainScreen] setBrightness:0.3];
    [super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
}

// Juliesays : seems unused
- (void) goToLivePosition{
    [self.mainViewController goToLiveTabbar];
}




@end
