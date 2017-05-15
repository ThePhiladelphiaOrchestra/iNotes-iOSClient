//
//  NavigationViewController.h
//  Test1
//
//  Created by Matthew Prockup on 11/17/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CGColor.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <QuartzCore/CAAnimation.h>

#import "Track.h"
#import "MusicPiece.h"
#import "PageViewController.h"
#import "MapToolBar.h"
#import "ProgramNotesViewController.h"
#import "constants.h"
#import "AnnotationMarkerBarView.h"
#import "MapSegment.h"
#import "UITaggedButton.h"
#import "DeviceProperties.h"

#define HORIZ_SWIPE_DRAG_MIN  12
#define VERT_SWIPE_DRAG_MAX    4

#define HORIZ_SWIPE_DRAG_MAX   4
#define VERT_SWIPE_DRAG_MIN   12



@interface NavigationViewController : UIViewController <UIScrollViewDelegate> {

    
    int kWIDTH;
    int kHEIGHT;
    
    int BUTTON_Y1;
    int BUTTON_Y2;
    int BUTTON_Y3;
    int BUTTON_Y4;
    int BUTTON_Y5;
    
    int BUTTON_SIZE;
    
	NSMutableArray * pageViewControllerArray;
	UIScrollView *scrollView;
	UIPageControl *pageControl;
	
	PageViewController * previousPage;
	PageViewController *currentPage;
	PageViewController *nextPage;
	
	
	UITabBar *tabBar;	
	UIImageView *imageView;
	UIImageView *pointerImageView;

	CGPoint startTouchPosition;
	UILabel * measureLabel;
	UILabel * slideLabel;
	UIButton * stopBlinkingButton;
	UITextView *textView;
	
	UIImageView * leftArrow;
	UIImageView * rightArrow;

	UIImageView * measureMarkerImageView;
	
	int pagePosistion;

	NSTimer * myTimer;
	UIButton  * liveButton;
	
	Track * trackData;
	
	UISlider * slider;
	//UITableView * trackSelector;
	BOOL animating;
	BOOL userInterjected;

	NSTimer * timer;
	
	UILabel * sliderMarkerText;
	UILabel * pointerText;
	
    BOOL pageControlIsChangingPage;

	MapToolBar * toolBar;
    AnnotationMarkerBarView* annotationMarkerBar;
	BOOL contentLoaded;
	
	BOOL loadedTickmarkers;
    ProgramNotesViewController* programNotes;
    UIImageView *appInstr;
    
    UITaggedButton * commentaryButton;
    UITaggedButton * brightButton;
    UITaggedButton * textSizeButton;
    UITaggedButton * helpButton;
    UITaggedButton * favoriteButton;
    UIImageView* trackSelectPointer;
    UIBarButtonItem* goLiveButton;
    UILabel* slidePosLabel;
    MusicPiece* piece;
    int cntGoLive;
    BOOL mapExpanded;
    BOOL choosingTrack;
    
    UIScrollView* trackButtonScrollView;
    BOOL tabsPresent;

}
-(void)addAView:(UIView*)view;
-(void)addUIComponents:(Track*)track;
-(void)goToPage:(NSInteger) measure animated:(BOOL) animated;
-(void)addMapColors:(Track*)structureTrack;
-(void)goLive;
-(void) startTimer;
-(void) stopTimer;
- (id) initWithTrack:(Track *)track;
@property (nonatomic, retain) NSTimer *myTimer;
@property (assign) int pagePosistion;
@property (nonatomic, retain) Track * trackData;
//@property (nonatomic, retain) UITableView * trackSelector;
@property (nonatomic, retain) AnnotationMarkerBarView* annotationMarkerBar;
@property (retain) UIBarButtonItem* goLiveButton;
@property (retain) UILabel* slidePosLabel;
@property (assign) BOOL contentLoaded;

@end
