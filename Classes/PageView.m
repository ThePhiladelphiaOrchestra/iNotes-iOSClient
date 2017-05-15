//
//  PageView.m
//  Test1
//
//  Created by Matthew Prockup on 2/16/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "PageView.h"
#import "Test1AppDelegate.h"


@implementation PageView

@synthesize webView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		webView = [[UIWebView alloc] initWithFrame:frame];
		webView.backgroundColor = [UIColor clearColor];
		//webView.contentStretch = frame;
		webView.opaque = NO;
		webView.userInteractionEnabled = YES;
		webView.delegate = self;

        
        
        
        
		[self addSubview:webView];
    }
    return self;
}



- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
//    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	printf("Touches Began in PageView\n");
	//[webView touchesEnded:touches withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"Hit Test");
    [webView hitTest:point withEvent:event];
    return self;
}

- (void)viewDidLoad
{
    
}


- (BOOL)webView:(UIWebView*)webView1 shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
    
    // Julie says : seems unused as none of those NSLOG messages show up
    
	NSString *path = [[request URL] path];
	NSLog(@"%@",path);
	
	NSString * linkText = [path lastPathComponent];
	NSLog(@"%@",linkText);
	
	switch (navigationType) {
		case UIWebViewNavigationTypeLinkClicked:
			printf("UIWebViewNavigationTypeLinkClicked");
			break;
		case UIWebViewNavigationTypeFormSubmitted:
			printf("UIWebViewNavigationTypeFormSubmitted");
			break;
		case UIWebViewNavigationTypeBackForward:
			printf("UIWebViewNavigationTypeBackForward");
			break;
		case UIWebViewNavigationTypeFormResubmitted:
			printf("UIWebViewNavigationTypeFormResubmitted");
			break;
		case UIWebViewNavigationTypeReload:
			printf("UIWebViewNavigationTypeReload");
			break;
		case UIWebViewNavigationTypeOther:
			printf("UIWebViewNavigationTypeOther");
			break;
	}
    
	
	if(navigationType == UIWebViewNavigationTypeLinkClicked){
		NSLog(@"Link clicked: %@ \n", linkText);
		
		// Find out the nature of the tap
		if ([linkText rangeOfString:@"."].location != NSNotFound && [linkText rangeOfString:@"http"].location == NSNotFound)
        {
            // Scenario 1 : the user tapped on a picture
            
            NSLog(@"Picture Clicked");
            // [self performSelectorOnMainThread:@selector(addImage:) withObject:linkText waitUntilDone:YES];
            //            closeimgView = [[UIImageView alloc] initWithFrame:CGRectMake(275, 45, 25, 25)]; //create appropriate frame
            //            closeimgView.image = [UIImage imageNamed:@"close_btn.png"];
            //            closeimgView.userInteractionEnabled =YES;
            //            closeimgView.contentMode = UIViewContentModeCenter;
            //            [webView.superview addSubview:closeimgView];
            //
            //            UITapGestureRecognizer* closeivGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeivTapped:)];
            //
            //            [closeimgView addGestureRecognizer:closeivGesture];
            return NO;
        }
        else if ([linkText rangeOfString:@"http"].location != NSNotFound || [linkText rangeOfString:@"/"].location != NSNotFound)
        {
            // Scenario 2 : the item tapped was a website name
            NSLog(@"We found a word with http in there ! ");
            
            NSArray *arrayToGetURL = [linkText componentsSeparatedByString:@"siteis:"];
            NSLog(@"The website is : %@", [arrayToGetURL objectAtIndex:1]);
            
            // Go to the website in Safari
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[arrayToGetURL objectAtIndex:1]]];

        }
        else
        {
            
            // Scenario 3 : the item tapped is an item of the glossary
            NSLog(@"We are going in the glossary to check that definition ");
            
            Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
            GlossaryViewController * glossary = appDelegate.glossary;
            glossary.navigationItem.title = @"Glossary";
            //		UIImageView * t = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play.png"]];
            //		UIBarButtonItem *connectedItem = [[UIBarButtonItem alloc] initWithCustomView:t];
            //		[glossary.navigationItem setRightBarButtonItem:connectedItem];
            [glossary goToPage:linkText];
            
            //[appDelegate.splashViewController.mainViewController fadeTabBar];
            
            //[appDelegate.splashViewController.mainViewController performSelectorOnMainThread:@selector(push:) withObject:glossary waitUntilDone:YES];
            
            [appDelegate.splashViewController.mainViewController.navigationController pushViewController:glossary animated:YES];
            
            //[(UINavigationController *)[appDelegate.splashViewController.mainViewController.trackTabBar selectedViewController] pushViewController:glossary animated:YES];
            
        }
        
        
		//[self presentModalViewController:glossary animated:YES];
		return YES;
	}
	else{
		return YES;
	}
    
}





@end
