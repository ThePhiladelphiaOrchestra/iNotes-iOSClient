//
//  NavigationViewController.m
//  Test1
//
//  Created by Matthew Prockup on 11/17/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "NavigationViewController.h"
#import "MainViewController.h"
#import "Test1AppDelegate.h"
#import "constants.h"

#define MAP_TOOLBAR_INSET	40
#define MAP_HEIGHT			50

#ifdef IS_IPAD
    #define MAX_TEXT_SIZE		48
    #define MIN_TEXT_SIZE		24
    #define FONT_MULTIPLIER      2
#else
    #define MAX_TEXT_SIZE		24
    #define MIN_TEXT_SIZE		12
    #define FONT_MULTIPLIER      1
#endif

@implementation NavigationViewController

@synthesize myTimer, pagePosistion, trackData, contentLoaded,annotationMarkerBar,goLiveButton,slidePosLabel;//trackSelector;

NSString * SERVER_ADDRESS = ADDRESS_OF_SERVER;

Test1AppDelegate * appDelegate;

BOOL memoryWarning = NO;

#pragma mark -
#pragma mark UI Init

- (id) initWithTrack:(Track *)track 
{
    kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
    kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
    BUTTON_SIZE = 25;
    
    int buttonCanvas = kHEIGHT - 32 - 2*kHEIGHT*.133;
    int numButtons = 3;
    int buttonSpace = buttonCanvas/numButtons;
    int buttonOffset = kHEIGHT*.133;
    BUTTON_Y1 = 10;
    BUTTON_Y3 = buttonOffset + 0 * buttonSpace + (buttonSpace-BUTTON_SIZE)/2;
    BUTTON_Y4 = buttonOffset + 1 * buttonSpace + (buttonSpace-BUTTON_SIZE)/2;
    BUTTON_Y5 = buttonOffset + 2 * buttonSpace + (buttonSpace-BUTTON_SIZE)/2;
    
    NSLog(@"1:%d,3:%d,4:%d,5:%d",BUTTON_Y1,BUTTON_Y3,BUTTON_Y4,BUTTON_Y5);
    
    tabsPresent = NO;
    
    cntGoLive = 0;
    mapExpanded = false;
    choosingTrack = false;
	self = [super init];
	if (self != nil) {
		self.contentLoaded = NO;
		self.tabBarItem.image = [UIImage imageNamed:@"table_gray.png"];
		self.title = [track name];
		self.trackData = track;
		
		loadedTickmarkers = NO;
		
		animating = NO;
		userInterjected = FALSE;
		
		pagePosistion = -1;
		
		appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
		
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, appFrame.size.height, appFrame.size.width)];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            appFrame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
            [scrollView setFrame:CGRectMake(0, 0, appFrame.size.width, appFrame.size.height)];
        }
		UIView *view = [[UIView alloc] initWithFrame:appFrame];
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.view = view;
        
		scrollView.delegate = self;
        scrollView.userInteractionEnabled = YES;
		scrollView.pagingEnabled = YES;
		scrollView.bounces = YES;
        scrollView.alwaysBounceVertical = NO;
		NSInteger widthCount = [trackData.pages count];

		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * widthCount,
											scrollView.frame.size.height);
		scrollView.contentOffset = CGPointMake(0, 0);
		

		currentPage = [[PageViewController alloc] initWithTrack:trackData withReference:self];
		nextPage = [[PageViewController alloc] initWithTrack:trackData withReference:self];
		

		[self applyNewIndex:0 pageController:currentPage];
		[self applyNewIndex:1 pageController:nextPage];
		[scrollView addSubview:currentPage.view];
		[scrollView addSubview:nextPage.view];
		[currentPage updateTextViews:YES];
		[nextPage updateTextViews:YES];
		
		[self.view addSubview:scrollView];
        
        [self addUIComponents:track];
        
        myTimer = [[NSTimer alloc] init];

    }
	return self;
}

-(void) addMapColors:(Track *)structureTrack
{
    NSLog(@"addMapColors called");
    [annotationMarkerBar drawMapSegments:structureTrack];
}

-(void) addWaveform:(Track *)waveTrack
{
    NSLog(@"addWaveform called");
    [annotationMarkerBar addWaveform:waveTrack];
}

-(void) addUIComponents:(Track *)track
{
    
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    goLiveButton = [[UIBarButtonItem alloc]
                    initWithTitle:@"Live"
                    style:UIBarButtonItemStyleBordered
                    target:self
                    action:@selector(goToLivePosition)];
    
    
    [goLiveButton setTintColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
    [goLiveButton setTintColor:[UIColor redColor]];
    [goLiveButton setTitle:@"Live"];
    
    [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
    
    
    //ANNOTATION POSITION TIMELINE
    toolBar = [[MapToolBar alloc] initWithFrame:CGRectMake(0, 0, 345, MAP_HEIGHT/2)];
    toolBar.track = track;
    [toolBar setNeedsLayout];
    [toolBar setNeedsDisplay];
    UIBarButtonItem * mapButton = [[UIBarButtonItem alloc] initWithCustomView:toolBar]; // Juliesays : seems unused
    
    
    //BOTTOM TOOLBAR Juliesays : This naviToolBar is not used anymore
    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *items = [NSArray arrayWithObjects: flexibleSpace1, mapButton, flexibleSpace2, nil];
    UIToolbar * naviToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0,kHEIGHT*.8, kWIDTH, kHEIGHT*.1)];
    
    if([DeviceProperties isIOS7]){ //iOS7
        [naviToolBar setBarTintColor: [UIColor clearColor]];
    }
    else{
        [naviToolBar setTintColor: [UIColor clearColor]];
    }
    
    naviToolBar.tintColor =  [UIColor whiteColor];
    [naviToolBar setItems:items animated:NO];
    
    //BUTTON TOOLBAR
    NSLog(@"allocating the marker bar in addUIComponents");
    annotationMarkerBar = [[AnnotationMarkerBarView alloc] initWithFrame:CGRectMake(0, kHEIGHT-30-MAP_HEIGHT, kWIDTH,MAP_HEIGHT)];
    [annotationMarkerBar addMarkers:track];
    
    NSLog(@"Adding the Timeline to the view");
    [self.view addSubview:annotationMarkerBar];
    
    //HELP BUTTON
    helpButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
    helpButton.userInteractionEnabled = YES;
    helpButton.tagText = @"help";
    [helpButton setBackgroundImage:HELP_ICON_SLIDE_IMAGE forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(preferenceButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    programNotes = [[ProgramNotesViewController alloc] initWithSpace];
    programNotes.title = @"HELP";
    
    
    //TEXT SIZE BUTTON
    textSizeButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
    textSizeButton.userInteractionEnabled = YES;
    textSizeButton.tagText = @"up";
    [textSizeButton setBackgroundImage:TEXT_SIZE_ICON_SLIDE_IMAGE forState:UIControlStateNormal];
    [textSizeButton addTarget:self action:@selector(preferenceButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    
    //GO TO LIVE BUTTON
    liveButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, 20)];
    liveButton.backgroundColor = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    [[liveButton layer] setCornerRadius:0.01f];
    [liveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [liveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [liveButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [liveButton setTitle:@"Touch to return to LIVE" forState:UIControlStateNormal];
    [liveButton addTarget:self action:@selector(goLive) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:liveButton];
    
    //FAVORITES BUTTON
    //NOT USED AND NOT FULLY IMPLEMENTED YET
    favoriteButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
    favoriteButton.userInteractionEnabled = YES;
    favoriteButton.tagText = @"favorite";
    [favoriteButton setBackgroundImage:FAVORITES_ICON_SLIDE_IMAGE forState:UIControlStateNormal];
    [favoriteButton addTarget:self action:@selector(preferenceButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    //BRIGHTNESS BUTTON
    brightButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
    brightButton.userInteractionEnabled = YES;
    brightButton.tagText = @"brightness";
    [brightButton setBackgroundImage:BRIGHTNESS_ICON_SLIDE_IMAGE forState:UIControlStateNormal];
    [brightButton addTarget:self action:@selector(preferenceButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    
    slidePosLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWIDTH-75, BUTTON_Y1, 65, BUTTON_SIZE)];
    [slidePosLabel setTextAlignment:NSTextAlignmentRight];
    slidePosLabel.font = SLIDE_POSITION_FONT;
    [slidePosLabel setTextColor:SLIDE_POSITION_TEXT_COLOR];
    [slidePosLabel setBackgroundColor:[UIColor clearColor]];
    [slidePosLabel setAlpha:1.0];
    
    
    trackButtonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, kHEIGHT*0.2)];
    trackButtonScrollView.backgroundColor = [UIColor clearColor];
    [trackButtonScrollView setShowsHorizontalScrollIndicator:NO];
    [trackButtonScrollView setShowsVerticalScrollIndicator:NO];
    [trackButtonScrollView setBounces:NO];
    
    trackSelectPointer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [trackSelectPointer setImage:TRACK_TIP_ICON_IMAGE];

    
    
    //ADD BUTTONS TO ITEMS TO VIEW

    [self.view addSubview:trackButtonScrollView];
    trackButtonScrollView.userInteractionEnabled = YES;
    trackButtonScrollView.bounces = YES;
    
    [trackButtonScrollView addSubview:trackSelectPointer];
    [trackSelectPointer setHidden:YES];
    
    [self updateCurrentPageAndTrackButtons];
    [self.view addSubview:slidePosLabel];
    
    [favoriteButton setFrame:CGRectMake(kWIDTH-35, BUTTON_Y2, BUTTON_SIZE, BUTTON_SIZE)];
    [favoriteButton setAlpha:0.5];
//    [self.view addSubview:favoriteButton];
    
    [textSizeButton setFrame:CGRectMake(kWIDTH-35, BUTTON_Y3, BUTTON_SIZE, BUTTON_SIZE)];
    [textSizeButton setAlpha:0.5];
    [self.view addSubview:textSizeButton];
    
    [brightButton setFrame:CGRectMake(kWIDTH-35, BUTTON_Y4, BUTTON_SIZE, BUTTON_SIZE)];
    [brightButton setAlpha:0.5];
    [self.view addSubview:brightButton];
    
    [helpButton setFrame:CGRectMake(kWIDTH-35, BUTTON_Y5, BUTTON_SIZE, BUTTON_SIZE)];
    [helpButton setAlpha:0.5];
    [self.view addSubview:helpButton];
    
    [self.view bringSubviewToFront:annotationMarkerBar];
}

#pragma mark -
#pragma mark UI Interaction
//In a method called hideLabel
- (void) killHelp
{
    
    [UIView beginAnimations:@"fade" context:nil];
    [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] setAlpha:0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadeAnimationDidStop:finished:context:)];
    [UIView commitAnimations];
    self.navigationController.view.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    
    
}

- (void)fadeAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] removeFromSuperview]; //This assumes that your label is a property of your view controller
    
}

- (void) preferenceButtonsActivated:(id)sender {
	if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"up"] ){
        NSLog(@"Changing Font Size");
		int size = appDelegate.TEXT_SIZE + 2*FONT_MULTIPLIER;
		if (size < MAX_TEXT_SIZE) {
			appDelegate.TEXT_SIZE = size;
			currentPage.pageIndex = currentPage.pageIndex;
            nextPage.pageIndex = nextPage.pageIndex;
		}
        else
        {
            appDelegate.TEXT_SIZE = 14*FONT_MULTIPLIER;
            currentPage.pageIndex = currentPage.pageIndex;
            nextPage.pageIndex = nextPage.pageIndex;
        }
		
	}
	else if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"help"] ){
        NSLog(@"Getting Help");
        UIImageView *someImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHEIGHT, kWIDTH)];
        
        NSString* loadFileName;
        if([DeviceProperties getDeviceResolutionLandscape].width == 480)
        {
            if(tabsPresent){
                loadFileName = SLIDE_VIEW_HELP_TRACKS_32;
            }
            else{
                loadFileName = SLIDE_VIEW_HELP_NO_TRACKS_32;
            }
            
        }
        else{
            if(tabsPresent){
                loadFileName = SLIDE_VIEW_HELP_TRACKS_169;
            }
            else{
                loadFileName = SLIDE_VIEW_HELP_NO_TRACKS_169;
            }
        }
        
        NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"http://%@/images/AppAssets/%@",SERVER_ADDRESS,loadFileName];

        
        NSLog(@"%@",tempImageStrUrltemp);
        NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
        
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
            data = [NSData dataWithContentsOfURL:url];
        }
        
        if(data==nil)
        {
            data = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],loadFileName]];
        }
        
        
        UIImage *helpImage = [[UIImage alloc] initWithData:data];
        
        [someImageView setImage:helpImage];
        [someImageView setAlpha:0.0];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            someImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            someImageView.frame =  CGRectMake(0, 0, kWIDTH, kHEIGHT);
        }
        
        self.navigationController.view.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:someImageView];
        
        [UIView beginAnimations:@"fade" context:nil];
        [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] setAlpha:1.0];
        [UIView commitAnimations];
        
        
        [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(killHelp) userInfo:nil repeats:NO];
    }
    else if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"brightness"] )
    {
        NSLog(@"Adjusting Brightness from NavigationViewController");
        Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate adjustBrightness];
	}
    else if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"commentary"] )
    {
        NSLog(@"Selecting Commentary Track");
        
        if(!choosingTrack)
        {
            choosingTrack = true;
            Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSMutableArray* piecesTemp = [[NSMutableArray alloc] initWithArray:appDelegate.splashViewController.mainViewController.thePieces];
            
            //get Track names for current piece
            NSMutableArray* currentPieceTracks = [[NSMutableArray alloc] init];
            for(MusicPiece* p in piecesTemp)
            {
                if([[p name] isEqualToString:[trackData pieceName]])
                {
                    NSMutableArray* tracks = [[NSMutableArray alloc] initWithArray:[p tracks]];
                    for(Track* t in tracks)
                    {
                        if(!([[t name] isEqualToString:@"NumSeconds"] || [[t name] isEqualToString:@"Structure"] || [[t name] isEqualToString:@"Waveform"]))
                        {
                            NSLog(@"%@",[t name]);
                            [currentPieceTracks addObject:t];
                        }
                    }
                }
            }
            int yOffset = 40;
            int imageCount = 1;
            for(Track* t in currentPieceTracks)
            {
                UITaggedButton* trackButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-250-40, yOffset , 250, 50)];
                trackButton.userInteractionEnabled = YES;
                trackButton.tagText = [t name];
                
                UILabel* buttonText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,250,50)];
                
                [buttonText setText:[t name]];
                if([[t name] isEqualToString:[trackData name]])
                {
                    UIColor* highlight = SELECTED_TAB_TEXT_COLOR;
                    buttonText.textColor = highlight;
                    [buttonText setFont:SELECTED_TAB_FONT];
                    [buttonText setBackgroundColor:SELECTED_TAB_BG_COLOR];
                    [buttonText setTextAlignment:NSTextAlignmentCenter];
                    
                }
                else{
                    buttonText.textColor = TAB_TEXT_COLOR;
                    [buttonText setFont:TAB_FONT];
                    [buttonText setBackgroundColor:TAB_BG_COLOR];
                    [buttonText setTextAlignment:NSTextAlignmentCenter];
                    
                }
                UIImage* backImage;
                if(imageCount == 1)
                {
                    backImage = [UIImage imageNamed:@"trackBackgroundFirstFlip.png"];
                    [trackButton setBackgroundImage:backImage forState:UIControlStateNormal];
                }
                else
                {
                    backImage = [UIImage imageNamed:@"trackBackgroundFlip.png"];
                    [trackButton setBackgroundImage:backImage forState:UIControlStateNormal];
                }
                yOffset = yOffset + 48;
                imageCount++;
                trackButton.alpha = 0.0;
                [trackButton addTarget:self action:@selector(trackButtonsActivated:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:trackButton];
                [trackButton addSubview:buttonText];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [trackButton setAlpha:1.0];
                [UIView commitAnimations];
                
            }
        }
        else
        {
            choosingTrack = false;
            Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSMutableArray* piecesTemp = [[NSMutableArray alloc] initWithArray:appDelegate.splashViewController.mainViewController.thePieces];
            
            //get Track names for current piece
            NSMutableArray* currentPieceTracks = [[NSMutableArray alloc] init];
            for(MusicPiece* p in piecesTemp)
            {
                if([[p name] isEqualToString:[trackData pieceName]])
                {
                    NSMutableArray* tracks = [[NSMutableArray alloc] initWithArray:[p tracks]];
                    for(Track* t in tracks)
                    {
                        if(!([[t name] isEqualToString:@"NumSeconds"] || [[t name] isEqualToString:@"Structure"] || [[t name] isEqualToString:@"Waveform"]))
                        {
                            NSLog(@"%@",[t name]);
                            [currentPieceTracks addObject:t];
                        }
                    }
                }
            }
            int trackCount = 0;
            for(Track* t in currentPieceTracks)
            {
                [[self.view.subviews objectAtIndex:[self.view.subviews count]-1] removeFromSuperview];
                trackCount++;
            }
        }
	}
}

- (void) trackButtonsActivated:(id)sender {
    
    choosingTrack = false;
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray* piecesTemp = [[NSMutableArray alloc] initWithArray:appDelegate.splashViewController.mainViewController.thePieces];
    
    //get Track names for current piece
    NSMutableArray* currentPieceTracks = [[NSMutableArray alloc] init];
    for(MusicPiece* p in piecesTemp)
    {
        if([[p name] isEqualToString:[trackData pieceName]])
        {
            NSMutableArray* tracks = [[NSMutableArray alloc] initWithArray:[p tracks]];
            for(Track* t in tracks)
            {
                if(!([[t name] isEqualToString:@"NumSeconds"] || [[t name] isEqualToString:@"Structure"] || [[t name] isEqualToString:@"Waveform"]))
                {
                    NSLog(@"%@",[t name]);
                    [currentPieceTracks addObject:t];
                }
            }
        }
    }
    
    
    
    
    int trackCount = 0;
    for(Track* t in currentPieceTracks)
    {
        if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:[t name]])
        {
            //push right track;
            [appDelegate.splashViewController.mainViewController.trackTabBar setSelectedIndex:trackCount];
            appDelegate.splashViewController.mainViewController.currentTrackIndex = trackCount;
        }
        trackCount++;
    }

}

- (void) pushProgramNotes {
	self.navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    programNotes.navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    CGFloat width = self.view.frame.size.width;
    UIImageView* appInstrTemp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appInstr.png"]];
    [appInstrTemp setFrame:CGRectMake(0, 30, kWIDTH, kHEIGHT-30)];
    [programNotes.view addSubview:appInstrTemp];
    UIToolbar * navBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
    [navBar setBackgroundColor: [UIColor clearColor]];
    navBar.tintColor =  [UIColor blackColor];

    UITaggedButton * closeButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(420, 0, 50, 23)];     closeButton.userInteractionEnabled = YES;
    closeButton.tagText = @"close";
    [closeButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeInfo:) forControlEvents:UIControlEventTouchDown];
    [closeButton setTitle:@"  back" forState:UIControlStateNormal]; 
    [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    UIBarButtonItem *closeButtonBarItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    NSArray *items = [NSArray arrayWithObjects: closeButtonBarItem, nil];
    [navBar setItems:items animated:NO];

    
    [programNotes.view addSubview:navBar];

    [programNotes.view setBackgroundColor:[UIColor clearColor]];
    [self.navigationController pushViewController:programNotes animated:YES];
}

-(void) closeInfo:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
    programNotes = [[ProgramNotesViewController alloc] initWithSpace];
    programNotes.title = @"Program Notes";
    
}

- (void) showMenu {
	[appDelegate.splashViewController.mainViewController fadeTabBar];
	
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	slider = [[UISlider alloc] init];
	CGRect rect = CGRectMake( 0, 0, 355, 10);
	slider.frame = rect;
	
	slider.maximumValue = [self.trackData numMeasures];
	slider.minimumValue = 1;
	
    
	// This is a hack for right now, because it forces the scrollview to repaint
	NSInteger pageIndex = 0;
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageIndex;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
}
- (void) goToLivePosition{
    NSLog(@"Going Live JAWN");
    
    NSMutableArray* allNames = appDelegate.splashViewController.mainViewController.thePieces;
    
    //int indexTemp = 0;
    for(int p = 0;p< [allNames count];p++)
    {
        int trackCount = 0;
        NSString* pieceName = [[allNames objectAtIndex:p] name];
        for(int i = 0; i<[[appDelegate.splashViewController.mainViewController.arrayOfTracks objectForKey:pieceName] count]; i++)
        {
            [[[appDelegate.splashViewController.mainViewController.arrayOfTracks objectForKey:pieceName] objectAtIndex:i] goLive];
            if([[[[[appDelegate.splashViewController.mainViewController.arrayOfTracks objectForKey:pieceName] objectAtIndex:i] trackData] name] isEqualToString:[trackData name]] && [pieceName isEqualToString:[trackData pieceName]]){
                //indexTemp = trackCount;
            }
            trackCount++;
        }
    }
    if([appDelegate.CURRENT_PIECE isEqualToString:[trackData pieceName]])
    {
        [appDelegate.splashViewController.mainViewController.trackTabBar setSelectedIndex:appDelegate.splashViewController.mainViewController.currentTrackIndex];
    }
}

-(void)goLive {
    
    if(appDelegate.splashViewController.onlineMode)
    {
        userInterjected = FALSE;
        liveButton.enabled = FALSE;
        liveButton.hidden = true;
        appDelegate.LIVE =  YES;
        [goLiveButton setTintColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
        [goLiveButton setTitle:@"Live"];
        
        if(![trackData.pieceName isEqualToString:appDelegate.CURRENT_PIECE]){
            
            [appDelegate.splashViewController.mainViewController goToLiveTabbar];
            appDelegate.splashViewController.mainViewController->mode = CONNECT_MULTI;
                        
        }
        else{
            [self checkUpdatePage:nil];
        }
        [self updateCurrentPageAndTrackButtons];
    }
    else{
        
        appDelegate.splashViewController.mainViewController->mode = CONNECT_MULTI;
    }
    
	
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}


#pragma mark -
#pragma mark Page Controller Stuff

- (void) loadPages {
	if(!contentLoaded){
		contentLoaded = YES;
	}
	
}

- (void)applyNewIndex:(NSInteger)newIndex pageController:(PageViewController *)pageController
{
	NSInteger pageCount = [trackData.pages count] ;
	BOOL outOfBounds = newIndex >= pageCount || newIndex < 0;
	
	if (!outOfBounds)
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = 0;
		pageFrame.origin.x = scrollView.frame.size.width * newIndex;
		pageController.view.frame = pageFrame;
	}
	else
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = scrollView.frame.size.height;
		pageController.view.frame = pageFrame;
	}
	
	[pageController setPageIndex:newIndex];
    [self updateCurrentPage];
}

- (void) changePage
{
	NSInteger pageIndex = pageControl.currentPage;
	
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageIndex;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	
	pageControlIsChangingPage = YES;
    
}

-(void) goToPage:(NSInteger)index animated:(BOOL) animated{
	
	// are we within the bounds of the measures of the current piece ?
	if(index >= 0 && index <= [trackData.pages count] && index != pagePosistion ) {
		
		if (animated){
            
			// update the scroll view to the appropriate page
			CGRect frame = scrollView.frame;
			frame.origin.x = frame.size.width * (index);
			frame.origin.y = 0;
			[scrollView scrollRectToVisible:frame animated:!memoryWarning];
			
			//[slider setValue:((float)index/(float)[trackData.pages count])*(float)[trackData numMeasures] animated:NO];
            
            
		}
		else{
            
            
		}
		
		pagePosistion = index;
        
		
	}
	[self updateCurrentPage];
	[self.view setNeedsLayout];
}


#pragma mark -
#pragma mark Scroll View Stuff

- (void)scrollViewWillBeginZooming:(UIScrollView *)sender
{
	printf("Will Begin Zoom\n");
	
}

- (void)scrollViewDidEndZooming:(UIScrollView *)sender atScale:(float)scale
{
    NSLog(@"\n\nScrollView ZOOM\n");
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	
	if (lowerNumber == currentPage.pageIndex)
	{
		if (upperNumber != nextPage.pageIndex)
		{
			// forwards
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	else if (upperNumber == currentPage.pageIndex)
	{
		if (lowerNumber != nextPage.pageIndex)
		{
			// back wards
			[self applyNewIndex:lowerNumber pageController:nextPage];
		}
	}
	else
	{
		if (lowerNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:currentPage];
		}
		else if (upperNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
		}
		else
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	[currentPage updateTextViews:NO];
	[nextPage updateTextViews:NO];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView
{
	pageControlIsChangingPage = NO;

    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
	
	if (currentPage.pageIndex != nearestNumber)
	{
		PageViewController *swapController = currentPage;
		currentPage = nextPage;
		nextPage = swapController;
	}
	
	[currentPage updateTextViews:YES];
    [self updateCurrentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)newScrollView
{
	[self scrollViewDidEndScrollingAnimation:newScrollView];
	pageControl.currentPage = currentPage.pageIndex;
	
	if(pagePosistion != currentPage.pageIndex){
		if(appDelegate.mode == LIVE_MODE){
            userInterjected = TRUE;
            liveButton.enabled = TRUE;
            liveButton.hidden = FALSE;
            
            if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window)&&(self.isViewLoaded && self.view.window))
            {
                [goLiveButton setTintColor:[UIColor redColor]];
                [goLiveButton setTitle:@"Live"];
                [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
            }
            appDelegate.LIVE = NO;
		}
		else{
			liveButton.enabled = TRUE;
			liveButton.hidden = FALSE;
			appDelegate.LIVE = NO;
            
            if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window))
            {
                [goLiveButton setTintColor:[UIColor redColor]];
                [goLiveButton setTitle:@"Live"];
                [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
            }
		}
	}
	
	pagePosistion = currentPage.pageIndex;
	
	if(appDelegate.mode == LIVE_MODE)
		[slider setValue:(float)(((float)pagePosistion/(float)[trackData.pages count])*trackData.numMeasures) animated:NO];
	

}



#pragma mark -
#pragma mark Touch Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   }

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    NSLog(@"Timeline touched");
    if(mapExpanded)
    {
        NSLog(@"Closing the Map");
        [annotationMarkerBar collapseView];
        mapExpanded = NO;
    }
    else
    {
        NSLog(@"Expending the Map");
        [annotationMarkerBar expandView];
        mapExpanded = YES;
    }
}

- (void) slide:(BOOL) left
{
	CATransition* trans = [CATransition animation];
	[trans setType:kCATransitionFade];
	[trans setDuration:0.5];
	if (!left)
		[trans setSubtype:(kCATransitionFromLeft)];
	else
		[trans setSubtype:(kCATransitionFromRight)];
    
	// code to change the view//
	[[self.view layer] addAnimation:trans forKey:@"Transition"];
}





#pragma mark -
#pragma mark OTHER SHIT

#pragma mark -
#pragma mark BlinkyText Shit

static BOOL showSlideFingerOption = TRUE;

-(void) stopBlinkyText {
	showSlideFingerOption = FALSE;
	slideLabel.hidden = YES;
	rightArrow.hidden = YES;
	leftArrow.hidden = YES;
	stopBlinkingButton.hidden = YES;
	[timer invalidate];
}

-(void) startBlinkyText {
	if(showSlideFingerOption){
		[UIView beginAnimations:nil context:nil]; // begins animation block
		[UIView setAnimationDuration:1.0];        // sets animation duration
		[UIView setAnimationDelegate:self];        // sets delegate for this block
		[UIView setAnimationDidStopSelector:@selector(finishedBlinkyText)];   // calls the finishedFading method when the animation is done (or done fading out)
		slideLabel.alpha = 1.0;
		rightArrow.alpha = 1.0;
		leftArrow.alpha = 1.0;
		stopBlinkingButton.alpha = 1.0;
		[UIView commitAnimations];   // commits the animation block.  This Block is done.
	}
	else{
		[self stopBlinkyText];
	}
	
}

-(void) finishedBlinkyText {
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:1.0];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	
	slideLabel.alpha = 0.0;
	rightArrow.alpha = 0.0;
	leftArrow.alpha = 0.0;
	stopBlinkingButton.alpha = 0.0;
	
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
	
}
#pragma mark -
#pragma mark Timer Shit

-(void) startTimer {
	myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkUpdatePage:) userInfo:nil repeats:YES];// init timer to call onTime function once per second
}

-(void) stopTimer {
	if([myTimer isValid])
		[myTimer invalidate];
}



#pragma mark -
#pragma mark Button callbacks

- (void) rewindCallback {
	if(appDelegate.mode == LIVE_MODE){
		userInterjected = TRUE;
		liveButton.enabled = TRUE;
        liveButton.hidden = FALSE;
        if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window))
        {
            [goLiveButton setTintColor:[UIColor redColor]];
            [goLiveButton setTitle:@"Live"];
            [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
        }
        
		appDelegate.LIVE = NO;
        
		[self goToPage:(pagePosistion - 1) animated:TRUE];
        
		[slider setValue:(float)(((float)pagePosistion/(float)[trackData.pages count])*trackData.numMeasures) animated:NO];
	}
	else{
		appDelegate.LIVE = NO;
		
		DataPage * page = [trackData pageWithLastTime:[appDelegate.player currentTime]];
		int newPagePosition = [trackData.pages indexOfObject:page] -1 ;
		if(newPagePosition >= 0){
			DataPage * next = [trackData.pages objectAtIndex:newPagePosition];
			appDelegate.player.currentTime = next.time;
		}
		
		appDelegate.LIVE = YES;
	}
	
}

- (void) forwardCallback {
	if(appDelegate.mode == LIVE_MODE){
		userInterjected = TRUE;
		liveButton.enabled = TRUE;
        liveButton.hidden = FALSE;
        if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window))
        {
            [goLiveButton setTintColor:[UIColor redColor]];
            [goLiveButton setTitle:@"Live"];
            [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
        }
		appDelegate.LIVE = NO;
        
		[self goToPage:(pagePosistion + 1) animated:TRUE];
        
		[slider setValue:(float)(((float)pagePosistion/(float)[trackData.pages count])*trackData.numMeasures) animated:NO];
	}
	else{
		appDelegate.LIVE = NO;
		
		DataPage * page = [trackData pageWithLastTime:[appDelegate.player currentTime]];
		int newPagePosition = [trackData.pages indexOfObject:page] + 1;
		if(newPagePosition < [trackData.pages count]){
			DataPage * next = [trackData.pages objectAtIndex:newPagePosition];
			appDelegate.player.currentTime = next.time;
		}
		
		appDelegate.LIVE = YES;
	}
}



#pragma mark -
#pragma mark Slider clallbacks


BOOL sliderMoving = FALSE;

-(void) showSliderPosition {
	if(appDelegate.mode == LIVE_MODE){
		printf("Touched slider\n");
		sliderMarkerText.text = [NSString stringWithFormat:@"%d", (int)slider.value];
		float width = slider.bounds.size.width - 10;
		float percent = ((float)[slider value])/((float)trackData.numMeasures);
	
		measureMarkerImageView.center = CGPointMake(slider.frame.origin.x + percent*width, 280);
		measureMarkerImageView.hidden = FALSE;
	}
}

- (void) sliderCallback {
	appDelegate.LIVE = NO;
	sliderMoving = TRUE;
	if(appDelegate.mode == LIVE_MODE){

		sliderMarkerText.text = [NSString stringWithFormat:@"%d", (int)[slider value]];
		float width = slider.bounds.size.width - 10;
		float percent = ((float)[slider value])/((float)trackData.numMeasures);
		measureMarkerImageView.center = CGPointMake(slider.frame.origin.x + percent*(width), 280);
	}
	else{
		if(![appDelegate.player isPlaying]){
			[appDelegate.player play];
		}
	}
}

-(void) sliderStopped {
	int value = (int)[slider value];
	sliderMoving = FALSE;

	if(appDelegate.mode == LIVE_MODE){
		DataPage * page = [trackData pageWithLastAnnotation:value];
		int newPagePosition = [trackData.pages indexOfObject:page];
		
		if( newPagePosition != pagePosistion){
			userInterjected = TRUE;
			liveButton.enabled = TRUE;
			liveButton.hidden = FALSE;
			appDelegate.LIVE = NO;
            if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window))
            {
                [goLiveButton setTintColor:[UIColor redColor]];
                [goLiveButton setTitle:@"Live"];
                [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
            }
			
			[self goToPage:newPagePosition animated:TRUE];
		}
		measureMarkerImageView.hidden = YES;
	}
	else{
		if(![appDelegate.player isPlaying]){
			[appDelegate.player play];
		}
		appDelegate.player.currentTime = slider.value;
		appDelegate.LIVE = YES;
	}
}

#pragma mark -
#pragma mark Update Page Timer

- (void)checkUpdatePage:(NSTimer *)timer {
    
    NSLog(@"Checking Update Page");
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
	int currentMeasure = appDelegate.CURRENT_MEASURE;
    
    NSLog(@"Updating the Marker Bar in checkUpdatePage");
    [annotationMarkerBar updateBarView:currentMeasure];
    [annotationMarkerBar setNeedsDisplay];
    
	if(appDelegate.APPLICATION_STARTED && [trackData.pieceName isEqualToString:appDelegate.CURRENT_PIECE]){
		
		if(appDelegate.mode == LIVE_MODE){
            
			NSLog(@"PagePosition: %d", pagePosistion);
			DataPage * page = [trackData pageWithLastAnnotation:currentMeasure];
			if(page){
                int newPagePosition = [trackData.pages indexOfObject:page];
                if (pagePosistion != newPagePosition && appDelegate.LIVE){
                    [self goToPage:newPagePosition animated:TRUE];
                    liveButton.enabled = NO;
                    liveButton.hidden = true;
                    if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window)){
                        [goLiveButton setTintColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
                        [goLiveButton setTitle:@"Live"];
                        [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
                    }
                    NSLog(@"Went to live");
                }
			}
            
			[pointerText performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d",currentMeasure] waitUntilDone:YES];
            
            pointerImageView.frame = CGRectMake(((float)currentMeasure/(float)trackData.numMeasures)*(toolBar.frame.size.width) + toolBar.frame.origin.x - pointerImageView.bounds.size.width/2,
												298-33+slider.bounds.origin.y,
												pointerImageView.bounds.size.width,
												pointerImageView.bounds.size.height);
            [self.view bringSubviewToFront:pointerImageView];
		}
		else{
            
            DataPage * page = [trackData pageWithClosestTime:[appDelegate.player currentTime]];
            if(page){
                int newPagePosition = [trackData.pages indexOfObject:page];
                if (pagePosistion != newPagePosition && appDelegate.LIVE){
                    [self goToPage:newPagePosition animated:TRUE];
                    liveButton.enabled = NO;
                    liveButton.hidden = true;
                    if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window)){
                        [goLiveButton setTintColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
                        [goLiveButton setTitle:@"Live"];
                        [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
                    }
                }
                
                [pointerText performSelectorOnMainThread:@selector(setText:) withObject:[self timeToString:[appDelegate.player currentTime]] waitUntilDone:YES];
                pointerImageView.frame = CGRectMake(([appDelegate.player currentTime]/[appDelegate.player duration])*(toolBar.frame.size.width) + toolBar.frame.origin.x - pointerImageView.bounds.size.width/2,
                                                    298-33+slider.bounds.origin.y,
                                                    pointerImageView.bounds.size.width,
                                                    pointerImageView.bounds.size.height);
                [self.view bringSubviewToFront:pointerImageView];
                
			}
			
		}
        
	}
	else{
        if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window))
        {
            liveButton.enabled = YES;
            liveButton.hidden = FALSE;
            [goLiveButton setTintColor:[UIColor redColor]];
            [goLiveButton setTitle:@"Live"];
            [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
            [self.view bringSubviewToFront:pointerImageView];
        }
	}
	
	
	
	if(!showSlideFingerOption){
		slideLabel.hidden = YES;
		stopBlinkingButton.hidden = YES;
	}
    [self updateCurrentPage];
}

- (NSString *) timeToString:(double) input{
	int seconds = (int)fmod(input, 60.0);
	int hours = (int)(input/60.0);
	
	if (seconds < 10)
		return [NSString stringWithFormat:@"%d:0%d",hours,seconds];
	else
		return [NSString stringWithFormat:@"%d:%d",hours,seconds];

}

#define PAGE_FLIP_TIME 0.75

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
    kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;

    if([trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE]&&(self.isViewLoaded && self.view.window)){
        [goLiveButton setTintColor:[UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0]];
        [goLiveButton setTitle:@"Live"];
        [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];
    }

}


-(void)viewWillAppear:(BOOL)animated
{
    [currentPage setPageIndex:currentPage.pageIndex];
    [nextPage setPageIndex:nextPage.pageIndex];
    if(![trackData.pieceName isEqualToString: appDelegate.CURRENT_PIECE])
    {
        [goLiveButton setTintColor:[UIColor redColor]];
        [goLiveButton setTitle:@"Live"];
    }
    
    if([DeviceProperties isIOS7]){ //iOS7
       
         [[UITabBar appearance] setBarTintColor:[UIColor clearColor]];
    }
    else{
        
         [[UITabBar appearance] setTintColor:[UIColor clearColor]];
    }
    [appDelegate.splashViewController.mainViewController.trackTabBar.navigationItem setRightBarButtonItem:goLiveButton];

   
}
- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"View shown");
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	memoryWarning = YES;
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void)addAView:(UIView*)view
{
    [self.view addSubview:view];
}

- (void)dealloc {

}


-(void) updateCurrentPageAndTrackButtons
{
    [self updateCurrentPage];
    [self updateTrackButtons];
}

-(void) updateCurrentPage
{
    NSString* tempStr =[NSString stringWithFormat:@"%d of %d",currentPage.pageIndex + 1,[trackData.pages count]];
    [slidePosLabel setText:tempStr];
}

-(void) updateTrackButtons
{
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray* piecesTemp = [[NSMutableArray alloc] initWithArray:appDelegate.splashViewController.mainViewController.thePieces];
    
    //get Track names for current piece
    NSMutableArray* currentPieceTracks = [[NSMutableArray alloc] init];
    for(MusicPiece* p in piecesTemp)
    {
        if([[p name] isEqualToString:[trackData pieceName]])
        {
            NSMutableArray* tracks = [[NSMutableArray alloc] initWithArray:[p tracks]];
            for(Track* t in tracks)
            {
                if(!([[t name] isEqualToString:@"NumSeconds"] || [[t name] isEqualToString:@"Structure"] || [[t name] isEqualToString:@"Waveform"]))
                {
                    NSLog(@"%@",[t name]);
                    [currentPieceTracks addObject:t];
                }
            }
        }
    }
    
    int yOffset = 0.0;
    int buttonHeight = kHEIGHT*0.133;
    int buttonWidth = (int)((kWIDTH*0.8)/currentPieceTracks.count);
    int xOffset = 0;
    int pointerHeight = 16;
    int pointerWidth = 20;
    
    if(currentPieceTracks.count != 1)
    {
        trackSelectPointer.hidden = NO;
        [currentPage.webView setFrame:  CGRectMake(0, 0, kWIDTH, kHEIGHT - kHEIGHT*.1 - kHEIGHT*.1*.5 - 32)];
        [nextPage.webView setFrame:     CGRectMake(0, 0, kWIDTH, kHEIGHT - kHEIGHT*.1 - kHEIGHT*.1*.5 - 32)];
        
        nextPage.webView.scrollView.contentInset = UIEdgeInsetsMake(buttonHeight, 0, 0, 0);
        currentPage.webView.scrollView.contentInset = UIEdgeInsetsMake(buttonHeight, 0, 0, 0);
        
        for(Track* t in currentPieceTracks)
        {
            UITaggedButton* trackButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(xOffset, yOffset , buttonWidth, buttonHeight)];
            trackButton.userInteractionEnabled = YES;
            trackButton.tagText = [t name];
            
            
            
            UILabel* buttonText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,buttonWidth,buttonHeight)];
            
            [buttonText setText:[t name]];
            if([[t name] isEqualToString:[trackData name]])
            {
                UIColor* highlight = SELECTED_TAB_TEXT_COLOR;
                buttonText.textColor = highlight;
                [buttonText setFont:SELECTED_TAB_FONT];
                [buttonText setBackgroundColor:SELECTED_TAB_BG_COLOR];
                [buttonText setTextAlignment:NSTextAlignmentCenter];
                [buttonText sizeToFit];
                
                [buttonText setFrame:CGRectMake(0, 0 , buttonText.frame.size.width+buttonHeight, buttonHeight)];
                [trackButton setFrame:CGRectMake(xOffset, yOffset , buttonText.frame.size.width, buttonHeight)];
                
                trackSelectPointer.frame = CGRectMake(xOffset + (buttonText.frame.size.width-pointerWidth)/2.0, yOffset+buttonHeight, pointerWidth, pointerHeight);
                trackSelectPointer.alpha = 0.7;
            }
            else{
                UIColor* highlight = TAB_TEXT_COLOR;
                buttonText.textColor = highlight;
                [buttonText setFont:TAB_FONT];
                [buttonText setBackgroundColor:TAB_BG_COLOR];
                [buttonText setTextAlignment:NSTextAlignmentCenter];
                [buttonText sizeToFit];
                
                [buttonText setFrame:CGRectMake(0, 0 , buttonText.frame.size.width+buttonHeight, buttonHeight)];
                [trackButton setFrame:CGRectMake(xOffset, yOffset , buttonText.frame.size.width, buttonHeight)];

            }
            xOffset = xOffset + buttonText.frame.size.width;
            [trackButton addTarget:self action:@selector(trackButtonsActivated:) forControlEvents:UIControlEventTouchUpInside];
            [trackButton addSubview:buttonText];
            [trackButtonScrollView addSubview:trackButton];
        }

        UIView* darkenedTrackTabBackground = [[UIView alloc] initWithFrame:CGRectMake(kWIDTH-75, 0, 75, buttonHeight)];
        [darkenedTrackTabBackground setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [self.view addSubview:darkenedTrackTabBackground];
        
        
        UIView* darkenedTrackSpacerHead = [[UIView alloc] initWithFrame:CGRectMake(-200, 0, 200, buttonHeight)];
        [darkenedTrackSpacerHead setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
        [trackButtonScrollView addSubview:darkenedTrackSpacerHead];
        
        if(xOffset<kWIDTH-75)
        {
            UIView* darkenedTrackSpacer = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, kWIDTH-xOffset-75, buttonHeight)];
            [darkenedTrackSpacer setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
            [trackButtonScrollView addSubview:darkenedTrackSpacer];
            trackButtonScrollView.contentSize = CGSizeMake(xOffset, trackButtonScrollView.frame.size.height);
        }
        else{
            UIView* darkenedTrackSpacer = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, 75 + 125, buttonHeight)];
            [darkenedTrackSpacer setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
            [trackButtonScrollView addSubview:darkenedTrackSpacer];
            trackButtonScrollView.contentSize = CGSizeMake(xOffset+75, trackButtonScrollView.frame.size.height);
        }
        tabsPresent = YES;
    }
    else{
        trackSelectPointer.hidden = YES;
        [currentPage.webView setFrame:  CGRectMake(0, 0,kWIDTH, kHEIGHT - kHEIGHT*.1 - kHEIGHT*.1*.5 - 32)];
        [nextPage.webView setFrame:     CGRectMake(0, 0,kWIDTH, kHEIGHT - kHEIGHT*.1 - kHEIGHT*.1*.5 - 32)];
        //                                              width   height    structure    dots          navbar
        nextPage.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        currentPage.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tabsPresent = NO;
    }
}
@end
