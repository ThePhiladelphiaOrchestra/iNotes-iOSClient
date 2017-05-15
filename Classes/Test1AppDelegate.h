//
//  Test1AppDelegate.h
//  Test1
//
//  Created by MattP Senior Design 2009 on 10/12/09.
//  Copyright Drexel University 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>


#import "SplashViewController.h"
#import "GlossaryViewController.h"
#import "constants.h"


#define SHOW_DREXELCAST_OPTION	0
#define SHOW_MODE_OPTION		0
#define INCLUDE_MAP_OPTION		1

typedef enum {
	DEMO_MODE, LIVE_MODE
} ProgramMode;


@interface Test1AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	//USE_SLIDE_FORMAT = 1;
    
    // ViewControllers
	SplashViewController *splashViewController;
	GlossaryViewController * glossary;
	
	int CURRENT_MEASURE;
	int TOTAL_MEASURES;
	
	int TEXT_SIZE;

	
	NSString * CURRENT_PIECE;
	NSString * CURRENT_TRACK;
	MusicPiece * CURRENT_DATA;
	
	NSString * SERVER_ADDRESS;
	NSString * DEFAULT_SERVER_ADDRESS;
	
	NSString * OFFLINE_FILE;
	
	BOOL CONNECTED_TO_SERVER;

	BOOL APPLICATION_STARTED;

	BOOL LIVE;
	
	BOOL USE_SLIDE_FORMAT;
	
	ProgramMode mode;
	AVAudioPlayer *player;
	
//	NSMutableArray * glossaryTerms;

}

-(void) adjustBrightness;
-(void) setSong:(NSString *)fileName;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) SplashViewController *splashViewController;
@property (nonatomic, retain) GlossaryViewController * glossary;
// @property (nonatomic, retain) NSMutableArray * glossaryTerms;
@property (nonatomic, retain) MusicPiece * CURRENT_DATA;

@property (assign) int TEXT_SIZE;
@property (assign) int CURRENT_MEASURE;
@property (assign) int TOTAL_MEASURES;
@property (assign) BOOL CONNECTED_TO_SERVER;
@property (assign) BOOL APPLICATION_STARTED;
@property (assign) BOOL LIVE;
@property (assign) BOOL USE_SLIDE_FORMAT;

@property (assign) ProgramMode mode;

@property (nonatomic, retain) NSString * CURRENT_PIECE;
@property (nonatomic, retain) NSString * OFFLINE_FILE;

@property (nonatomic, retain) NSString * CURRENT_TRACK;
@property (nonatomic, retain) NSString * SERVER_ADDRESS;
@property (nonatomic, retain) NSString * DEFAULT_SERVER_ADDRESS;
@property (nonatomic, retain) AVAudioPlayer *player;

@end

