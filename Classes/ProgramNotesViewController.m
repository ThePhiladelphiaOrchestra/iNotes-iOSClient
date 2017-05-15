//
//  ProgramNotesViewController.m
//  Test1
//
//  Created by Matthew Prockup on 6/7/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "ProgramNotesViewController.h"


@implementation ProgramNotesViewController

@synthesize webView, pdfUrl;


- (id) init
{
	self = [super init];
	if (self != nil) {
        kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
        kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            appFrame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
        }
		UIView *view = [[UIView alloc] initWithFrame:appFrame];
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.view = view;
        
        NSString* path = @"http://www.google.com";
        NSURL* tempUrl = [[NSURL alloc] initWithString:path];
        self.pdfUrl = tempUrl;
        [self setPdfUrl:tempUrl];
        
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH,kHEIGHT-30)];
		webView.scalesPageToFit = YES;
		[self.view addSubview:webView];
        for (id subview in webView.subviews)
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
                ((UIScrollView *)subview).bounces = YES;
	}
	return self;
}

- (id) initWithSpace
{
    self = [super init];
	if (self != nil) {
        kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
        kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            appFrame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
        }
		UIView *view = [[UIView alloc] initWithFrame:appFrame];
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.view = view;
		      
        NSString* path = @"http://www.google.com";
        NSURL* tempUrl = [[NSURL alloc] initWithString:path];
        self.pdfUrl = tempUrl;
        [self setPdfUrl:tempUrl];
        
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30, kWIDTH,kHEIGHT-30)];
		webView.scalesPageToFit = YES;
		[self.view addSubview:webView];
        for (id subview in webView.subviews)
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
                ((UIScrollView *)subview).bounces = YES;
	}
	return self;
}

- (void) setPdfUrl:(NSURL *) url {
    [webView setBackgroundColor:[UIColor clearColor]];
	[webView loadRequest:[NSURLRequest requestWithURL:url]];
	
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


@end
