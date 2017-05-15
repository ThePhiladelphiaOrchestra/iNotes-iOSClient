// a
//  MainViewController.m
//  Test1
//
//  Created by Matthew Prockup on 11/16/09.
//  Copyright 2009 Drexel University. All rights reserved.
//


// Main page after connect:
// short description of each track
//

#import "MainViewController.h"
#import "Test1AppDelegate.h"
#import "constants.h"
#import "NetworkCheck.h"
#define USE_CUSTOM_DRAWING 1

@implementation MainViewController

@synthesize myTimer,currentMeasureNumber, trackButtonArray, arrayOfTracks, tableView, receivedData,tabBarVisible,tabBarLabel ;
@synthesize thePieces, currentMusicPiece, currentDataPage, currentProperty, currentTrack, trackTabBar, goLiveButton, goLiveButtonFromTable,refreshButton, currentTrackIndex,labelViewBarsArray,theAlbumNamesFull,liveLabelButtons, deletePieceButtons,pieceComposerLabels, composersAlbumList, piecesAlbumList,piecesToBeDeleted,theAlbumScrollViews;//,multicastClient;


NSString * SERVER_IP = ADDRESS_OF_SERVER;

NSString * MEASURE_DATA = @"___MEASURE_DATA___";
NSString * CONTENT_DATA = @"___CONTENT_DATA___";

NSString * REQUEST_CONTENT = @"___REQUEST_CONTENT___";
NSString * REQUEST_MEASURE = @"___REQUEST_MEASURE___";

NSString * READY_FOR_CONTENT_DATA = @"___CONTENT_DATA_READY___";
NSString * READY_FOR_MEASURE_DATA = @"___MEASURE_DATA_READY___";

NSString * END_CONTENT_STRING = @"___END_CONTENT___";
NSString * GOT_CONTENT_SIZE = @"___GOT_CONTENT_SIZE___";

NSString * GOT_ALL_CONTENT = @"___GOT_ALL_CONTENT___";

BOOL updating = FALSE;
NSData* tempContentData;
NSLock * lock;
Test1AppDelegate *appDelegate;

int currentIndex = 0;
const CGFloat kAnimationTime = 0.25;
int albumWidth = 175;
int toolbarWidth = 65;


- (id) initWithTitle:(NSString *) theTitle
{
    self = [super init];
    if (self != nil) {
        self.tabBarItem.image = [UIImage imageNamed:@"table_gray.png"];
        appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.title = theTitle;
        tabBarVisible = YES;
    }
    return self;
}

// UNUSED
- (void) hideNavBar {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationTime];
    self.navigationController.navigationBar.alpha =  (tabBarVisible ? 0.0 : 1.0);
    [UIView commitAnimations];
}

- (void) hidetabbar {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationTime];
    
    
    
    if (tabBarVisible) {
        self.navigationController.navigationBar.alpha = 1.0;
    } else {
        self.navigationController.navigationBar.alpha = 1.0;
    }
    [UIView commitAnimations];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationTime];
    [UIView setAnimationDelegate:self];        // sets delegate for this block
    
    
    for(UIView *view in trackTabBar.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (tabBarVisible) {
                view.alpha = 0.0;
            } else {
                view.alpha = 1.0;
            }
        } else {
            if (tabBarVisible) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, kHEIGHT)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, kHEIGHT)];
            }
        }
        
    }
    [UIView commitAnimations];
    
    tabBarVisible = !tabBarVisible;
    
}

- (void) fadeTabBar {
        
    CGRect tabBarFrame = [trackTabBar.tabBar frame];

    [UIView beginAnimations:nil context:nil]; // begins animation block
    [UIView setAnimationDuration:kAnimationTime];        // sets animation duration
    [UIView setAnimationDelegate:self];        // sets delegate for this block
    
    int yLocation = 0;
    
    if (tabBarVisible){
        yLocation = trackTabBar.view.frame.size.height;
        trackTabBar.tabBar.alpha = 0;
    }
    else{
        trackTabBar.tabBar.alpha = 0.0;
    }
    trackTabBar.tabBar.frame = CGRectMake(tabBarFrame.origin.x, yLocation, kWIDTH, 50);
    [UIView commitAnimations];   // commits the animation block.  This Block is done.
    
    tabBarVisible = !tabBarVisible;
}

- (void)initializeEverything {
    
    lock = [[NSLock alloc] init];
    currentMeasureNumber = 0;
    
    myTimer = [[NSTimer alloc] init];
    cm =0;
    
    goLiveButtonFromTable = [[UIBarButtonItem alloc]
                             initWithTitle:@"Live"
                             style:UIBarButtonItemStyleBordered
                             target:self
                             action:@selector(goToLivePositionFromTable)];
    [goLiveButtonFromTable setTintColor:[UIColor redColor]];
    
    UIImage *image = [UIImage imageNamed: @"refresh.png"];
    UIButton* butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [butt setBackgroundImage:image forState:UIControlStateNormal];
    [butt addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    refreshButton = [[UIBarButtonItem alloc] initWithCustomView:butt];
    refreshSpinning = false;

    [self.navigationItem setRightBarButtonItem:goLiveButtonFromTable];
    [self.navigationItem setLeftBarButtonItem:refreshButton];
   
    currentTrackIndex = 0;
    
}

-(void) refreshButtonPressed
{
    mode = CONTENT;
}


-(void) startRefreshSpin
{
//    if (!refreshSpinning) {
//        refreshSpinning = true;
//        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
//    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.refreshButton.customView.transform = CGAffineTransformRotate( self.refreshButton.customView.transform, -M_PI/2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (refreshSpinning) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                                 self.refreshButton.customView.frame = CGRectMake(0, 0, 20, 20) ;
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                                 self.refreshButton.customView.frame = CGRectMake(0, 0, 20, 20) ;
                                 //self.refreshButton.customView.transform = CGAffineTransformIdentity;
                             }
                         }
                     }];
}


// UNUSED
//Connect to site for data, no longer the actual
// Juliesays : TOFIX, no longer the actual but still gets called
-(void) startConnectThread:(NSNumber *)tries {
    [appDelegate.splashViewController performSelectorOnMainThread : @selector(setConnected:) withObject:[NSNumber numberWithBool:TRUE] waitUntilDone:NO];
}

-(void) reloadTableRow:(NSNumber * ) row {
    NSIndexPath * path = [NSIndexPath indexPathForRow:[row intValue] inSection:0];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:path,nil] withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadData];
}

// UNUSED
-(void) tempPush{
    [self performSelectorOnMainThread:@selector(otherTempPush) withObject:nil waitUntilDone:NO];
}

// UNUSED
-(void) otherTempPush{
    [self.navigationController pushViewController:trackTabBar animated:YES];
    
}

- (void) goToLiveTabbar {
    
    if(appDelegate.USE_SLIDE_FORMAT){
        
        NSMutableArray * tracks = [arrayOfTracks objectForKey:appDelegate.CURRENT_PIECE];
        [self configureTracks:tracks piece:appDelegate.CURRENT_DATA];
        trackTabBar.title = appDelegate.CURRENT_PIECE;
    }
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[pieceList indexOfObject:appDelegate.CURRENT_PIECE] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    if(!tabBarVisible)
        [self fadeTabBar];
}

#pragma mark -
#pragma mark Main receive thread

BOOL hitEndOfContent = FALSE;
BOOL gotContentSize = FALSE;
int totalContentSize = 0;
int currentContentSize = 0;
-(void)editTitle: (NSString*) titleJawn
{
    [self setTitle:titleJawn];
}


//Thread that constantly listens to the socket to receive new data when it becomes available
//THIS THREAD IS REALLY FUCKING IMPORTANT
-(void)getData:(id) dummy
{
    //get pointer to application delegate
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //setup multicast client
    multicastClient = [[MulticastClient alloc] init];
    int connectionLoop = 0;
    
    //run forever
    while(1)
    {
        
        bool connectedStream = false;
        
        sleep(1);
        
        //In the Download content from server state. Spin the loading/refresh button. Download all content available on server and load stored documents
        //This state is reached on startup and any time the user presses refresh.
        if(mode == CONTENT)
        {
            [self performSelectorOnMainThread:@selector(editTitle:) withObject:@"Loading..." waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(startRefreshSpin) withObject:nil waitUntilDone:NO];
            [self loadContentFromInternetAndFile];
            
            //set the state to start multicast connections
            mode = CONNECT_MULTI;
            
        }
        
        //State for managing multicast connections
        //This is reached on start up, every time the user presses refresh, and every time the user hits "view live"
        //Its called alot to make sure there is good service. Multicast is connectionless, its hard to know if you arn't receiving packets becasue none are there or there there is problem
        else if(mode == CONNECT_MULTI)
        {
            //are we connected? try to close it
            if([multicastClient isSocketOpen])
            {
                int socketCount = 0;
                [multicastClient closeSocket];
                
                //try to close it nicely 5 times
                while([multicastClient isSocketOpen] &&  socketCount<5 )
                {
                    sleep(1.0);
                    NSLog(@"Waiting on Socket close");
                    socketCount++;
                }
            }
            
            //reinti client. will force close connection if we havnt yet
            multicastClient = [[MulticastClient alloc] init];
            
            int cnt = 1;
            NSString* ssidTemp = SSID;
            
            //Connect multicast if we are not connected yet and we are on the appropriate wifi network
            while((!connectedStream) && cnt<=5 && [[NetworkCheck whatIsMySSID] isEqualToString:ssidTemp])
            {
                NSLog(@"Trying to connect... %d",cnt);
                cnt++;
                
                //init multicast connection
                connectedStream = [multicastClient startMulticastListenerOnPort:kPortNumber withAddress: [NSString stringWithUTF8String:kMulticastAddress]];
                if(!connectedStream)
                {
                    sleep(1.0);
                }
                
            }
            connectionLoop++;
            
            //If we connected and are on the right network start client listen loop
            if(connectedStream && [[NetworkCheck whatIsMySSID] isEqualToString:ssidTemp])
            {
                [multicastClient startListen];
                appDelegate.splashViewController.onlineMode = true;
                
                //Wait for all alerts to disappear
                while(appDelegate.splashViewController.alertsPresent)
                {
                    NSLog(@"Waiting for initial connection alerts to dissapear");
                    sleep(1.0);
                }
                if(connectionLoop == 1)
                {
                    //On first connection send a welcome message and a connection success
                    [self performSelectorOnMainThread:@selector(sendConnectionSuccessMessage) withObject:nil waitUntilDone:false];
                }
                else{
                    //All other times, send a simple "connected!" message.
                    [self performSelectorOnMainThread:@selector(sendSecondaryConnectionSuccessMessage) withObject:nil waitUntilDone:false];
                    
                }
                
            }
            //send a connection failure message
            else{
                //wait for initial alerts to dissapear
                while(appDelegate.splashViewController.alertsPresent)
                {
                    NSLog(@"Waiting for initial connection alerts to dissapear");
                    sleep(2);
                }
                
                if(connectionLoop > 1)
                {
                    appDelegate.splashViewController.onlineMode = false;
                    [self performSelectorOnMainThread:@selector(sendConnectionErrorMessage) withObject:nil waitUntilDone:false];
                }
            }
            
            //set the state to receive measure updates
            mode=MEASURE;
            
            //stop the refresh/loading button from spinning
            refreshSpinning = false;
            [self performSelectorOnMainThread:@selector(editTitle:) withObject:@"Home" waitUntilDone:NO];
        }
        //This state involves accessing the client for the current packets that are received and sets the current measure and peice accordingly
        else if(mode == MEASURE){
            NSData* buffer = [multicastClient getCurrentData];
            NSString *s = [[NSString alloc] initWithData:buffer encoding:[NSString defaultCStringEncoding]];
            
            //seperate piece name and measure number
            NSArray *parts = [s componentsSeparatedByString: @";"];
            
            if([parts count] > 1){
                
                NSLog(@"%@", s);
                
                
                //If the piece is not the current one, update it in the App Delegate (where this info is stored for global access)
                NSString * piece = [[NSString alloc] initWithString:[parts objectAtIndex:0]];
                if(piece && ![piece isEqualToString:appDelegate.CURRENT_PIECE]){
                    
                    if([pieceList containsObject:piece]){
                        
                        //set current piece
                        appDelegate.CURRENT_PIECE = piece;
                        for(MusicPiece * p in thePieces){
                            if([p.name isEqualToString:appDelegate.CURRENT_PIECE]){
                                appDelegate.CURRENT_DATA = p;
                                break;
                            }
                        }
                        
                        // Select
                        [self performSelectorOnMainThread:@selector(reloadTableRow:) withObject:[NSNumber numberWithInt:[pieceList indexOfObject:piece]] waitUntilDone:NO];
                        
                        //Move to new piece and measure if user is viewing live
                        if(appDelegate.LIVE){
                            [self performSelectorOnMainThread:@selector(goToLiveTabbar) withObject:nil waitUntilDone:YES];
                            
                        }
                    }
                    
                }
                
                //update current measure number
                currentMeasureNumber = [[parts objectAtIndex:1] intValue];
                //NSLog(@"update current measure");
                if(appDelegate.USE_SLIDE_FORMAT){
                    // NSLog(@"USe Slide");
                    if(appDelegate.CURRENT_MEASURE != currentMeasureNumber){
                        appDelegate.CURRENT_MEASURE = currentMeasureNumber;
                        // NSLog(@"Set current Measure Number");
                        for(NSString * s in pieceList){
                            NSMutableArray * t = [arrayOfTracks objectForKey:s];
                            for(UIViewController * ui in t){
                                NSLog(@"UI View Controller");
                                if(ui){
                                    @try{
                                        //NSLog(@"==============================================");
                                        //NSLog(@"==============================================");
                                        //NSLog(@"Tried");
                                        [((NavigationViewController *)ui) performSelectorOnMainThread:@selector(checkUpdatePage:) withObject:nil waitUntilDone:YES];
                                    }
                                    @catch (NSException* theException) {
                                        //NSLog(@"Caught");
                                    }
                                    // NSLog(@"Success");
                                    // NSLog(@"==============================================");
                                    // NSLog(@"==============================================");
                                }
                            }
                        }
                    }
                }
                appDelegate.CURRENT_MEASURE = currentMeasureNumber;
                
            }
            //set the album/document in the Home view that is live to show its live
            if([labelViewBarsArray count]>1)
            {
                for(int i = 0; i< [labelViewBarsArray count];i++)
                {
                    if([appDelegate.CURRENT_PIECE isEqualToString:[theAlbumNamesFull objectAtIndex:i]])
                    {
                        [[labelViewBarsArray objectAtIndex:i] setLive:YES];
                    }
                    else
                    {
                        [[labelViewBarsArray objectAtIndex:i] setLive:NO];
                    }
                }
            }
        }
        else{
        }
        
    }

    
}

- (void)sendConnectionErrorMessage
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Live Stream Error"
                          message:@"You are in offline mode. The live stream is only available to those at an enhanced concert. If you are at an enhanced concert, make sure you are connected to the correct wireless network."
                          delegate:nil cancelButtonTitle:
                          @"OK"
                          otherButtonTitles:nil];
    
    [alert show];

}

//First connection message
- (void)sendConnectionSuccessMessage
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Live Stream Connected"
                          message:@"Welcome to iNotes! Select \"Live\" to see the live content stream."
                          delegate:nil cancelButtonTitle:
                          @"OK"
                          otherButtonTitles:nil];
    [alert show];
}

//Subsequent connection message (auto dismissed)
- (void)sendSecondaryConnectionSuccessMessage
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Live Stream Connected!"
                          message:nil
                          delegate:nil cancelButtonTitle:nil
                          otherButtonTitles:nil];
    [alert show];
    
    [self performSelector:@selector(dismissSecondaryConnectionSuccessMessage:) withObject:alert afterDelay:2];
}

/////////////////////////////////////////////
// Add an alert view when deleting a piece //
/////////////////////////////////////////////

//dismiss secondary connection message
- (void)dismissSecondaryConnectionSuccessMessage:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

//This loads all content from the server, as well as the stored documents
//It also saves document files as it loads content
//THIS IS REALLY FUCKING IMPORTANT
-(void)loadContentFromInternetAndFile
{
    bool hasProperConnection;
    //QUICK OFFLINE FIX MP    
    //if on no network or cell network, dont load content
    if(([NetworkCheck whatIsMyConnectionType] == 0)||([NetworkCheck whatIsMyConnectionType] == 2))
    {
        hasProperConnection = false;
    }
    else //only load if on wifi
    {
        hasProperConnection = true;
    }
    
    NSArray* piecesArray = [[NSArray alloc] init];
    
    if(hasProperConnection)
    {
        
        //check for what pieces are being played and insert them into string
        NSString* urlPiecesString = [NSString stringWithFormat:@"http://%@/getPieces.php", SERVER_IP];
        NSURL* urlPieces = [NSURL URLWithString:urlPiecesString];
        NSURLRequest *piecesRequest = [[NSURLRequest alloc] initWithURL:urlPieces cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:3.0];
        
        NSURLResponse *piecesResponse;
        NSError *error = nil;
        NSData *tempData = [NSURLConnection sendSynchronousRequest:piecesRequest returningResponse:&piecesResponse error:&error];
        NSString *piecesStringContent = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",piecesStringContent);
        
        //array of pieces played
        piecesArray = [piecesStringContent componentsSeparatedByString: @";"];
        int numberOfNewPieces = [piecesArray count];
        
        
        //Load the new pieces data.
        NSString * urlImageFolder = IMAGE_SERVER;
        for (int i = 0; i<numberOfNewPieces; i++) {
            NSString * urlString = [NSString stringWithFormat:@"http://%@/getData.php?", SERVER_IP];
            urlString = [NSString stringWithFormat:@"%@database1=%@", urlString,[piecesArray objectAtIndex:i]];
            
            NSString *encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL * url = [NSURL URLWithString:encodedString];
            
            NSError *error = nil;
            contentString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];  //content for a single piece.
            if(error)
            {
                //Do some stuff if there is an error.
                //To see the human readable description you can:
                NSLog(@"The error was: %@", [error localizedDescription]);
                //To see the error code you do:
                NSLog(@"The error code: %d", error.code);
            }
            
            //Search for images, download images
            if(contentString != nil)
            {
                //Strip out xml tags surrounding each piece.
                contentString = [contentString stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\"?><concert>" withString:@""];
                contentString = [contentString stringByReplacingOccurrencesOfString:@"</concert>" withString:@""];
                
                NSMutableArray* imageList = [[NSMutableArray alloc] init];
                NSMutableArray* imageNames = [[NSMutableArray alloc] init];
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\$[^\\.]*\\.[:alnum:]*," options:0 error:NULL];
                NSArray *matches = [regex matchesInString:contentString options:0 range:NSMakeRange(0, [contentString length])];
                for (NSTextCheckingResult *match in matches) {
                    NSRange matchRange = [match range];
                    NSString* tempName = [contentString substringWithRange:matchRange];
                    tempName = [tempName stringByReplacingOccurrencesOfString:@"$" withString:@""];
                    tempName = [tempName stringByReplacingOccurrencesOfString:@"," withString:@""];
                    
                    NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"%@%@",urlImageFolder,tempName];
                    
                    NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
                    NSLog(@"%@",tempImageStrUrl);
                    NSURL *url = [NSURL URLWithString:tempImageStrUrl];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    //UIImage *image = [[UIImage alloc] initWithData:data];
                    [imageList addObject:data];//add for musicFile. Easier to save and load.
                    [imageNames addObject:tempName];
                }
                
                //Add images and xml to PieceFile object
                MusicPieceFile* musicFile = [[MusicPieceFile alloc] initWithName:[piecesArray objectAtIndex:i] withData:contentString withImages:imageList thatHaveNames:imageNames];
                
                //Strip All non AlphaNUmeric fromFileName
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                NSString* fileName = [[[piecesArray objectAtIndex:i] componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
            
                fileName = [NSString stringWithFormat:@"POA%@",fileName];
                
                //Save that to documents folder.
                if(![fileName isEqualToString:@"POA"])
                {
                    [musicFile savePiece:fileName];
                    NSLog(@"Saved %@",fileName);
                }
                else
                {
                    NSLog(@"Error - Did not save: %@",fileName);
                }
                
            }
            else{
                 NSLog(@"Error Downloading: %@",[piecesArray objectAtIndex:i]);
            }
        }
    }
    
    NSArray* savedFileNames = [SavedContentManager listDocumentsDir]; //gets list of saved docs
    
    if(![savedFileNames containsObject:@"POAStraussDonJuanDonJuan"])
    {
        
        NSString *donJuanDataPath =   @"data.xml";
        NSString *donJuanImagePath1 = @"DJ1.png";
        NSString *donJuanImagePath2 = @"DJ2.png";
        NSString *donJuanImagePath3 = @"DJ3.png";
        NSString *donJuanImagePath4 = @"DJ4.png";
        NSString *donJuanImagePath5 = @"DJ5.png";
        NSString *donJuanImagePath6 = @"DJ6.png";
        NSString *donJuanImagePath7 = @"DJ7.png";
        NSString *donJuanImageNames = @"imageNames.txt";
        NSString *donJuanName =       @"name.txt";
        
        NSArray* pathArray = [[NSArray alloc] initWithObjects:donJuanDataPath,donJuanImagePath1,donJuanImagePath2,donJuanImagePath3,donJuanImagePath4,donJuanImagePath5,donJuanImagePath6,donJuanImagePath7,donJuanImageNames, donJuanName,nil];
        
        [SavedContentManager createFolderInDocuments:@"POAStraussDonJuanDonJuan"];
        
        for (NSString* pathJawn in pathArray)
        {
            NSString* documentsPath = [NSString stringWithFormat:@"%@/POAStraussDonJuanDonJuan/%@",[SavedContentManager getDocumentsDir],pathJawn];
            NSString* preloadPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],pathJawn];
            
            [SavedContentManager copyFileAtPath:preloadPath toPath:documentsPath];
            
        }
        savedFileNames = [SavedContentManager listDocumentsDir];

    }
    
    
    // Get the loaded pieces
    NSMutableArray* tempPiecesArray = [[NSMutableArray alloc] init];
    
    if(hasProperConnection)
    {
        for(NSString* str in piecesArray)
        {
            
            if([str length]>0)
            {
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                NSString* fileTemp = [[str componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
                fileTemp = [NSString stringWithFormat:@"POA%@",fileTemp];
                [tempPiecesArray addObject:fileTemp];
            }
        }
        
    }
    
    
    NSMutableArray *allPiecesUnion =  [[NSMutableArray alloc] initWithArray:tempPiecesArray];
    
    //Get Union of Saved and loaded pieces.
    //provide an edited piecesArray
    
    for (NSString* str in savedFileNames)
    {
        
        if([str hasPrefix:@"POA"] && ![allPiecesUnion containsObject:str])// make sure you don't add it if it's already there.
        {
            [allPiecesUnion addObject:str]; // if its not there, add it
        }
        
    }
    
    NSString* concatData = @"<?xml version=\"1.0\"?><concert>";
    for(NSString* tempPiece in allPiecesUnion)
    {
        MusicPieceFile* tempPieceFile = [[MusicPieceFile alloc] init];
        
        if(![tempPiece isEqualToString:@"POA"])
        {
            if([tempPieceFile  loadPiece:tempPiece])
            {
                if([tempPieceFile getPieceData]!= nil)
                {
                    concatData = [concatData stringByAppendingString:[tempPieceFile getPieceData]];
                    NSLog(@"Loaded %@",tempPiece);
                }
                else{
                    NSLog(@"Error Loading - piece has no data: %@",tempPiece);
                }
            }
            else{
                NSLog(@"Error Loading - piece not complete. %@",tempPiece);
            }
            
        }
        else{
            NSLog(@"Error Loading - brokenFile: %@",tempPiece);
        }
        
        
        
    }
    concatData = [concatData stringByAppendingString:@"</concert>"];
    
    
    contentString = [[NSString alloc] initWithString:concatData];
    NSLog(@"%@",contentString);
    mode = MEASURE;
    BOOL ok = [self parseData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
    if(!ok){
        [currentMeasure performSelectorOnMainThread : @selector(setText:) withObject:@"Parse Error" waitUntilDone:YES];
        
    }
    else{
        [self performSelectorOnMainThread : @selector(createTrackButtons) withObject:nil waitUntilDone:YES];
    }
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.splashViewController performSelectorOnMainThread : @selector(notifyFinished:) withObject:[NSNumber numberWithBool:TRUE] waitUntilDone:NO];
    appDelegate.CONNECTED_TO_SERVER = TRUE;
    
    [self performSelectorOnMainThread:@selector(createNewNavView) withObject:nil waitUntilDone:YES];
    
}

// UNUSED
-(int) getCurrentMeasure {
    
    return currentMeasureNumber;
}

#pragma mark -
#pragma mark XML parsing methods

- (BOOL)parseData:(NSData *)data1 {
    
    BOOL ok = TRUE;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data1];
    
    self.thePieces = [[NSMutableArray alloc] init]; // Create our scheduler list
    
    [parser setDelegate:self]; // The parser calls methods in this class
    [parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
    [parser setShouldReportNamespacePrefixes:NO]; //
    [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
    
    [parser parse]; // Parse that data..
    
    //DataPage * thisPage = [((MusicPiece *)[thePieces objectAtIndex:0]) pageWithMeasure:3];
    if ([parser parserError]) {
        ok = FALSE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was an error parsing the XML file."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert performSelectorOnMainThread:@selector( show ) withObject:nil waitUntilDone:NO];
    }
    else{
        [tableView reloadData];
        ok = TRUE;
    }
    
    
    return ok;
}


-(void) createTrackButtons {
    int numPieces = [thePieces count];
    pieceList = [[NSMutableArray alloc] init];
    if (appDelegate.USE_SLIDE_FORMAT){
        pickerViewArray = [[NSMutableArray alloc] init];
        arrayOfTracks = [[NSMutableDictionary alloc] init];
        for(int j=0; j<numPieces; j++){
            
            MusicPiece * thisPiece = [self.thePieces objectAtIndex:j];            
            
            NSMutableArray * trackArray = [[NSMutableArray alloc] init];
            int numTracks = [thisPiece.tracks count];
            
            [pieceList addObject:[NSString stringWithString:thisPiece.name]];
            
            for(int i=0; i<numTracks; i++){
                Track * thisTrack = (Track *)[thisPiece.tracks objectAtIndex:i];
                thisTrack.pieceName = thisPiece.name;
                if([thisTrack.name isEqualToString:@"The Music"]){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if([thisTrack.name isEqualToString:@"English"]){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if([thisTrack.name isEqualToString:@"German"]){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if([thisTrack.name isEqualToString:@"Both"]){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if([thisTrack.name isEqualToString:@"History"]){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if([thisTrack.name isEqualToString:@"Latin"]){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if(!([thisTrack.name isEqualToString:@"NumSeconds"] || [thisTrack.name isEqualToString:@"MeasureNumber"] || [thisTrack.name isEqualToString:@"Structure"] || [thisTrack.name isEqualToString:@"Waveform"])){
                    NavigationViewController * navigationViewController = [[NavigationViewController alloc] initWithTrack:thisTrack];
                    navigationViewController.tabBarItem.image = [UIImage imageNamed:@"musicnote.png"];
                    [trackArray addObject:navigationViewController];
                }
                else if([thisTrack.name isEqualToString:@"Structure"])
                {
                    for(int nTemp = 0; nTemp<[trackArray count];nTemp++)
                    {
                        [[trackArray objectAtIndex:nTemp] addMapColors:thisTrack];
                    }
                    
                    NSLog(@"jawning structure Track");
                }
                //ADD WAVEFORM STUFF HERE
                else if([thisTrack.name isEqualToString:@"Waveform"])
                {
                    for(int nTemp = 0; nTemp<[trackArray count];nTemp++)
                    {
                        [[trackArray objectAtIndex:nTemp] addWaveform:thisTrack];
                    }
                    
                    NSLog(@"jawning structure Track");
                }
                
                
            }
            [pickerViewArray addObject:thisPiece.name];
            [arrayOfTracks setObject:trackArray forKey:thisPiece.name];
        }
    }
    else{
        mapArray = [[NSMutableDictionary alloc] init];
        
        for(int j=0; j<1; j++){
            
            MusicPiece * thisPiece = [self.thePieces objectAtIndex:j];
            [pieceList addObject:thisPiece.name];
        }
        
    }
    
    
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (qName) {
        elementName = qName;
    }
    
    if (self.currentDataPage) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"measure"] || [elementName isEqualToString:@"text"] || [elementName isEqualToString:@"time"]) {
            self.currentProperty = [NSMutableString string];
        }
        
    }
    else if (self.currentTrack) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"name"]) {
            self.currentProperty = [NSMutableString string];
        }
        else if ([elementName isEqualToString:@"page"]) {
            self.currentDataPage = [[DataPage alloc] init]; // Create the element
            self.currentDataPage.parentTrack = self.currentTrack.name;
            
            if([attributeDict objectForKey:@"time"]){
                self.currentDataPage.time = [[attributeDict objectForKey:@"time"] doubleValue];
            }
            
            if([attributeDict objectForKey:@"measure"] ){
                self.currentDataPage.measure = [[attributeDict objectForKey:@"measure"] intValue];
            }
            
        }
        
    }
    else if (self.currentMusicPiece) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"name"] || [elementName isEqualToString:@"measures"] || [elementName isEqualToString:@"image"] || [elementName isEqualToString:@"audio"]) {
            self.currentProperty = [NSMutableString string];
        }
        else if ([elementName isEqualToString:@"track"]) {
            self.currentTrack = [[Track alloc] init]; // Create the element
            
            if([attributeDict objectForKey:@"name"]){
                self.currentTrack.name = [attributeDict objectForKey:@"name"];
            }
        }
        
        
        
    } else { // We are outside of everything, so we need a
        // Check for deeper nested node
        if ([elementName isEqualToString:@"piece"]) {
            self.currentMusicPiece = [[MusicPiece alloc] init];
            
            if([attributeDict objectForKey:@"name"]){
                self.currentMusicPiece.name = [attributeDict objectForKey:@"name"];
            }
            
            if([attributeDict objectForKey:@"measures"] ){
                self.currentMusicPiece.numMeasures = [[attributeDict objectForKey:@"measures"] intValue];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.currentProperty) {
        [currentProperty appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (qName) {
        elementName = qName;
    }
    
    if (self.currentDataPage) { // Are we in a
        // Check for standard nodes
        self.currentDataPage.pieceName = self.currentMusicPiece.name;
        if ([elementName isEqualToString:@"measure"]) {
            self.currentDataPage.measure = [self.currentProperty intValue];
        } else if ([elementName isEqualToString:@"text"]) {
            
            NSString* tempProperty = [[NSString alloc] initWithString:currentProperty];
            self.currentProperty = (NSMutableString*)[self.currentDataPage extractAndRemoveImageData:tempProperty];
            self.currentDataPage.text = self.currentProperty;
        } else if ([elementName isEqualToString:@"time"]) {
            self.currentDataPage.time = [self.currentProperty doubleValue];
        } else if ([elementName isEqualToString:@"page"]) {
            if(self.currentDataPage.text && ![self.currentDataPage.text isEqualToString:@""] && ![self.currentDataPage.text isEqualToString:@"NaN"]);
            [currentTrack addDataPage:self.currentDataPage]; // Add to parent
            
            self.currentDataPage = nil; // Set nil
        }
    }
    else if (self.currentTrack) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"name"]) {
            self.currentTrack.name = self.currentProperty;
        } else if ([elementName isEqualToString:@"track"]) {
            self.currentTrack.numMeasures = [self.currentMusicPiece numMeasures];
            [currentMusicPiece addTrack:self.currentTrack]; // Add to parent
            self.currentTrack = nil; // Set nil
        }
    }
    else if (self.currentMusicPiece) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"name"]) {
            self.currentMusicPiece.name = self.currentProperty;
        } else if ([elementName isEqualToString:@"measures"]) {
            self.currentMusicPiece.numMeasures = [self.currentProperty intValue];
        } else if ([elementName isEqualToString:@"image"]) {
            self.currentMusicPiece.image = [UIImage imageNamed:self.currentProperty];
        } else if ([elementName isEqualToString:@"audio"]) {
            self.currentMusicPiece.audio = self.currentProperty;
        }
        else if ([elementName isEqualToString:@"piece"]) {
            [self.thePieces addObject:currentMusicPiece];
            self.currentMusicPiece = nil; // Set nil
        }
    }
    
    // We reset the currentProperty, for the next textnodes..
    self.currentProperty = nil;
}

- (void)parser :(NSXMLParser *)parser parseErrorOccurred :(NSError *)parseError {
    NSString *errorString = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code], [[parser parserError] localizedDescription], [parser lineNumber],	[parser columnNumber]];
    
    NSLog(@"error parsing XML: %@", errorString);
    
    
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString * piece = [pickerViewArray objectAtIndex:row];
    if(piece){
        NSMutableArray * trackStuff = [arrayOfTracks objectForKey:piece];
        
        Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.TOTAL_MEASURES = [[thePieces objectAtIndex:row] numMeasures];
        appDelegate.CURRENT_TRACK = [((NavigationViewController *)[trackStuff objectAtIndex:0]).trackData name];
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    returnStr = [pickerViewArray objectAtIndex:row];
    
    return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth = 0.0;
    componentWidth = 340.0;	// first column size is wider to hold names
    
    return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerViewArray count];
}

// UNUSED
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(void)onTime:(NSTimer*)timer //Timer function that gets called on iterations of the timer delay
{
    
    //updates the current measure
    if(cm != currentMeasureNumber)
    {
        cm = currentMeasureNumber;
    }
}


-(void)updateCurrent//force view update for current measure
{
    NSString* test = [NSString stringWithFormat:@"%d", currentMeasureNumber];
    [textView setText:test];
}

-(IBAction) current:(id) sender//force update by button push
{
    [self updateCurrent];
}

- (void) beginProgram {
    
    printf("Begin Program\n");
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!appDelegate.CONNECTED_TO_SERVER){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"We're having trouble with the data-server. When it's availble, the red light in the upper-right will turn green. Then, click start."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    appDelegate.APPLICATION_STARTED = TRUE;
    
    NSString * piece = appDelegate.CURRENT_PIECE;
    NSMutableArray * trackStuff = [arrayOfTracks objectForKey:piece];
    
    appDelegate.TOTAL_MEASURES = [((NavigationViewController *)[trackStuff objectAtIndex:0]).trackData numMeasures];
    [[appDelegate.splashViewController pieceBarItem] setTitle:appDelegate.CURRENT_PIECE];
    [appDelegate.splashViewController pieceBarItem].enabled = TRUE;
    [appDelegate.splashViewController updateMeasure];
    
    if([appDelegate.splashViewController toolbarVisible])
    [self.navigationController pushViewController:trackTabBar animated:YES];
    [self fadeTabBar];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

#pragma mark -
#pragma mark Alert Handling

- (void)alertView:(UIAlertView*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    // Let's get the tag of the alert to know which message was showing.
    int tag = actionSheet.tag;
    
    ///// CREATE THE ALERTS
    
    // WHAT IS WHAT : each alert has its special tag
    // tag = 100 is alertWhenDeleteHit
    // tag = 200 is doneEditingMessage
    // tag = 300 is successDeleteMessage
    // tag = 400 is errorDeleteMessage
    // tag = 500 is alertWhenCannotDelete


    
    ///// REACTION TO USER's ACTION
    
    if (tag==100 && buttonIndex==0) {
        // The user hit delete and then choses to cancel
        inDeleteMode = false;
        [self hideDeleteMode];
        
    }else if (tag==100 && buttonIndex==1){
        // "Are you sure you want to delete this", and the user says yes
        inDeleteMode = false;
        [self deletePieces];
    }
    else if (tag==500){
        inDeleteMode = false;
        [self hideDeleteMode];
    }


}



#pragma mark -
#pragma mark Initialize GUI
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        appFrame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
    }
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;
    
    backGroundImageView = [[UIImageView alloc] initWithImage:MAIN_BACKGROUND];
    backGroundImageView.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    backGroundImageView.frame = CGRectMake(0,0,kWIDTH,kHEIGHT);
    
    [self.view addSubview:backGroundImageView];
    
    trackButtonArray = [[NSMutableArray alloc] init];
    
    [NSThread detachNewThreadSelector:@selector(getData:) toTarget:self withObject:nil];//Start socket polling thread
    
    mode = CONTENT;
    
    trackTabBar = [[UITabBarController alloc] init];
    trackTabBar.view.frame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
    trackTabBar.view.clipsToBounds = YES;
    trackTabBar.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    trackTabBar.delegate =  self;
    CGFloat bottomInset = 30;
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              appFrame.size.height,
                                                              appFrame.size.width - 30 - bottomInset)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 100;
    tableView.delegate =  self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:tableView];
    
    
    self.view.backgroundColor = [UIColor clearColor];
    [self initializeEverything];
    
    
    programNotes = [[ProgramNotesViewController alloc] init];
    programNotes.title = @"Program Notes";
    
    
    tabBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, kWIDTH, 20)];
    
    tabBarLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [tabBarLabel setTextColor:[UIColor whiteColor]];
    [tabBarLabel setTextAlignment:NSTextAlignmentCenter];
    [tabBarLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [trackTabBar.view addSubview:tabBarLabel];
    
    
    
}


// UNUSED
- (void) pushProgramNotes {
    
    
    [self.navigationController pushViewController:programNotes animated:YES];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"ProgramNotes" ofType:@"pdf"];
    NSString* escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)path,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
    NSURL* tempUrl = [[NSURL alloc] initWithString:escapedString];
    [programNotes setPdfUrl:tempUrl];
}

#pragma mark -
#pragma mark TableViewController methods

// UNUSED
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [thePieces count];
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MusicPiece * thisPiece = (MusicPiece *) ((UITaggedTableViewCell*)[atableView cellForRowAtIndexPath:indexPath]).tagPiece;
    
    if(appDelegate.USE_SLIDE_FORMAT){
        if(appDelegate.mode == DEMO_MODE){
            appDelegate.LIVE = YES;
            NSArray * vc = trackTabBar.viewControllers;
            for(UIViewController * uivc in vc){
                [((NavigationViewController *)uivc) stopTimer];
            }
        }
        
        NSMutableArray * trackStuff = [arrayOfTracks objectForKey:thisPiece.name];
        [self configureTracks:trackStuff piece:thisPiece];
        
        trackTabBar.selectedIndex = 0;
        
        [self.navigationController pushViewController:trackTabBar animated:YES];
        trackTabBar.title = thisPiece.name;
        
        if(tabBarVisible)
        {
            [self hidetabbar];
        }
        if(![appDelegate.CURRENT_PIECE isEqualToString:thisPiece.name] && (appDelegate.mode == DEMO_MODE)){
            if(thisPiece.audio)
                [appDelegate setSong:thisPiece.audio];
            
            appDelegate.CURRENT_PIECE = thisPiece.name;
            
            NSArray * vc = trackTabBar.viewControllers;
            for(UIViewController * uivc in vc){
                [((NavigationViewController *)uivc) startTimer];
            }
            
        }
    }
    else{
        
        if(appDelegate.mode == DEMO_MODE){
            appDelegate.LIVE = YES;
            
            
        }
        if(![appDelegate.CURRENT_PIECE isEqualToString:thisPiece.name] && (appDelegate.mode == DEMO_MODE)){
            if(thisPiece.audio){
                [appDelegate setSong:thisPiece.audio];
                
            }
            
            appDelegate.CURRENT_PIECE = thisPiece.name;
            
            
        }
        
    }
    
    
    
}

-(void) push:(UIViewController * ) v {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController pushViewController:v animated:YES];
}


// Returns the cell for a given indexPath.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicPiece * piece = (MusicPiece *)[thePieces objectAtIndex:[indexPath row]];
    UIImageView * imageView;
    
#if USE_CUSTOM_DRAWING
    const NSInteger TOP_LABEL_TAG = 1001;
    const NSInteger BOTTOM_LABEL_TAG = 1002;
    const NSInteger IMAGE_LABEL_TAG = 1003;
    
    const CGFloat IMAGE_INSET_TOP = 15;
    const CGFloat IMAGE_INSET_LEFT = 20;
    UILabel *topLabel;
    UILabel *bottomLabel;
#endif
    
    static NSString *CellIdentifier = @"Cell";
    UITaggedTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        
        // Create the cell.
        cell = [[UITaggedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        
#if USE_CUSTOM_DRAWING
        UIImage *indicatorImage = [UIImage imageNamed:@"indicator.png"];
        const CGFloat LABEL_HEIGHT = 60;
        imageView = [[UIImageView alloc] init];
        imageView.tag = IMAGE_LABEL_TAG;
        imageView.frame = CGRectMake(IMAGE_INSET_LEFT, IMAGE_INSET_TOP, aTableView.rowHeight - 2*IMAGE_INSET_TOP, aTableView.rowHeight - 2*IMAGE_INSET_TOP);
        [cell.contentView addSubview:imageView];
        
        
        
        // Create the label for the top row of text
        topLabel =
        [[UILabel alloc]
          initWithFrame:
          CGRectMake(
                     imageView.frame.size.width + IMAGE_INSET_LEFT + 2.0 * cell.indentationWidth - 5,
                     aTableView.rowHeight*0.1,
                     aTableView.bounds.size.width -
                     imageView.frame.size.width - 4.0 * cell.indentationWidth
                     - indicatorImage.size.width,
                     LABEL_HEIGHT)];
        [cell.contentView addSubview:topLabel];
        
        // Configure the properties for the text that are the same on every row
        topLabel.tag = TOP_LABEL_TAG;
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        topLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:0.0];
        topLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]+3];
        topLabel.adjustsFontSizeToFitWidth = NO;
        topLabel.lineBreakMode = NSLineBreakByWordWrapping;
        topLabel.numberOfLines = 2;
        
        // Create the label for the top row of text
        bottomLabel =
        [[UILabel alloc]
          initWithFrame:
          CGRectMake(aTableView.bounds.size.width - indicatorImage.size.width - 60,
                     0.5 * (aTableView.rowHeight - 2*LABEL_HEIGHT) + LABEL_HEIGHT,
                     aTableView.bounds.size.width - imageView.frame.size.width - 4.0 * cell.indentationWidth - indicatorImage.size.width,
                     LABEL_HEIGHT)];
        [cell.contentView addSubview:bottomLabel];
        
        // Configure the properties for the text that are the same on every row
        bottomLabel.tag = BOTTOM_LABEL_TAG;
        bottomLabel.backgroundColor = [UIColor clearColor];
        bottomLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.2 alpha:0.0];
        bottomLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:0.0];
        bottomLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
        
        // Create a background image view.
        cell.backgroundView =
        [[UIImageView alloc] init];
        cell.selectedBackgroundView =
        [[UIImageView alloc] init];
#endif
    }
    
#if USE_CUSTOM_DRAWING
    else
    {
        topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
        bottomLabel = (UILabel *)[cell viewWithTag:BOTTOM_LABEL_TAG];
    }
    
    
    topLabel.text = piece.name;
    if([piece.name isEqualToString: appDelegate.CURRENT_PIECE ]){
        bottomLabel.text = @"LIVE";
    }
    else {
        bottomLabel.text = @"";
    }
    
    CGSize newSize = CGSizeMake( aTableView.rowHeight - 2*IMAGE_INSET_TOP, aTableView.rowHeight - 2*IMAGE_INSET_TOP);
    UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
    //image is the original UIImage
    UIGraphicsEndImageContext();
    cell.tagPiece = piece;
    
#else
    cell.text = [NSString stringWithFormat:@"Cell at row %ld.", [indexPath row]];
#endif
    
    return cell;
}

#pragma mark -
#pragma mark TabBar stuff
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSArray * vcs = tabBarController.viewControllers;
    int nextIndex = [vcs indexOfObject:viewController];
    if(tabBarVisible)
        [self fadeTabBar];
    
    if (nextIndex != ([vcs count]-1)){
        
    }
    if(currentIndex != ([vcs count]-1)){

    }
    currentIndex = nextIndex;
}

- (void) configureTracks:(NSMutableArray *) array piece:(MusicPiece *) piece{
    if(currentViewControllers){
        [currentViewControllers removeAllObjects];
    }
    else{
        currentViewControllers = [[NSMutableArray alloc] init];
    }
    
    for(int	i =0; i<[array count]; i++){
        [currentViewControllers addObject:[array objectAtIndex:i]];
    }
    
    [trackTabBar setViewControllers:currentViewControllers animated:YES];
    trackTabBar.selectedIndex = 0;
}


// UNUSED
- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    startTouchPosition = [touch locationInView:[self view]];
    NSLog(@"MainView Touches Begin");
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // reset the touch posistion
    startTouchPosition.x = 0.0;
    startTouchPosition.y = 0.0;
    NSLog(@"MainView Touches End");
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
    kWIDTH  = [DeviceProperties getDeviceResolutionLandscape].width;
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



-(void) flip {
    
}




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
}

- (void) goToLivePosition{
    NSLog(@"Going Live");
    [self goToLiveTabbar];
}

#pragma mark -
#pragma mark New Front Navigation

-(void)createNewNavView
{
    
    [self setTitle:@"Home"];
    
    liveLabelButtons     = [[NSMutableArray alloc] init]; // Contains all the Live labels in green
    deletePieceButtons   = [[NSMutableArray alloc] init]; // Contains all trash buttons for each piece
    pieceComposerLabels  = [[NSMutableArray alloc] init]; // Contains all labels for the top red banner of a piece
    composersAlbumList   = [[NSMutableArray alloc] init];
    piecesAlbumList      = [[NSMutableArray alloc] init];
    piecesToBeDeleted    = [[NSMutableArray alloc] init];
    inDeleteMode = false;
    
    
    UIView* addOnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH,kHEIGHT)];
    [addOnView setBackgroundColor:[UIColor clearColor]];
    [addOnView setAlpha:1.0];
    
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString* loadFileName;
    if([DeviceProperties getDeviceResolutionLandscape].width == 480)
    {
        loadFileName = SELECT_PIECES_BG_32;
    }
    else{
        loadFileName = SELECT_PIECES_BG_169;
    }
    
    NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"http://%@/images/AppAssets/%@",SERVER_IP,loadFileName];
    
    
    NSLog(@"%@",tempImageStrUrltemp);
    NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
    NSURL *url = [NSURL URLWithString:tempImageStrUrl];

    //QUICK OFFLINE FIX MP
    NSData* data = nil;
    
    //if on no network or cell network, dont load content
    if(([NetworkCheck whatIsMyConnectionType] == 0)||([NetworkCheck whatIsMyConnectionType] == 2))
    {
        data = nil;
    }
    else //only load if on wifi
    {
        data = [NSData dataWithContentsOfURL:url];
    }
    
    
    if(data == nil)
    {
        data = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], loadFileName]];
    }
    UIImage *colorsImage = [[UIImage alloc] initWithData:data];
    
    UIImageView* colorsView = [[UIImageView alloc] initWithImage:colorsImage];

    [colorsView setFrame:CGRectMake(65, 0, kWIDTH-65,kHEIGHT-32)];
    [addOnView addSubview:colorsView];
    
    //ADD THE SCROLLING ALBUM DISPLAY
    UIScrollView* scrollAlbums = [[UIScrollView alloc] initWithFrame:CGRectMake(toolbarWidth, 30, kWIDTH-toolbarWidth, kHEIGHT-30-32)];
    [scrollAlbums setBackgroundColor:[UIColor clearColor]];
    [scrollAlbums setScrollEnabled:YES];
    NSMutableArray* theAlbumViews = [[NSMutableArray alloc] init];
    theAlbumScrollViews = [[NSMutableArray alloc] init];
    NSMutableArray* theAlbumNames = [[NSMutableArray alloc] init];
    theAlbumNamesFull = [[NSMutableArray alloc] init];
    NSMutableArray* theMovementNames = [[NSMutableArray alloc] init];
    NSMutableArray* theComposerNames = [[NSMutableArray alloc] init];
    NSString* currentPiece = @"jawn";
    
    int albumPositionCount = 0;
    for(int i = 0; i < [thePieces count]; i++)
    {
        
        // CREATE PIECES buttons, so that the user can tap anywhere on a piece
        UITaggedButton* albumArtButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(0, 0, albumWidth, kHEIGHT-30-32-10-10)];
        [albumArtButton setBackgroundColor:[UIColor clearColor]];
        albumArtButton.tagText = [[thePieces objectAtIndex:i] name];
        [albumArtButton addTarget:self action:@selector(albumSelected:) forControlEvents:UIControlEventTouchUpInside];
        // Add the hold down property to the album art to delete a piece
        holdRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showDeleteMode:)];
        [holdRecognizer setMinimumPressDuration:1]; // Time that needs to be holded before it calls showDeleteMode
        [albumArtButton addGestureRecognizer:holdRecognizer];

        UIView* albumArt = [[UIView alloc] initWithFrame:CGRectMake(albumPositionCount*albumWidth+albumPositionCount*10 + 10, 10, albumWidth, kHEIGHT-30-32-10-10)];
        
        NSString* pieceFullNameText = [[thePieces objectAtIndex:i] name];
        NSArray *items = [pieceFullNameText componentsSeparatedByString:@", "];

        
        if([items count]>1)
        {
            
            NSRange rangeOfDash = [pieceFullNameText rangeOfString:@", "];
            NSString* composor  = (rangeOfDash.location != NSNotFound) ? [pieceFullNameText substringToIndex:rangeOfDash.location] : @"";
            NSString* pieceName = (rangeOfDash.location != NSNotFound) ? [pieceFullNameText substringFromIndex:rangeOfDash.location+1] : @"";
            
            NSArray* movementsArray = [pieceName componentsSeparatedByString:@": "];
            NSString* movementName;
            
            if([movementsArray count] >1)
            {
                movementName = [[NSString alloc] initWithString:[movementsArray objectAtIndex:1]];
                [theMovementNames addObject:movementName];
                [theComposerNames addObject:composor];
                pieceName = [movementsArray objectAtIndex:0];
                [theAlbumNamesFull addObject:pieceName];
            }
            
            
            if(![pieceName isEqualToString:currentPiece])
            {
                //Label of composer on album art
                UILabel* pieceComposorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,albumWidth,30)];
                [pieceComposorLabel setText:composor];
                [pieceComposorLabel setFont: ALBUM_COMPOSER_FONT];
                pieceComposorLabel.backgroundColor = ALBUM_COMPOSER_BG_COLOR;
                pieceComposorLabel.textColor = ALBUM_COMPOSER_TEXT_COLOR;
                pieceComposorLabel.textAlignment = NSTextAlignmentCenter;
                
                
                //label of piece name on album art
                UITextView* pieceNameLabel = [[UITextView alloc] initWithFrame:CGRectMake(0,100,albumWidth,100)];
                [pieceNameLabel setText:pieceName];
                [pieceNameLabel setFont:ALBUM_NAME_FONT];
                pieceNameLabel.backgroundColor = [UIColor clearColor];
                pieceNameLabel.textColor = ALBUM_NAME_TEXT_COLOR;
                pieceNameLabel.textAlignment = NSTextAlignmentCenter;
                
                UIButton* isCurrentLiveButton = [[UIButton alloc] initWithFrame:CGRectMake(0,albumArt.frame.size.height - 50,albumWidth,50)];
                isCurrentLiveButton.backgroundColor = [UIColor clearColor];
                [isCurrentLiveButton addTarget:self action:@selector(goToLivePositionFromTable) forControlEvents:UIControlEventTouchDown];
                [isCurrentLiveButton.titleLabel setFont:ALBUM_LIVE_BUTTON_FONT];
                [isCurrentLiveButton setTitleColor:ALBUM_LIVE_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
                
                // Button that appears when holddown event happen to delete a piece
                UIImage *trashIcon = [UIImage imageNamed:@"deletePieceIcon.png"];
                UITaggedButton* deletePieceButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(albumWidth-30, (pieceComposorLabel.frame.size.height-trashIcon.size.height)/2, 20, 20)];
                deletePieceButton.backgroundColor = [UIColor colorWithPatternImage:trashIcon];
                deletePieceButton.tagText = [[thePieces objectAtIndex:i] name];
                [deletePieceButton addTarget:self action:@selector(albumDelete:) forControlEvents:UIControlEventTouchDown];
                deletePieceButton.hidden  = YES;
                deletePieceButton.enabled = NO;
                
                
                [pieceComposerLabels addObject: pieceComposorLabel]; // Contains all labels for the top red banner of a piece
                [liveLabelButtons    addObject: isCurrentLiveButton];
                [deletePieceButtons  addObject: deletePieceButton]; // Contains all trash buttons for each piece
                [composersAlbumList  addObject: composor];
                [piecesAlbumList     addObject: pieceName];
                
                NSLog(@"added, composor :  %@ , pieceName :  %@ " ,composor,pieceName);
                
                [albumArt addSubview:pieceComposorLabel];
                [albumArt addSubview:pieceNameLabel];
                pieceNameLabel.userInteractionEnabled = false;
                currentPiece = pieceName;
                [theAlbumViews addObject:albumArt];
                [theAlbumNames addObject:currentPiece];
                [albumArt addSubview:albumArtButton];
                [albumArt addSubview:isCurrentLiveButton];
                UIScrollView *albumPieceScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, albumWidth,  kHEIGHT-30-32-10-10-30)];
                [theAlbumScrollViews addObject:albumPieceScroll];
                albumPieceScroll.hidden = true;
                [albumArt addSubview:[theAlbumScrollViews objectAtIndex:[theAlbumScrollViews count]-1]];
                if (!([composor isEqualToString:@"Strauss"]||[pieceName isEqualToString:@"Don juan"])) {
                    [albumArt addSubview:deletePieceButton];
                }
                [scrollAlbums addSubview:albumArt];
                scrollAlbums.contentSize = CGSizeMake(albumPositionCount*albumWidth+albumPositionCount*10 + 10 + albumWidth + 10, kHEIGHT-30-32-10-10);
                [albumArt setBackgroundColor:ALBUM_BG_COLOR];
                albumPositionCount++;
            }
            
        }
        else{
            
            UILabel* pieceComposorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,albumWidth,30)];
            pieceComposorLabel.backgroundColor = ALBUM_COMPOSER_BG_COLOR;
            
            pieceComposorLabel.textAlignment = NSTextAlignmentCenter;
            
            UITextView* pieceNameLabel = [[UITextView alloc] initWithFrame:CGRectMake(0,100,albumWidth,100)];
            [pieceNameLabel setText:pieceFullNameText];
            [pieceNameLabel setFont:ALBUM_NAME_FONT];
            pieceNameLabel.backgroundColor = [UIColor clearColor];
            pieceNameLabel.textColor = ALBUM_NAME_TEXT_COLOR;
            pieceNameLabel.textAlignment = NSTextAlignmentCenter;
            
            [theMovementNames  addObject:pieceFullNameText];
            [theComposerNames  addObject: @" "];
            [theAlbumNamesFull addObject:pieceFullNameText];
            
            UIButton* isCurrentLiveButton = [[UIButton alloc] initWithFrame:CGRectMake(0,albumArt.frame.size.height - 50,albumWidth,50)];
            isCurrentLiveButton.backgroundColor = [UIColor clearColor];
            [isCurrentLiveButton addTarget:self action:@selector(goToLivePositionFromTable) forControlEvents:UIControlEventTouchDown];
            [isCurrentLiveButton.titleLabel setFont:ALBUM_LIVE_BUTTON_FONT];
            [isCurrentLiveButton setTitleColor:ALBUM_LIVE_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
            
            // Button that appears when holddown event happen to delete a piece
            UIImage *trashIcon = TRASH_ICON_IMAGE;
            UITaggedButton* deletePieceButton = [[UITaggedButton alloc] initWithFrame:CGRectMake(albumWidth-30, (pieceComposorLabel.frame.size.height-trashIcon.size.height)/2, 20, 20)];
            deletePieceButton.backgroundColor = [UIColor colorWithPatternImage:trashIcon];
            deletePieceButton.tagText = [[thePieces objectAtIndex:i] name];
            [deletePieceButton addTarget:self action:@selector(albumDelete:) forControlEvents:UIControlEventTouchDown];
            deletePieceButton.hidden  = YES;
            deletePieceButton.enabled = NO;
            
            [liveLabelButtons    addObject:  isCurrentLiveButton];
            [deletePieceButtons  addObject:  deletePieceButton];
            [pieceComposerLabels addObject: pieceComposorLabel];
            [composersAlbumList  addObject:  @" "];
            [piecesAlbumList     addObject:  pieceFullNameText];
            
            pieceNameLabel.userInteractionEnabled = false;
            [albumArt addSubview:pieceComposorLabel];
            [albumArt addSubview:pieceNameLabel];
            
            [theAlbumViews addObject:albumArt];
            [theAlbumNames addObject:pieceFullNameText];
            [albumArt addSubview:albumArtButton];
            [albumArt addSubview:isCurrentLiveButton];
            
            if ([pieceFullNameText rangeOfString:@"Strauss, Don Juan: Don Juan"].location == NSNotFound ) {
                [albumArt addSubview:deletePieceButton];
            }
            [scrollAlbums addSubview:albumArt];
        }
    }
    
    
    //ADD THE MVMT LABELS TO ALBUM ART
    labelViewBarsArray = [[NSMutableArray alloc] init];
    int pieceCount = 0;
    NSString* currentName = [[NSString alloc] initWithString:(NSString*)[theAlbumNames objectAtIndex:0]];
    int xJawn = 0;
    int yJawn = 0;
    int labelHeightJawn = 40;
    int incramentLabel = labelHeightJawn + 0;
    for(int i = 0; i<[theMovementNames count];i++){
        if(![[theAlbumNamesFull objectAtIndex:i] isEqualToString:currentName]){
            pieceCount++;
            currentName = [theAlbumNames objectAtIndex:pieceCount];
            yJawn = 0;
        }
        TrackLabelView* labelViewBar = [[TrackLabelView alloc] initWithFrame:CGRectMake(xJawn,yJawn,albumWidth,labelHeightJawn)];
        yJawn = yJawn + incramentLabel;
        [labelViewBar setPieceName:currentName withMovementName:(NSString*)[theMovementNames objectAtIndex:i] withTag:i];
        labelViewBar.composerName = (NSString*)[theComposerNames objectAtIndex:i];
        labelViewBar.hidden = YES;
        [labelViewBar addTarget:self action:@selector(navigateToMovement:) forControlEvents:UIControlEventTouchUpInside];
        [labelViewBarsArray addObject:labelViewBar];
        [[theAlbumScrollViews objectAtIndex:pieceCount] setContentSize:CGSizeMake(albumWidth, yJawn)];
        [[theAlbumScrollViews objectAtIndex:pieceCount] addSubview:[labelViewBarsArray objectAtIndex: [labelViewBarsArray count]-1]];
    }
    
    [addOnView addSubview:scrollAlbums];
    
    //ADD THE PROGRAM NOTES VIEW
    programNotesView = [[UIView alloc] initWithFrame:CGRectMake(toolbarWidth, 30, kWIDTH-toolbarWidth, kHEIGHT-30-32)];
    [programNotesView setBackgroundColor:[UIColor clearColor]];
    
    programNotesView.hidden = YES;
    programNotesView.alpha = 0.0;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH-toolbarWidth, kHEIGHT-30-32)];
    NSString* urlString = [[NSString alloc] initWithFormat:@"http://%@/images/AppAssets/ProgramNotes.pdf",SERVER_IP];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    [webView setBackgroundColor: [UIColor clearColor]];
    [webView setScalesPageToFit:YES];
    [programNotesView addSubview:webView];
    
    [addOnView addSubview:programNotesView];
    
    //ADD THE PROGRAM NOTES BUTTON
    programNotesNewButton = [[UIButton alloc] initWithFrame:CGRectMake(kWIDTH-150, 5, 145, 25)];
    programNotesNewButton.backgroundColor = PROGRAM_NOTES_BUTTON_BG_COLOR;
    
    [programNotesNewButton setTitle:@" Program Notes ▾" forState:UIControlStateNormal];
    [programNotesNewButton.titleLabel setFont:PROGRAM_NOTES_BUTTON_FONT];
    [programNotesNewButton setTitleColor:PROGRAM_NOTES_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [programNotesNewButton addTarget:self action:@selector(loadProgramNotesNew) forControlEvents:UIControlEventTouchUpInside];
    
    [addOnView addSubview:programNotesNewButton];
    
    //ADD THE LEFT TOOLBAR
    UIView* toolbar = [[UIView alloc] initWithFrame:CGRectMake(0,0,toolbarWidth,kHEIGHT)];
    [toolbar setBackgroundColor:TOOLBAR_BG_COLOR];
    
    //HELP BUTTON
    glossaryButton = [[UITaggedButton alloc] initWithFrame:CGRectMake((toolbarWidth-toolbarWidth*.9)/2, 15, toolbarWidth*.9, toolbarWidth*.9)];
    glossaryButton.userInteractionEnabled = YES;
    glossaryButton.tagText = @"glossary";
    [glossaryButton setBackgroundImage:GLOSSARY_ICON_FRONT_IMAGE forState:UIControlStateNormal];
    [glossaryButton addTarget:self action:@selector(toobarButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    //BRIGHTNESS BUTTON
    brightButton = [[UITaggedButton alloc] initWithFrame:CGRectMake((toolbarWidth-toolbarWidth*.9)/2, (toolbarWidth + 15), toolbarWidth*.9, toolbarWidth*.9)];
    brightButton.userInteractionEnabled = YES;
    brightButton.tagText = @"brightness";
    [brightButton setBackgroundImage:BRIGHTNESS_ICON_FRONT_IMAGE forState:UIControlStateNormal];
    [brightButton addTarget:self action:@selector(toobarButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    //HELP BUTTON
    helpButton = [[UITaggedButton alloc] initWithFrame:CGRectMake((toolbarWidth-toolbarWidth*.9)/2, (toolbarWidth)*2+15, toolbarWidth*.9, toolbarWidth*.9)];
    helpButton.userInteractionEnabled = YES;
    helpButton.tagText = @"help";
    [helpButton setBackgroundImage:HELP_ICON_FRONT_IMAGE forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(toobarButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    //INFO BUTTON
    infoButton = [[UITaggedButton alloc] initWithFrame:CGRectMake((toolbarWidth-toolbarWidth*.9)/2, (toolbarWidth)*3+15, toolbarWidth*.9, toolbarWidth*.9)];
    infoButton.userInteractionEnabled = YES;
    infoButton.tagText = @"info";
    [infoButton setBackgroundImage:INFO_ICON_FRONT_IMAGE forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(toobarButtonsActivated:) forControlEvents:UIControlEventTouchDown];
    
    [toolbar addSubview:glossaryButton];
    [toolbar addSubview:brightButton];
    [toolbar addSubview:helpButton];
    [toolbar addSubview:infoButton];
    [addOnView addSubview:toolbar];

    //ADD THE MAIN VIEW PAGE
    [self.view addSubview:addOnView];

    previousLiveMovement = @"jawn";
    isLiveLabelTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkLiveLabel:) userInfo:nil repeats:YES];
}

-(void)checkLiveLabel:(NSTimer*) theTimer
{
    NSString* currentPieceFullName = appDelegate.CURRENT_PIECE;
    NSRange rangeOfDash = [currentPieceFullName rangeOfString:@", "];
    NSString* liveComposor = (rangeOfDash.location != NSNotFound) ? [currentPieceFullName substringToIndex:rangeOfDash.location] : nil;
    NSString* livePieceName = (rangeOfDash.location != NSNotFound) ? [currentPieceFullName substringFromIndex:rangeOfDash.location+1] : nil;
    NSArray* movementsArray = [livePieceName componentsSeparatedByString:@": "];
    NSString* livePieceTitle = [movementsArray objectAtIndex:0];
    NSString* livePieceMovement;
    
    if([movementsArray count]>1)
    {
        livePieceMovement = [[NSString alloc] initWithString:[movementsArray objectAtIndex:1]];
    }
    else{
        livePieceMovement = livePieceTitle;
    }
    
    if(![currentPieceFullName isEqualToString:previousLiveMovement])
    {
        previousLiveMovement = currentPieceFullName;
        for(int i = 0; i< [composersAlbumList count];i++)
        {
            if([livePieceTitle isEqualToString:[piecesAlbumList objectAtIndex:i]] && [liveComposor isEqualToString:[composersAlbumList objectAtIndex:i]])
            {
                NSString* liveTitle = [[NSString alloc] initWithFormat:@"LIVE: %@",livePieceMovement];
                [[liveLabelButtons objectAtIndex:i] setHidden:NO];
                [[liveLabelButtons objectAtIndex:i] setTitle:liveTitle forState:UIControlStateNormal];
                [[liveLabelButtons objectAtIndex:i] setFont:ALBUM_LIVE_BUTTON_FONT];
                [[liveLabelButtons objectAtIndex:i] setTitleColor:ALBUM_LIVE_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
            }
            else{
                [[liveLabelButtons objectAtIndex:i] setHidden:YES];
            }
        }
    }
    
    
}

-(void) goToLivePositionFromTable
{
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* currentPieceName = appDelegate.CURRENT_PIECE;
    MusicPiece * thisPiece = [thePieces objectAtIndex:0];
    for(int i = 0; i< [thePieces count];i++)
    {
        NSString* pieceName = [[thePieces objectAtIndex:i] name];
        if([pieceName isEqualToString:currentPieceName])
        {
            thisPiece = [thePieces objectAtIndex:i];
        }
    }
    
    if(appDelegate.USE_SLIDE_FORMAT){
        if(appDelegate.mode == DEMO_MODE){
            appDelegate.LIVE = YES;
            NSArray * vc = trackTabBar.viewControllers;
            for(UIViewController * uivc in vc){
                [((NavigationViewController *)uivc) stopTimer];
            }
        }
        
        NSMutableArray * trackStuff = [arrayOfTracks objectForKey:thisPiece.name];
        [self configureTracks:trackStuff piece:thisPiece];
        
        trackTabBar.selectedIndex = 0;
        [self.navigationController pushViewController:trackTabBar animated:YES];
        trackTabBar.title = thisPiece.name;
        if(tabBarVisible)
        {
            [self hidetabbar];
        }
        if(![appDelegate.CURRENT_PIECE isEqualToString:thisPiece.name] && (appDelegate.mode == DEMO_MODE)){
            if(thisPiece.audio)
                [appDelegate setSong:thisPiece.audio];
            
            appDelegate.CURRENT_PIECE = thisPiece.name;
            
            NSArray * vc = trackTabBar.viewControllers;
            for(UIViewController * uivc in vc){
                [((NavigationViewController *)uivc) startTimer];
            }
        }
    }
    else{
        
        if(appDelegate.mode == DEMO_MODE){
            appDelegate.LIVE = YES;
        }
        
        if(![appDelegate.CURRENT_PIECE isEqualToString:thisPiece.name] && (appDelegate.mode == DEMO_MODE)){
            if(thisPiece.audio){
                [appDelegate setSong:thisPiece.audio];
            }
            appDelegate.CURRENT_PIECE = thisPiece.name;
        }
    }
    
    NSLog(@"Going Live From Table");
    
    NSMutableArray* allNames = thePieces;
    for(int p = 0;p< [allNames count];p++)
    {
        NSString* pieceName = [[allNames objectAtIndex:p] name];
        for(int i = 0; i<[[arrayOfTracks objectForKey:pieceName] count]; i++)
        {
            [[[arrayOfTracks objectForKey:pieceName] objectAtIndex:i] goLive];
        }
    }
}

-(void) loadProgramNotesNew
{
    if(programNotesView.hidden){
        programNotesView.hidden = NO;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        programNotesView.alpha = 1.0;
        [UIView commitAnimations];
        [programNotesNewButton setTitle:@" Program Notes ▴" forState: UIControlStateNormal ];
    }
    else if (!programNotesView.hidden){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animateProgramDone)];
        programNotesView.alpha = 0.0;
        [UIView commitAnimations];
        [programNotesNewButton setTitle:@" Program Notes ▾" forState: UIControlStateNormal ];
    }
}
-(void)animateProgramDone
{
    programNotesView.hidden = YES;
}

-(void)albumSelected:(id)sender
{
    [albumViewTimer invalidate];
    
    if(inDeleteMode){
        NSLog(@"An album have been selected and we are exiting the delete mode");
        [self hideDeleteMode];
    }
    
    else{
        
        NSLog(@"%@",(NSString*)((UITaggedButton*)sender).tagText);
        for(int i = 0; i< [labelViewBarsArray count];i++)
        {
            ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).alpha = 0.0;
            ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).hidden = NO;
        }
        
        for(int i = 0; i< [theAlbumScrollViews count];i++)
        {
            ((UIScrollView *) [theAlbumScrollViews objectAtIndex:i]).alpha = 0;
            ((UIScrollView *) [theAlbumScrollViews objectAtIndex:i]).hidden = NO;
        }
        
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        NSArray* movementsArray = [(NSString*)((UITaggedButton*)sender).tagText componentsSeparatedByString:@": "];
        NSString* taggedPiece = [[NSString alloc] initWithString:[movementsArray objectAtIndex:0]];
        
        NSString* currentPieceName = @"";
        for(int i = 0; i< [labelViewBarsArray count];i++)
        {
            NSString* labelPiece = [[NSString alloc] initWithFormat:@"%@,%@", ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).composerName, ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).pieceName];
            
            if([labelPiece isEqualToString:taggedPiece])
            {
                ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).alpha = 1.0;
                currentPieceName = [((NSString*)((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).pieceName)  stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
        }
        
        int showIndex = 0;
        for(int i=0;i<piecesAlbumList.count;i++)
        {
            if([[[piecesAlbumList objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:currentPieceName])
            {
                showIndex = i;
            }
        }
        
        for(int i = 0; i< [theAlbumScrollViews count];i++)
        {
            if(i==showIndex)
            {
                ((UIScrollView *) [theAlbumScrollViews objectAtIndex:i]).alpha = 1.0;
            }
            else
            {
                ((UIScrollView *) [theAlbumScrollViews objectAtIndex:i]).hidden = YES;
            }
        }
        
        //programNotesView.frame = CGRectMake(0, 0,0, 0);
        [UIView commitAnimations];
        
        albumViewTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(fadeLabelViews)
                                       userInfo:nil
                                        repeats:NO];
        NSLog(@"Current:%@",currentPieceName);
        NSLog(@"CurrentIndex:%d",showIndex);
    }
}

-(void) fadeLabelViews
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideLabelViews)];
    for(int i = 0; i< [theAlbumScrollViews count];i++)
    {
        ((UIScrollView *) [theAlbumScrollViews objectAtIndex:i]).alpha = 0.0;
    }
    for(int i = 0; i< [labelViewBarsArray count];i++)
    {
        ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).alpha = 0.0;
    }
    [UIView commitAnimations];
}

-(void)hideLabelViews
{
    for(int i = 0; i< [labelViewBarsArray count];i++)
    {
        ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).hidden = YES;
    }
    for(int i = 0; i< [theAlbumScrollViews count];i++)
    {
        ((UIScrollView *) [theAlbumScrollViews objectAtIndex:i]).hidden = YES;
    }
}

-(void)navigateToMovement:(id)sender
{
    NSLog(@"NavigatingToMovement: %d", [((TrackLabelView*)sender) getTag]);
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MusicPiece * thisPiece = (MusicPiece *)[thePieces objectAtIndex:[((TrackLabelView*)sender) getTag]];
    
    if(appDelegate.USE_SLIDE_FORMAT){
        if(appDelegate.mode == DEMO_MODE){
            appDelegate.LIVE = YES;
            NSArray * vc = trackTabBar.viewControllers;
            for(UIViewController * uivc in vc){
                [((NavigationViewController *)uivc) stopTimer];
            }
        }
        
        NSMutableArray * trackStuff = [arrayOfTracks objectForKey:thisPiece.name];
        [self configureTracks:trackStuff piece:thisPiece];
        trackTabBar.selectedIndex = 0;
        [self.navigationController pushViewController:trackTabBar animated:YES];
        trackTabBar.title = thisPiece.name;
        
        if(tabBarVisible)
        {
            [self hidetabbar];
        }
        if(![appDelegate.CURRENT_PIECE isEqualToString:thisPiece.name] && (appDelegate.mode == DEMO_MODE)){
            if(thisPiece.audio)
                [appDelegate setSong:thisPiece.audio];
            
            appDelegate.CURRENT_PIECE = thisPiece.name;
            
            NSArray * vc = trackTabBar.viewControllers;
            for(UIViewController * uivc in vc){
                [((NavigationViewController *)uivc) startTimer];
            }
        }
    }
    else{
        
        if(appDelegate.mode == DEMO_MODE){
            appDelegate.LIVE = YES;
        }
        
        if(![appDelegate.CURRENT_PIECE isEqualToString:thisPiece.name] && (appDelegate.mode == DEMO_MODE)){
            if(thisPiece.audio){
                [appDelegate setSong:thisPiece.audio];
            }
            
            appDelegate.CURRENT_PIECE = thisPiece.name;
        }
        
    }
}

-(void)toobarButtonsActivated:(id)sender
{
    NSLog(@"Toolbar Jawned");
    if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"glossary"] ){
        NSLog(@"pushing Glossary");
        Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
        GlossaryViewController * glossary = appDelegate.glossary;
        glossary.navigationItem.title = @"Glossary";
        [glossary goToPage:@"adagio"];
        [self.navigationController pushViewController:glossary animated:YES];
    }
    else if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"brightness"] )
    {
        NSLog(@"Adjusting Brightness from MainViewController");
        Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate adjustBrightness];
    }
    else if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"help"] ){
        NSLog(@"Getting Help");
        UIButton *someImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kHEIGHT, kWIDTH)];
        NSString* loadFileName;
        int width = [DeviceProperties getDeviceResolutionLandscape].width;
        if([DeviceProperties getDeviceResolutionLandscape].width == 480)
        {
            loadFileName = MAIN_WINDOW_HELP_32;
        }
        else{
            loadFileName = MAIN_WINDOW_HELP_169;
        }
        
        NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"http://%@/images/AppAssets/%@",SERVER_IP,loadFileName];
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
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

        self.navigationController.view.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        [someImageView setBackgroundImage:helpImage forState:UIControlStateNormal];
        [someImageView setAlpha:0.0];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            someImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            someImageView.frame =  CGRectMake(0, 0, kWIDTH, kHEIGHT);
        }
        
        [someImageView addTarget:self action:@selector(killHelp:) forControlEvents:UIControlEventTouchUpInside];
        [[[UIApplication sharedApplication] keyWindow] addSubview:someImageView];
        
        [UIView beginAnimations:@"fade" context:nil];
        [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] setAlpha:1.0];
        [UIView commitAnimations];
    }
    else if([(NSString*)((UITaggedButton *)sender).tagText isEqualToString:@"info"] ){
        NSLog(@"Getting Info");
        UIButton *someImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kHEIGHT, kWIDTH)];
        NSString* loadFileName;
        if([DeviceProperties getDeviceResolutionLandscape].width == 480)
        {
            loadFileName = INFO_SCREEN_32;
        }
        else{
            loadFileName = INFO_SCREEN_169;
        }
        
        NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"http://%@/images/AppAssets/%@",SERVER_IP,loadFileName];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
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
            data = [NSData dataWithContentsOfFile: [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], loadFileName]];
        }
        
        UIImage *helpImage = [[UIImage alloc] initWithData:data];
        [someImageView setBackgroundImage:helpImage forState:UIControlStateNormal];
        [someImageView setAlpha:0.0];
        [someImageView addTarget:self action:@selector(killInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* linkButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,32,kWIDTH)];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            someImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            someImageView.frame =  CGRectMake(0, 0, kWIDTH, kHEIGHT);
            linkButton.frame = CGRectMake(0,0,32,kWIDTH);
        }
        [linkButton addTarget:self action:@selector(infoLinkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        linkButton.backgroundColor = [UIColor blackColor];
        [linkButton setAlpha:0.1];
        [someImageView addSubview:linkButton];
        [[[UIApplication sharedApplication] keyWindow] addSubview:someImageView];
        [UIView beginAnimations:@"fade" context:nil];
        [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] setAlpha:1.0];
        [UIView commitAnimations];
        
        self.navigationController.view.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
    }
    
}
- (void)infoLinkButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:INFO_LINK]];
}



- (void)killHelp:(id)sender
{
    self.navigationController.view.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [sender removeFromSuperview];
}

- (void)fadeAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] removeFromSuperview]; //This assumes that your label is a property of your view controller
}

- (void) killInfo:(id)sender
{
    self.navigationController.view.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [sender removeFromSuperview];
}

- (void)fadeAnimationDidStopInfo:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] removeFromSuperview]; //This assumes that your label is a property of your view controller
    [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:([[[[UIApplication sharedApplication] keyWindow] subviews] count] - 1)] removeFromSuperview];
}





#pragma mark -
#pragma mark Delete Piece functions


-(void)showDeleteMode:(UILongPressGestureRecognizer*)recognizer
{
    // This gets called when an albumArt button (piece) gets a long touch from the user
    inDeleteMode = true;

    ////////// DISABLE ALL OTHER FUNCTIONS
    // Get the bigger size of our arrays for the loop
    int iMax = MAX(MAX([labelViewBarsArray count], [deletePieceButtons count]), MAX([pieceComposerLabels count], [liveLabelButtons count]));
    
    // Count how many pieces are on the App
    numberOfPiecesWhenDeleting = (int)[thePieces count];
    
    if (numberOfPiecesWhenDeleting>1) {
        
        // They should all have the same dimensions, but you never know...
        for(int i =0; i<iMax;i++)
        {
            if (i<[deletePieceButtons count]) {
                // Make the delete buttons appear
                [[deletePieceButtons objectAtIndex:i] setHidden:NO];
                [[deletePieceButtons objectAtIndex:i] setEnabled:YES];
            }
            if (i<[pieceComposerLabels count]) {
                // Change the color of the pieces (so that the user understand he's in edit mode)
                [[pieceComposerLabels objectAtIndex:i] setBackgroundColor:[UIColor whiteColor]];
            }
            if (i<[liveLabelButtons count]) {
                // Disable the "Live" green buttons
                [[liveLabelButtons objectAtIndex:i] setEnabled:NO];
                [[liveLabelButtons objectAtIndex:i] setAlpha:0.5];
            }
            if (i<[labelViewBarsArray count]) {
                // Disable goToLivePositionFromTable function
                ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).alpha = 0.5;
                ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).enabled = NO;
            }
        }
        
        // DISABLE everything else
        programNotesNewButton.enabled = NO;
        programNotesNewButton.alpha   = 0.5;
        glossaryButton.enabled        = NO;
        glossaryButton.alpha          = 0.5;
        infoButton.enabled            = NO;
        infoButton.alpha              = 0.5;
        goLiveButtonFromTable.enabled = NO;
        refreshButton.enabled         = NO;
        // Brigthness and help will still be available in this edit mode
        brightButton.alpha  = 0.5;
        helpButton.alpha    = 0.5;
        
        
        // write function for
        // That should also suspend the other functions (you cannot navigate to a piece)
        
    }
    
    
}

-(void)hideDeleteMode
{
    // Gets called when the user is done deleting pieces
    
    inDeleteMode = false;
    ////////// ENABLE ALL OTHER FUNCTIONS to come back to normal
    
    // Get the bigger size of our arrays for the loop
    int iMax = MAX(MAX([labelViewBarsArray count], [deletePieceButtons count]), MAX([pieceComposerLabels count], [liveLabelButtons count]));
    
    // They should all have the same dimensions, but you never know...
    for(int i =0; i<iMax;i++)
    {
        if (i<[deletePieceButtons count]) {
            // Make the delete buttons appear
            [[deletePieceButtons objectAtIndex:i] setHidden:YES];
            [[deletePieceButtons objectAtIndex:i] setEnabled:NO];
        }
        if (i<[pieceComposerLabels count]) {
            // Change the color of the pieces (so that the user understand he's in edit mode)
            [[pieceComposerLabels objectAtIndex:i] setBackgroundColor:ALBUM_COMPOSER_BG_COLOR];
        }
        if (i<[liveLabelButtons count]) {
            // Disable the "Live" green buttons
            [[liveLabelButtons objectAtIndex:i] setEnabled:YES];
            [[liveLabelButtons objectAtIndex:i] setAlpha:1];
        }
        if (i<[labelViewBarsArray count]) {
            // Disable goToLivePositionFromTable function
            ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).alpha = 1;
            ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).enabled = YES;
        }
    }
    
    // ENABLE everything back once done editing
    programNotesNewButton.enabled = YES;
    programNotesNewButton.alpha   = 1;
    glossaryButton.enabled        = YES;
    glossaryButton.alpha          = 1;
    infoButton.enabled            = YES;
    infoButton.alpha              = 1;
    brightButton.alpha            = 1;
    helpButton.alpha              = 1;
    goLiveButtonFromTable.enabled = YES;
    refreshButton.enabled         = YES;
    
}


-(void)albumDelete:(id)sender
{
    // Finised on August 8 2014, Julie Borgeot
    
    NSLog(@"Attempted to delete an album");
    
    //* Get the name of the piece to be deleted *//
    albumToDelete = (NSString*)((UITaggedButton*)sender).tagText; // name of the piece to be deleted
    
    // Get the tite of the piece for user messages
    NSRange colonRange = [albumToDelete rangeOfString:@":"];
    NSString *taggedPiece;
    if (colonRange.location<[albumToDelete length]) {
        taggedPiece = [albumToDelete substringToIndex:colonRange.location];
    }else{
        taggedPiece = albumToDelete;
    }

    
    //* check what pieces are being played and insert them into an array of strings *//
    NSArray      * livePiecesArray = [[NSArray alloc] init];
    NSString     * urlPiecesString = [NSString stringWithFormat:@"http://%@/getPieces.php", SERVER_IP];
    NSURL        * urlPieces       = [NSURL URLWithString:urlPiecesString];
    NSURLRequest * piecesRequest    = [[NSURLRequest alloc] initWithURL:urlPieces cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:3.0];
    NSURLResponse*piecesResponse;
    NSError      *error = nil;
    NSData       *tempData = [NSURLConnection sendSynchronousRequest:piecesRequest returningResponse:&piecesResponse error:&error];
    NSString     *piecesStringContent = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
    
    livePiecesArray = [piecesStringContent componentsSeparatedByString: @";"];  // Array of live pieces

    
    NSLog(@"Trying to delete : %@", albumToDelete);
    NSLog(@"The live pieces are : %@",livePiecesArray);
    
    // Check the network to see which actions we can and cannot do
    NSLog(@"when deleting, the SSID found is %@",[NetworkCheck whatIsMySSID]);
    
    if(([NetworkCheck whatIsMyConnectionType] == 0)||([NetworkCheck whatIsMyConnectionType] == 2) || ![[NetworkCheck whatIsMySSID] isEqualToString:SSID]) // not at PHL or no internet connection or 3G connection
    {
        //* CLIENT not at PHL *//
        // We enter this when the user needs to connect to wifi
        NSLog(@"Using local data. Order doesn't matter");
        [piecesToBeDeleted removeAllObjects];
        for(int i = 0; i< [labelViewBarsArray count];i++)
        {
            
            
            // Get the label of the piece
            NSString* labelPiece = [[NSString alloc] initWithFormat:@"%@,%@", ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).composerName, ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).pieceName];
            
            // Compare with the label of the piece that we want to delete
            if([labelPiece isEqualToString:taggedPiece])
            {
                NSString *fullPieceString;
                fullPieceString = [NSString stringWithFormat:@"%@%@%@", ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).composerName, ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).pieceName,((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).movementName];
                
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                fullPieceString = [[fullPieceString componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
                fullPieceString = [NSString stringWithFormat:@"POA%@",fullPieceString];
                [piecesToBeDeleted addObject:fullPieceString];
            }
        }
        NSLog(@"The piece to be deleted is %@",piecesToBeDeleted);
        
        // send an alert : Are you sure ?
        NSString* deleteMessage       = [NSString stringWithFormat: @"Delete %@? This action cannot be undone.",taggedPiece];
        UIAlertView* alertWhenDeleteHit = [[UIAlertView alloc] initWithTitle:@"Delete Piece" message:deleteMessage delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"delete", nil];
        alertWhenDeleteHit.tag = 100;
        [alertWhenDeleteHit show];
    }
    else
    {
        /*---------------*/
        /* CLIENT AT PHL */
        /*---------------*/
        // We enter this when the client is at the PHL, ready to load content from the server
        
        // Check if the piece to delete is part of the program at the orchestra
        BOOL pieceToDeleteIsLive = [livePiecesArray containsObject:albumToDelete];
        NSLog(@" Is this piece current live ?? : %d", pieceToDeleteIsLive);
        if (pieceToDeleteIsLive) {
            
            // IF THE PIECE IS LIVE //
            NSLog(@"Not deleting anything because piece is live");
            
            // send an alert : this can't be deleted
            NSString    * cannotDeleteMessage   = [NSString stringWithFormat: @" %@ cannot be deleted because it is part of today's performance",taggedPiece];
            UIAlertView * alertWhenCannotDelete = [[UIAlertView alloc] initWithTitle:@"Cannot Delete" message:cannotDeleteMessage delegate:self cancelButtonTitle:@"got it !" otherButtonTitles:nil, nil];
            alertWhenCannotDelete.tag = 500;
            [alertWhenCannotDelete show];
        }else{
            
            // IF THIS PIECE ISN'T LIVE
            NSLog(@"Reloading the whole view from the server.");
            
            // Get all of the movements to be deleted in piecesToBeDeleted. Example of string : POAStraussDonJuanDonJuan (POAcomposerNamepieceNamemovementName)
            [piecesToBeDeleted removeAllObjects];
            
            for(int i = 0; i< [labelViewBarsArray count];i++)
            {
                // Get the label of the piece
                NSString* labelPiece = [[NSString alloc] initWithFormat:@"%@,%@", ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).composerName, ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).pieceName];

                // Compare with the label of the piece that we want to delete
                if([labelPiece isEqualToString:taggedPiece])
                {
                    NSString *fullPieceString;
                    fullPieceString = [NSString stringWithFormat:@"%@%@%@", ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).composerName, ((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).pieceName,((TrackLabelView *)[labelViewBarsArray objectAtIndex:i]).movementName];
                    
                    NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                    fullPieceString = [[fullPieceString componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
                    fullPieceString = [NSString stringWithFormat:@"POA%@",fullPieceString];
                    [piecesToBeDeleted addObject:fullPieceString];
                }
            }
            
            
            NSLog(@"The piece to be deleted is %@",piecesToBeDeleted);

            NSArray *pieceNameWords = [taggedPiece componentsSeparatedByString:@","];

            // send an alert : Are you sure ?
            NSString* deleteMessage       = [NSString stringWithFormat: @"Delete %@? This action cannot be undone.",[pieceNameWords objectAtIndex:0]];
            UIAlertView* alertWhenDeleteHit = [[UIAlertView alloc] initWithTitle:@"Delete Piece" message:deleteMessage delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"delete", nil];
            alertWhenDeleteHit.tag = 100;
            [alertWhenDeleteHit show];
        }
    }
}

-(void) deletePieces{
    
    // Finised on August 8 2014, Julie Borgeot
    
    // This function gets called when a user deletes the content associated with an album.
    // It goes to the documents directory and remove images, .xml and others
    
    // Get the doc directory
    NSString* docsDir = [SavedContentManager getDocumentsDir];
    
    // Take the name of the files to be deleted
    for(NSString* filename in piecesToBeDeleted)
    {
        // Computes the path of the files to be deleted
        NSString* savedPiecePath = [NSString stringWithFormat:@"%@/%@/",docsDir,filename];
        
        NSLog(@"The path of the file to be deleted is : %@", savedPiecePath);
        
        [SavedContentManager listFilesForPath:savedPiecePath];
        [SavedContentManager deleteFileAtPath:savedPiecePath];
        
        // Count the number of albums when the user switched to Delete Mode
        int numberOfPieces = (int)[self.thePieces count];
        
        // Count how many pieces are in total so that we exit the DeleteMode when there is nothing to delete anymore
        numberOfPiecesWhenDeleting--;
        NSLog(@"Done deleting !");
    }
    
    [self hideDeleteMode];
    
    // Reload the view
    [self performSelectorOnMainThread:@selector(editTitle:) withObject:@"Loading..." waitUntilDone:NO];
    
    if(([NetworkCheck whatIsMyConnectionType] == 0)||([NetworkCheck whatIsMyConnectionType] == 2) || ![[NetworkCheck whatIsMySSID] isEqualToString:SSID]){
        // reload the view in offline mode with local content
        [self reloadWhenOffline];
        
    }else{
        // reload the view from server
        mode = CONTENT;
        [self hideDeleteMode];
    }
    

    
}

-(void)reloadWhenOffline{
    
    // Finised on August 8 2014, Julie Borgeot
    
    // This function gets called when the user is at home and deleted some albums.
    // It reloads the view using local content
    
    // Start with reseting the arrays to fill them with the correct info later
    [liveLabelButtons       removeAllObjects];
    [deletePieceButtons     removeAllObjects];
    [pieceComposerLabels    removeAllObjects];
    [composersAlbumList     removeAllObjects];
    [piecesAlbumList        removeAllObjects];
    [piecesToBeDeleted      removeAllObjects];

    //gets list of saved docs
    NSArray* savedFileNames = [SavedContentManager listDocumentsDir];
    NSLog(@"the saved file names are %@",savedFileNames);
    
    // Always add Don Juan as an example in the App. It cannot be deleted
    if(![savedFileNames containsObject:@"POAStraussDonJuanDonJuan"])
    {
        NSString *donJuanDataPath =   @"data.xml";
        NSString *donJuanImagePath1 = @"DJ1.png";
        NSString *donJuanImagePath2 = @"DJ2.png";
        NSString *donJuanImagePath3 = @"DJ3.png";
        NSString *donJuanImagePath4 = @"DJ4.png";
        NSString *donJuanImagePath5 = @"DJ5.png";
        NSString *donJuanImagePath6 = @"DJ6.png";
        NSString *donJuanImagePath7 = @"DJ7.png";
        NSString *donJuanImageNames = @"imageNames.txt";
        NSString *donJuanName =       @"name.txt";
        
        NSArray* pathArray = [[NSArray alloc] initWithObjects:donJuanDataPath,donJuanImagePath1,donJuanImagePath2,donJuanImagePath3,donJuanImagePath4,donJuanImagePath5,donJuanImagePath6,donJuanImagePath7,donJuanImageNames, donJuanName,nil];
        
        [SavedContentManager createFolderInDocuments:@"POAStraussDonJuanDonJuan"];
        
        for (NSString* pathJawn in pathArray)
        {
            NSString* documentsPath = [NSString stringWithFormat:@"%@/POAStraussDonJuanDonJuan/%@",[SavedContentManager getDocumentsDir],pathJawn];
            NSString* preloadPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],pathJawn];
            
            [SavedContentManager copyFileAtPath:preloadPath toPath:documentsPath];
            
        }
        savedFileNames = [SavedContentManager listDocumentsDir];
        
    }
    
    NSLog(@"the saved file names are %@",savedFileNames);
    
    NSString* concatData = @"<?xml version=\"1.0\"?><concert>";
    for(NSString* tempPiece in savedFileNames)
    {
        MusicPieceFile* tempPieceFile = [[MusicPieceFile alloc] init];
        
        if(![tempPiece isEqualToString:@"POA"])
        {
            if([tempPieceFile  loadPiece:tempPiece])
            {
                if([tempPieceFile getPieceData]!= nil)
                {
                    concatData = [concatData stringByAppendingString:[tempPieceFile getPieceData]];
                    NSLog(@"Loaded %@",tempPiece);
                }
                else{
                    NSLog(@"Error Loading - piece has no data: %@",tempPiece);
                }
            }
            else{
                NSLog(@"Error Loading - piece not complete. %@",tempPiece);
            }
            
        }
        else{
            NSLog(@"Error Loading - brokenFile: %@",tempPiece);
        }
        
        
        
    }
    concatData = [concatData stringByAppendingString:@"</concert>"];
    
    contentString = [[NSString alloc] initWithString:concatData];
    NSLog(@"%@",contentString);
    mode = MEASURE;
    BOOL ok = [self parseData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
    if(!ok){
        [currentMeasure performSelectorOnMainThread : @selector(setText:) withObject:@"Parse Error" waitUntilDone:YES];
        
    }
    else{
        [self performSelectorOnMainThread : @selector(createTrackButtons) withObject:nil waitUntilDone:YES];
    }
    Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.splashViewController performSelectorOnMainThread : @selector(notifyFinished:) withObject:[NSNumber numberWithBool:TRUE] waitUntilDone:NO];
    appDelegate.CONNECTED_TO_SERVER = TRUE;

    // Call CreateNewNavView that generates the view from the arrays that we made
    [self performSelectorOnMainThread:@selector(createNewNavView) withObject:nil waitUntilDone:YES];
    
    // Reload the view
    [self performSelectorOnMainThread:@selector(editTitle:) withObject:@"Home" waitUntilDone:NO];
}



@end


