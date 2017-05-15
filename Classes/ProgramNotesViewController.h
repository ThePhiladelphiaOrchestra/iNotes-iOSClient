//
//  ProgramNotesViewController.h
//  Test1
//
//  Created by Matthew Prockup on 6/7/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"
#import "DeviceProperties.h"

@interface ProgramNotesViewController : UIViewController {

	UIWebView	*webView;
	NSURL	*pdfUrl;
    int kWIDTH;
    int kHEIGHT;
}
- (id) initWithSpace;
@property (nonatomic, retain)  UIWebView	*webView;
@property (nonatomic, retain) NSURL			*pdfUrl;

@end
