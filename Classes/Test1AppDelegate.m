//
//  Test1AppDelegate.m
//  Test1
//
//  Created by MattP Senior Design 2009 on 10/12/09.
//  Copyright Drexel University 2009. All rights reserved.
//

#import "Test1AppDelegate.h"
@implementation Test1AppDelegate
@synthesize window, glossary, TEXT_SIZE,OFFLINE_FILE,CURRENT_DATA; // glossaryTerms
@synthesize splashViewController, mode, player;
@synthesize CURRENT_MEASURE, TOTAL_MEASURES, CURRENT_PIECE, CURRENT_TRACK,USE_SLIDE_FORMAT;
@synthesize SERVER_ADDRESS,DEFAULT_SERVER_ADDRESS, CONNECTED_TO_SERVER, APPLICATION_STARTED, LIVE;


- (void)applicationDidFinishLaunching:(UIApplication *)application {

	//[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	
    
//    // Juliesays : seems unused
//    glossaryTerms = [[NSMutableArray alloc] init];
	TEXT_SIZE = 15;
	
	CURRENT_MEASURE = 0;
	TOTAL_MEASURES = 0;
	CURRENT_PIECE = nil;
	CURRENT_TRACK = nil;
	CONNECTED_TO_SERVER = FALSE;
	APPLICATION_STARTED = FALSE;
	OFFLINE_FILE = @"June8th";
	LIVE = FALSE;
	
    
	self.SERVER_ADDRESS = DEFAULT_SERVER_ADDRESS;
	
    window.frame = [UIScreen mainScreen].bounds;
    
	splashViewController = [[SplashViewController alloc] init];
	glossary = [[GlossaryViewController alloc] init];
    // Override point for customization after app launch
    
    [window setRootViewController:splashViewController];
	[window makeKeyAndVisible];
    CGRect tempWindowFrame = window.bounds;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void) setSong:(NSString *)fileName {
	
	if(player){
		if(player.playing)
			[player stop];
    }
	
	NSArray * parts = [fileName componentsSeparatedByString: @"."];
	if([parts count] == 2){
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:[parts objectAtIndex:0] ofType:[parts objectAtIndex:1]]];
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		[player play];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	printf("Application closing");
}

- (void)terminateWithSuccess:(UIApplication *)application {
	printf("Application closing");
}

- (void)dealloc {
}


-(void) adjustBrightness
{
    CGFloat brightness = [[UIScreen mainScreen] brightness];
    
    if(brightness == 0.5)
    {
        brightness = 0;
    }
    else if(brightness>0.5)
    {
        brightness = 0.5;
    }
    else
    {
        brightness = brightness + 0.1;
    }
    
     NSLog(@"brightness:%f",brightness);
    [[UIScreen mainScreen] setBrightness:brightness];
}


@end

