//
//  PageViewController.m
//  Test1
//
//  Created by Matthew Prockup on 1/4/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "PageViewController.h"
#import "Test1AppDelegate.h"
#import "constants.h"
#import <QuartzCore/QuartzCore.h>

int MAX_IMAGE_WIDTH;
int MAX_IMAGE_HEIGHT;
#define IMAGE_PAD			5

const CGFloat TEXT_VIEW_PADDING = 10.0;

@implementation PageViewController

@synthesize didScroll,webView,pageIndex;

Test1AppDelegate *appDelegate;

- (id) initWithTrack:(Track *)track withReference:(id)ref
{
    navRef = ref;
    toolbarVisible = TRUE;
	self = [super init];
	if (self != nil) {
        
        kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
        kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
        MAX_IMAGE_WIDTH=		kWIDTH/3.0;
        MAX_IMAGE_HEIGHT =	kHEIGHT*0.6;
		appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
		
		trackData = track;
		
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        imageView = [[UIImageView alloc] initWithImage:MAIN_BACKGROUND];
        imageView.frame = CGRectMake(0, 0, appFrame.size.height, appFrame.size.width +10);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            appFrame = CGRectMake(0, 0, kWIDTH, kHEIGHT);
            imageView.frame = CGRectMake(0, 0, appFrame.size.width, appFrame.size.height +10);
        }
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH, kHEIGHT*.9)];
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.view = view;
		
		[self.view addSubview:imageView];
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH,kHEIGHT*.65)];
		webView.backgroundColor = [UIColor clearColor];
        for (id subview in webView.subviews)
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
                ((UIScrollView *)subview).bounces = YES;

		webView.opaque = NO;
		webView.userInteractionEnabled = YES;
		webView.delegate = self;
		[self.view addSubview:webView];

		progressInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0, 50, 50)];
		progressInd.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
		[progressInd startAnimating];
		progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		progressInd.backgroundColor = [UIColor clearColor];
		
		[self.view addSubview:progressInd];
		
		didScroll = FALSE;
	}
	return self;
}

-(NSInteger) getPageIndex {
	return pageIndex;
}

- (void)setDataPage:(DataPage *) page
{
    // Juliesays : seems unused, as none of those messages show up when running the App
    NSLog(@"We are in setDataPage, setting the data page for the webview");
    
		if(page){
			NSURL * fileURL;
			NSString * htmlString;
			NSString *path = [[NSBundle mainBundle] bundlePath];
			NSURL *baseURL = [NSURL fileURLWithPath:path];	
			NSString * formattedString;
			NSString * newString;
			
			switch (page.html) {
				case TEXT_AND_PICTURE:
					fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"template2" ofType:@"html"]];
					htmlString = [[NSString alloc] initWithContentsOfURL:fileURL usedEncoding:nil error:nil];
					
					newString =  [self insertHyperlinks:page.text];
					
					if(page.hasImages){
						
						CGFloat width = page.imageWidth;
						CGFloat height = page.imageHeight;;
						
						if(width > height){
							if(width > MAX_IMAGE_WIDTH){
								height = height*MAX_IMAGE_WIDTH/width;
								width = MAX_IMAGE_WIDTH;
							}
						}
						else{
							if(height > MAX_IMAGE_HEIGHT){
								width = width*MAX_IMAGE_HEIGHT/height;
								height = MAX_IMAGE_HEIGHT;
							}
						}
						
						CGFloat textX = IMAGE_PAD*2 + width;
						CGFloat textWidth = kWIDTH - textX;
						
                        
                        NSString * cap = @"";
                        if([page.images count] > 1){
                            cap = [page.images objectAtIndex:1];
                        }
                        
                        formattedString = [NSString stringWithFormat:htmlString, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_B, [page.imageDataPath objectAtIndex:0],(int)IMAGE_PAD, (int)width, (int)height, [page.imageDataPath objectAtIndex:0], SLIDE_FONT_FAMILY_A, SLIDE_TEXT_COLOR, (int)height + 48, (int)IMAGE_PAD, (int) width, cap, SLIDE_FONT_FAMILY_A,appDelegate.TEXT_SIZE, SLIDE_TEXT_COLOR, IMAGE_PAD, kWIDTH-100, newString];

                        NSLog(@"the new string after links added is : %@", newString);
					}
					else{
						
						formattedString = [NSString stringWithFormat:htmlString, (int)IMAGE_PAD, 50, 50, @"mozart.jpg", 100 , 200, newString];
					}
					[webView loadHTMLString:formattedString baseURL:baseURL];
					
					break;
				case TEXT_ONLY:
					fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"template1" ofType:@"html"]];
					htmlString = [[NSString alloc] initWithContentsOfURL:fileURL  usedEncoding:nil error:nil];
					
					newString =  [self insertHyperlinks:page.text];
					
					formattedString = [NSString stringWithFormat:htmlString, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_B, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_A, appDelegate.TEXT_SIZE, SLIDE_TEXT_COLOR,kWIDTH-100, newString];
					[webView loadHTMLString:formattedString baseURL:baseURL];
                    NSLog(@"the new string after links added is : %@", newString);
					break;
				case PICTURE_ONLY:
					
					fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"template3" ofType:@"html"]];
					htmlString = [[NSString alloc] initWithContentsOfURL:fileURL  usedEncoding:nil error:nil];
					
					if(page.hasImages){
						CGFloat width = page.imageWidth;
						CGFloat height = page.imageHeight;
						
						if(height > MAX_IMAGE_HEIGHT){
							width = width*MAX_IMAGE_HEIGHT/height;
							height = MAX_IMAGE_HEIGHT;
						}
						
						if(width > kWIDTH){
							height = height*kWIDTH/width;
							width = kWIDTH;
						}
						
						int left = (int)( (kWIDTH - width)/2.0 );
						
						formattedString = [NSString stringWithFormat:htmlString, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_B, [page.imageDataPath objectAtIndex:0] ,left, (int)width, (int)height, [page.images objectAtIndex:0], SLIDE_FONT_FAMILY_A, SLIDE_TEXT_COLOR, (int)height + 48, left, (int) width-50, [page.images objectAtIndex:1]];
					}
					else{
						
						formattedString = [NSString stringWithFormat:htmlString, (int)IMAGE_PAD, 50, 50, @"mozart.jpg", 100 , 200, newString];
					}
					[webView loadHTMLString:formattedString baseURL:baseURL];
					break;
			}
		}
}


- (void)setPageIndex:(NSInteger)newPageIndex
{
    
	pageIndex = newPageIndex;
	
	if (pageIndex >= 0 && pageIndex < [trackData.pages count])
	{
		DataPage * page = [trackData.pages objectAtIndex:pageIndex];
		if(page){
			NSURL * fileURL;
			NSString * htmlString;
			NSString *path = [[NSBundle mainBundle] bundlePath];
			NSURL *baseURL = [NSURL fileURLWithPath:path];	
			NSString * formattedString;
			NSString * newString;
			
			switch (page.html) {
				case TEXT_AND_PICTURE:
					fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"template2" ofType:@"html"]];
					htmlString = [[NSString alloc] initWithContentsOfURL:fileURL  usedEncoding:nil error:nil];
					
                    
					newString =  [self insertHyperlinks:page.text];
					
					if(page.hasImages){

						CGFloat width = page.imageWidth;
						CGFloat height = page.imageHeight;

						if(width > height){
							if(width > MAX_IMAGE_WIDTH){
								height = height*MAX_IMAGE_WIDTH/width;
								width = MAX_IMAGE_WIDTH;
							}
						}
						else{
							if(height > MAX_IMAGE_HEIGHT){
								width = width*MAX_IMAGE_HEIGHT/height;
								height = MAX_IMAGE_HEIGHT;
							}
						}
						
						NSString * cap = @"";
						if([page.images count] > 1){
							cap = [page.images objectAtIndex:1];
						}

                        
                        formattedString = [NSString stringWithFormat:htmlString, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_B, [page.imageDataPath objectAtIndex:0],(int)IMAGE_PAD, (int)width, (int)height, [page.imageDataPath objectAtIndex:0], SLIDE_FONT_FAMILY_A, SLIDE_TEXT_COLOR, (int)height + 48, (int)IMAGE_PAD, (int) width, cap, SLIDE_FONT_FAMILY_A,appDelegate.TEXT_SIZE, SLIDE_TEXT_COLOR, IMAGE_PAD, kWIDTH-100, newString];

					}
					else{

						formattedString = [NSString stringWithFormat:htmlString, (int)IMAGE_PAD, 50, 50, @"mozart.jpg", 100 , 200, newString];
					}
                    
#ifdef TEXT_REPLACE
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ˆ" withString:@"&#246;"];//small o, umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"‰" withString:@"&#228;"];//small a, umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"¸" withString:@"&#252;"];//small u, umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"Ú" withString:@"&#242;"];//small letter o with grave
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ƒ" withString:@"&#196;"];//capital letter A umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"È" withString:@"&#233;"];//small letter e with accent
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"÷" withString:@"&#214;"];//capital letter O umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"‹" withString:@"&#220;"];//capital letter U umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ﬂ" withString:@"&#223;"];//capital letter ß
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"∞" withString:@"&#176;"];//degree symbol
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ì" withString:@"&#147;"];//left quote
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"î" withString:@"&#148;"];//right quote
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"Ñ" withString:@"&#132;"];//bottom quote
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ñ" withString:@"-"];//dash
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"Ö" withString:@"..."];//elipses ... mark
#endif
                    [webView loadHTMLString:formattedString baseURL:baseURL];
					
					break;
				case TEXT_ONLY:
					fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"template1" ofType:@"html"]];
					htmlString = [[NSString alloc] initWithContentsOfURL:fileURL  usedEncoding:nil error:nil];
					
					newString =  [self insertHyperlinks:page.text];

					formattedString = [NSString stringWithFormat:htmlString, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_B, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_A, appDelegate.TEXT_SIZE, SLIDE_TEXT_COLOR,kWIDTH-100, newString];;
#ifdef TEXT_REPLACE

                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ˆ" withString:@"&#246;"];//small o, umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"‰" withString:@"&#228;"];//small a, umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"¸" withString:@"&#252;"];//small u, umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"Ú" withString:@"&#242;"];//small letter o with grave
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ƒ" withString:@"&#196;"];//capital letter A umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"È" withString:@"&#233;"];//small letter e with accent
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"÷" withString:@"&#214;"];//capital letter O umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"‹" withString:@"&#220;"];//capital letter U umlaut mark
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ﬂ" withString:@"&#223;"];//capital letter ß
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"∞" withString:@"&#176;"];//degree symbol
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ì" withString:@"&#147;"];//left quote
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"î" withString:@"&#148;"];//right quote
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"Ñ" withString:@"&#132;"];//bottom quote
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"ñ" withString:@"-"];//dash
                    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"Ö" withString:@"..."];//elipses ... mark
#endif
                    [webView loadHTMLString:formattedString baseURL:baseURL];
					break;
				case PICTURE_ONLY:
					
					fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"template3" ofType:@"html"]];
					htmlString = [[NSString alloc] initWithContentsOfURL:fileURL  usedEncoding:nil error:nil];
										
					if(page.hasImages){
						CGFloat width = page.imageWidth;
						CGFloat height = page.imageHeight;
						
						if(height > MAX_IMAGE_HEIGHT){
							width = width*MAX_IMAGE_HEIGHT/height;
							height = MAX_IMAGE_HEIGHT;
						}
						
						if(width > kWIDTH){
							height = height*kWIDTH/width;
							width = kWIDTH;
						}
						
						int left = (int)( (kWIDTH - width)/2.0 );
						
						formattedString = [NSString stringWithFormat:htmlString, SLIDE_FONT_FAMILY_A, SLIDE_FONT_FAMILY_B, [page.imageDataPath objectAtIndex:0] ,left, (int)width, (int)height, [page.images objectAtIndex:0], SLIDE_FONT_FAMILY_A, SLIDE_TEXT_COLOR, (int)height + 48, left, (int) width-50, [page.images objectAtIndex:1]];
					}
					else{
						formattedString = [NSString stringWithFormat:htmlString, (int)IMAGE_PAD, 50, 50, @"mozart.jpg", 100 , 200, newString];
					}
					[webView loadHTMLString:formattedString baseURL:baseURL];
					break;
			}
		}
		

		CGRect absoluteRect = [self.view.window
							   convertRect:webView.bounds
							   fromView:webView];
		if (!self.view.window ||
			!CGRectIntersectsRect(
								  CGRectInset(absoluteRect, TEXT_VIEW_PADDING, TEXT_VIEW_PADDING),
								  [self.view.window bounds]))
		{
			textViewNeedsUpdate = YES;
		}
	}
}

- (NSString *) insertHyperlinks:(NSString *) input {
    
    // This is where we seek for words that are in the glossary and add links to them so that when tapped, they can send the user to the gloassary at the correct page. You can uncomment the NSLogs for testing

    
    // temp will be modified several times and finally returned as formattedstring
    NSString *temp;
    NSString *formattedString = [[NSString alloc] initWithString:input];
    
    /*------------------------*/
    /* HYPERLINKS TO WEBSITES */
    /*------------------------*/
    
    // Hyperlinks formatting to go to websites
    NSString * linkWebsite = [NSString stringWithFormat: @"<a style=\"color: %@\" %@",SLIDE_LINK_TEXT_COLOR, @"href=\"websiteis:%@\">%@</a>"];
    
    // Check if we find urls in our text
    NSDataDetector  *linkDetector  = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray         *allUrlsInText = [linkDetector matchesInString:input options:0 range:NSMakeRange(0, [input length])];
    
    // Get rid of doublons (so that you don't put a link into another link)
    NSCountedSet   *countedSet       = [NSCountedSet setWithArray:allUrlsInText ];
    NSMutableArray *usefulURLsInText = [NSMutableArray arrayWithCapacity:[allUrlsInText  count]];
    for(id obj in countedSet) {
        if([countedSet countForObject:obj] == 1) {
            [usefulURLsInText addObject:obj];
        }
    }
    
    
    for (NSTextCheckingResult *match in usefulURLsInText) {
        // now replace the text with hyperlink
        
        NSLog(@"working on the url : %@", match);
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            NSString *urlStringWithSpace = [[url absoluteString] stringByAppendingFormat:@" "]; // enables to differenciate things like http://www.yoursite.org/ and http://www.yoursite.org/iNotes/
            NSString *urlStringWithDot = [[url absoluteString] stringByAppendingFormat:@"."];
            
            NSArray *arrayToFormatURL = [[url absoluteString] componentsSeparatedByString:@"://"]; // format for dislay on the slide without http://

            // the url is followed either by a @" " or a @".", we do the operation for those two different situations
            formattedString = [formattedString stringByReplacingOccurrencesOfString:urlStringWithSpace  withString:[NSString stringWithFormat:linkWebsite, [url absoluteString],[[arrayToFormatURL objectAtIndex:1] stringByAppendingFormat:@" "]  ]];
            formattedString = [formattedString stringByReplacingOccurrencesOfString:urlStringWithDot  withString:[NSString stringWithFormat:linkWebsite, [url absoluteString],[[arrayToFormatURL objectAtIndex:1] stringByAppendingFormat:@"."] ]];
        }
    }
    
    /*-------------------*/
    /* LINKS TO GLOSSARY */
    /*-------------------*/
    
	NSString * link = [NSString stringWithFormat:@"<a style=\"color: %@\" %@",SLIDE_LINK_TEXT_COLOR,@"href=\"%@\">%@</a>"];
	NSMutableArray * tags = appDelegate.glossary.dataSource1.glossaryData;
    
    // replace all occurences of glossary items with
	for(int i =0; i< [tags count]; i++){
        
		GlossaryItem * item = [tags objectAtIndex:i];
		NSString * thisTag = [item.name lowercaseString];
		
		temp = [formattedString stringByReplacingOccurrencesOfString:thisTag withString:[NSString stringWithFormat:link, thisTag, thisTag]];
		formattedString = temp;
	}
	
	return formattedString;
}

- (void)updateTextViews:(BOOL)force
{
	if (force ||
		(textViewNeedsUpdate &&
		 self.view.window &&
		 CGRectIntersectsRect(
							  [self.view.window
							   convertRect:CGRectInset(webView.bounds, TEXT_VIEW_PADDING, TEXT_VIEW_PADDING)
							   fromView:webView],
							  [self.view.window bounds])))
	{
		for (UIView *childView in self.view.subviews)
		{
			[childView setNeedsDisplay];
		}
		textViewNeedsUpdate = NO;
	}
}





// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
}

-(void) tappedView {
	Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.splashViewController.mainViewController fadeTabBar];	

}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Touching is Happening");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.splashViewController.mainViewController fadeTabBar];
	
}

- (BOOL)webView:(UIWebView*)webView1 shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSString *path = [[request URL] path];
    NSString *url = [[request URL] absoluteString];
    NSLog(@"webview, URL of request is %@", url);
	NSString * linkText;
    
    // format the linkText for different cases
    if ([url rangeOfString:@"http"].location != NSNotFound) { // in case it is a link to a website, keep the URL
        linkText = url;
    }else{
        linkText = [path lastPathComponent]; // otherwisem you only want the last word
    }
	 
	NSLog(@"webView, linkText of request is %@",linkText);
	
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
            //[self hideToolbar];
			break;
	}
	
	if(navigationType == UIWebViewNavigationTypeLinkClicked){
		NSLog(@"Link clicked: %@ \n", linkText);
		
		// Find out the nature of the tap
		if ([linkText rangeOfString:@"."].location != NSNotFound && [linkText rangeOfString:@"http"].location == NSNotFound)
        {
            // Scenario 1 : the user tapped on a picture
            
            NSLog(@"Picture Clicked");
            return NO;
        }
        else if ([linkText rangeOfString:@"http"].location != NSNotFound || [linkText rangeOfString:@"/"].location != NSNotFound)
        {
            // Scenario 2 : the item tapped was a website name
            NSLog(@"We found a word with http in there ! ");
            
            NSArray *arrayToGetURL = [linkText componentsSeparatedByString:@"siteis:"];
      
            NSLog(@"The website is : %@", [arrayToGetURL objectAtIndex:1]);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[arrayToGetURL objectAtIndex:1]]];
            // still need to find a way to not show the page in iNotes in the webview
        }
        else
        {
            
            // Scenario 3 : the item tapped is an item of the glossary
            NSLog(@"We are going in the glossary to check that definition ");
            
            Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
            GlossaryViewController * glossary = appDelegate.glossary;
            glossary.navigationItem.title = @"Glossary";
            [glossary goToPage:linkText];
            [appDelegate.splashViewController.mainViewController.navigationController pushViewController:glossary animated:YES];
        }
		return YES;
	}
	else{
		return YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView1 {
	[progressInd removeFromSuperview];
}

- (void)webView:(UIWebView *)webView1 didFailLoadWithError:(NSError *)error {

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


-(void) hideToolbar {
	
    
}


- (void)dealloc {
}

-(void)addImage:(NSString*)fileJawn
{
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 50, 250, 350)]; //create appropriate frame
    imgView.image = [UIImage imageNamed:fileJawn];
    imgView.contentMode = UIViewContentModeCenter;
    [webView addSubview:imgView];
}

- (void)closeivTapped:(id)sender
{
    [imgView removeFromSuperview];
    [closeimgView removeFromSuperview];
}


@end
