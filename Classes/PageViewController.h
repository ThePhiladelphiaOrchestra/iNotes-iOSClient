//
//  PageViewController.h
//  Test1
//
//  Created by Matthew Prockup on 1/4/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"
#import "DataPage.h"
#import "GlossaryViewController.h"
#import "PageView.h"
#import "constants.h"
#import "DeviceProperties.h"

@interface PageViewController : UIViewController <UIWebViewDelegate>
{
    int kWIDTH;
    int kHEIGHT;
	//NSInteger pageIndex;
	BOOL textViewNeedsUpdate;

	UIImageView *imageView;
	UILabel * measureLabel;
	UILabel * timeLabel;

	UITextView *textView;
    id navRef;
	Track * trackData;
	BOOL didScroll;

	NSMutableArray * dataPages;
	
	UIWebView * webView;
	GlossaryViewController * tempGloss;
	

	
	PageView * pageView;
	

	UIActivityIndicatorView * progressInd;
    BOOL toolbarVisible;
        UIImageView *imgView;
        UIImageView *closeimgView;
   
}
@property (retain) UIWebView* webView;
@property (assign,nonatomic) NSInteger pageIndex;
@property (assign) BOOL didScroll;
-(void)addImage:(NSString*)fileJawn;
- (id) initWithTrack:(Track *)track withReference:(id)ref;
- (void)updateTextViews:(BOOL)force;

@end