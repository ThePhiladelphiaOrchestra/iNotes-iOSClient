//
//  PageView.h
//  Test1
//
//  Created by Matthew Prockup on 2/16/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "constants.h"
@interface PageView : UIView <UIWebViewDelegate> {
	UIWebView * webView;
}

@property (retain) UIWebView * webView;

@end
