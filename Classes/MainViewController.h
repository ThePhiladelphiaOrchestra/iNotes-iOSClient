//
//  MainViewController.h
//  Test1
//
//  Created by Matthew Prockup on 11/16/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "DataPage.h"
#import "MusicPiece.h"
#import "ProgramNotesViewController.h"
#import "TrackLabelView.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#import <UIKit/UIKit.h>
#define kMulticastAddress "239.255.255.251"
#define kPortNumber 12345
//#define kBufferSize 1024
#define kMaxSockets 16
#import "constants.h"
#import "SavedContentManager.h"
#import "MusicPieceFile.h"
#import "MulticastClient.h"
#import "DeviceProperties.h"
#import "UITaggedTableViewCell.h"
#import "UITaggedButton.h"

typedef enum {
	CONTENT, MEASURE, CONNECT_MULTI
} Mode;

#define HORIZ_SWIPE_DRAG_MIN  12
#define VERT_SWIPE_DRAG_MAX    4

@interface MainViewController : UIViewController <UITabBarControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate> {
@public
    Mode mode;
    
@protected
    CGPoint startTouchPosition;
	BOOL    tabBarVisible;

	NSMutableArray * currentViewControllers;
	NSMutableDictionary * arrayOfTracks;
	
	UIImageView *backGroundImageView;
	UILabel *connectLabel;              // unused
	
	UILabel * currentMeasure;
	UITextField *textField;
	
	int whichTrack;
	
	UIPickerView   *   piecePicker;     // that seems unused
	NSMutableArray * pickerViewArray;   // seems unused
	
	UIView *tempView;                   // unused
	
	///NETWORK
	NSString *ipAdd;                // unused
	int portNum;
	bool connected;
	NSString* responseString;       // unused
	NSString* stringMeasure;        // unused
	NSString* idNum;                // unused
	int currentMeasureNumber;
	int cm;
	UILabel* textView;
	NSTimer *myTimer;
	
	UIButton *connectButton;        // unused
    UIButton *disconnectButton;     // unused
	UIButton *receiveButton;        // unused
	
	UIButton * flipButton;          // unused
    
	UIButton * loadContentButton;   // unused
	UIButton * startTrackingButton; // unused

    // Program notes
	UIView* programNotesView;
    UIButton* programNotesNewButton;
    
    
    // Left side toolbar
    UITaggedButton* glossaryButton;
    UITaggedButton* brightButton;
    UITaggedButton* helpButton;
    UITaggedButton* infoButton;
	
	// Temp structures for parsing the XML content
	NSMutableString * currentProperty;
	Track * currentTrack;
	DataPage * currentDataPage;
	MusicPiece * currentMusicPiece;
	
	// Final array which holds the MusicPiece's
	NSMutableArray *  thePieces;
	
	NSMutableArray * trackButtonArray;
	NSMutableArray * pieceList;
	
	UITextView * introTextView;     // unused
	

	UITabBarController * trackTabBar;
    
    
	UITableView * tableView;
	UIBarButtonItem * albumBarItem; // unused
	
	NSMutableDictionary * mapArray;
	NSString * contentString;
	
	ProgramNotesViewController * programNotes;
	
	UILabel *tabBarLabel;
	NSData* receivedData;
    
    // Elements in the top tabbar
    NSMutableArray* mapSegments;
    UIBarButtonItem *goLiveButton;          // unused
	UIBarButtonItem *goLiveButtonFromTable; // "View Live" button
    UIBarButtonItem *refreshButton;         // Refresh arrow button
    
    BOOL refreshSpinning;
    
    int currentTrackIndex;
    NSMutableArray* labelViewBarsArray;
    NSMutableArray* theAlbumNamesFull;      // Name in white showing in the album (content from server, dublons)
    NSMutableArray* liveLabelButtons;       // Array with the Live buttons in green
    NSMutableArray* composersAlbumList;     // Name of the composer as showing in the pieceComposerLabel (no doublons)
    NSMutableArray* piecesAlbumList;        // Same as theAlbumNamesFull without doublons
    NSMutableArray* piecesToBeDeleted;
    NSMutableArray* deletePieceButtons;     // Array with the delete buttons
    NSMutableArray* pieceComposerLabels;    // Array with the Red labels of the pieces
    NSMutableArray* theAlbumScrollViews;
    NSTimer *isLiveLabelTimer;
    NSString* previousLiveMovement;
    MulticastClient* multicastClient;
    int kHEIGHT;
    int kWIDTH;
    
    // Delete a piece (also called albumArt)
    UILongPressGestureRecognizer *holdRecognizer;
    NSString* albumToDelete;            // Name of the album to be deleted
    int numberOfPiecesWhenDeleting;     // this variable helps to keep track of how many pieces are there and if there is still something to delete
    BOOL inDeleteMode;
    
    NSTimer* albumViewTimer;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;


//Network

-(IBAction) current:(id) sender;
- (void) flip;
- (void) goToLiveTabbar;
- (void) createNewNavView;
- (void) deletePieces;
- (id)   initWithTitle:(NSString *) theTitle;
- (void) fadeTabBar;
- (BOOL) parseData:(NSData *)data1;
- (void) configureTracks:(NSMutableArray *) array piece:(MusicPiece *) piece;
- (void) createTrackButtons;


@property (assign) BOOL tabBarVisible;

@property (assign) int currentMeasureNumber;
@property (nonatomic, retain) NSTimer *myTimer;
@property NSMutableString *currentProperty;
@property (retain) Track *currentTrack;
@property (retain) DataPage *currentDataPage;
@property (retain) MusicPiece *currentMusicPiece;
@property (retain) NSMutableArray *thePieces;
@property (retain) NSMutableArray *trackButtonArray;
@property (retain) NSMutableDictionary * arrayOfTracks;
@property (retain) UITableView * tableView;
@property (retain) UITabBarController *trackTabBar;
@property (retain) UILabel *tabBarLabel;
@property (retain) NSData *receivedData;
//@property (retain) NSMutableArray *mapSegments;
@property (retain) UIBarButtonItem *goLiveButton;       // unused
@property (retain) UIBarButtonItem *goLiveButtonFromTable;
@property (retain) UIBarButtonItem *refreshButton;
@property (assign) int currentTrackIndex;
@property (retain) NSMutableArray* labelViewBarsArray;
@property (retain) NSMutableArray* theAlbumNamesFull;
@property (retain) NSMutableArray* liveLabelButtons;
@property (retain) NSMutableArray* deletePieceButtons;
@property (retain) NSMutableArray* pieceComposerLabels;
@property (retain) NSMutableArray* composersAlbumList;
@property (retain) NSMutableArray* piecesAlbumList;
@property (retain) NSMutableArray* piecesToBeDeleted;
@property (retain) NSMutableArray* theAlbumScrollViews;
//@property (retain) MulticastClient* multicastClient;
@end
