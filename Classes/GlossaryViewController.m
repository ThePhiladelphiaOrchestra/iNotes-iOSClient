//
//  GlossaryViewController.m
//  Untitled
//
//  Created by Matthew Prockup on 2/2/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "GlossaryViewController.h"


@implementation GlossaryViewController

@synthesize dataSource1;

CGFloat kDefaultMenuWidth;
CGFloat kDefaultBarWidth = 10.0;

- (id) init
{
	self = [super init];
    
    kWIDTH = [DeviceProperties getDeviceResolutionLandscape].width;
    kHEIGHT = [DeviceProperties getDeviceResolutionLandscape].height;
    kDefaultMenuWidth =  kWIDTH/3;
    
    
	if (self != nil) {
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, kWIDTH,kHEIGHT)];
        
		view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.view = view;
		dataSource1 = [[GlossaryDataSource alloc] initWithXML:@"glossary"];
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDefaultMenuWidth,kHEIGHT-30) style:UITableViewStylePlain];
		
        // set the cell separator to a single straight line.
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		tableView.backgroundColor = [UIColor clearColor];

		// set the tableview delegate to this object and the datasource to the datasource which has already been set
		tableView.delegate = self;
		tableView.dataSource = dataSource1;
		
		tableView.sectionIndexMinimumDisplayRowCount = 2;
        
		glossaryView = [[GlossaryItemView alloc] initWithFrame:CGRectMake(0, 
																		  0, 
																		  kWIDTH - tableView.frame.size.width-10,
																		  1000)];
		
		// set the tableview as the controller view
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kDefaultMenuWidth + kDefaultBarWidth, 
																	0, 
																	kWIDTH - tableView.frame.size.width,
																	kHEIGHT-30)];
		scrollView.contentSize = glossaryView.frame.size;
		scrollView.backgroundColor = [UIColor clearColor];
		scrollView.autoresizesSubviews = YES;
		scrollView.delegate = self;
		scrollView.maximumZoomScale = 5.0;
		scrollView.minimumZoomScale = 0.5;
		scrollView.pagingEnabled = NO;
		[scrollView addSubview:glossaryView];
		
		CGSize dividerSize = CGSizeMake(10, kHEIGHT);
		UIImage * tempImage = [UIImage imageNamed:@"glossaryBack.png"];
		UIGraphicsBeginImageContext( dividerSize );// a CGSize that has the size you want
		[tempImage drawInRect:CGRectMake(0,0,dividerSize.width,dividerSize.height)];
		//image is the original UIImage
		dividerUnselectedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
        // I think that glossaryBack and glossaryBackSelected are the same and that glossaryBack is not being used
		tempImage = [UIImage imageNamed:@"glossaryBackSelected.png"];
		UIGraphicsBeginImageContext( dividerSize );// a CGSize that has the size you want
		[tempImage drawInRect:CGRectMake(0,0,dividerSize.width,dividerSize.height)];
		//image is the original UIImage
		dividerSelectedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		dividerBar = [[UIImageView alloc] initWithImage:dividerUnselectedImage];
		dividerBar.frame = CGRectMake(kDefaultMenuWidth, -6, dividerSize.width,dividerSize.height);
		dividerBar.userInteractionEnabled = YES;
		
        
        // Juliesays : "back" for "background"
		UIImageView * tableBack = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kWIDTH,kHEIGHT)];
		tableBack.image = GLOSSARY_BACKGROUND;
		
		[self.view addSubview:tableBack];
		[self.view addSubview:tableView];
		[self.view addSubview:scrollView];
		[self.view addSubview:dividerBar];
    }
	return self;
}




-(BOOL) goToPage:(NSString *)page{
	[tableView reloadData];
	
	NSIndexPath *scrollIndexPath;
	int row, section;
	BOOL foundPage = NO;
	
	NSMutableArray * names = dataSource1.categoryNames;
	for(NSString * c in names){
		NSMutableArray * category = [dataSource1.categories objectForKey:c];
		for(NSString * n in category){
			if([[((GlossaryItem* )n).name lowercaseString] isEqualToString:page]){
				row = [category indexOfObject:n];
				section = [names indexOfObject:c];
				foundPage = YES;
				break;
			}
		}
		
		if(foundPage)
			break;
	}
	
	if(foundPage){
		scrollIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
		[tableView selectRowAtIndexPath:scrollIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		[self tableView:tableView didSelectRowAtIndexPath:scrollIndexPath];
	}
	
	return foundPage;
}

BOOL touchedMarker1;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    startTouchPosition = [touch locationInView:self.view];
    touchedMarker1 = NO;
	if(CGRectContainsPoint(dividerBar.frame, startTouchPosition)){
		touchedMarker1 = YES;
		[dividerBar setImage: dividerSelectedImage];
	}
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
	if(touchedMarker1){
		dividerBar.center = CGPointMake(point.x, dividerBar.center.y);
		tableView.frame = CGRectMake(0, 0, dividerBar.frame.origin.x, tableView.frame.size.height);
		scrollView.frame = CGRectMake(dividerBar.frame.origin.x + kDefaultBarWidth, 0,  kWIDTH - (dividerBar.frame.origin.x + kDefaultBarWidth), scrollView.frame.size.height);
        [glossaryView setCustomFrame: CGRectMake(0, 0, kWIDTH-(dividerBar.frame.origin.x + kDefaultBarWidth)-10, glossaryView.frame.size.height)];
        scrollView.contentSize = glossaryView.frame.size;
        
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(touchedMarker1)
    {
        
        [glossaryView layoutSubviews];
        scrollView.contentSize = glossaryView.frame.size;
    }
    
    touchedMarker1 = NO;
	dividerBar.image = dividerUnselectedImage;
	
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// deselect the new row using animation
	NSString * section = [dataSource1.categoryNames objectAtIndex: indexPath.section];
	NSMutableArray * data = [dataSource1.categories objectForKey:section];
	
	
    [glossaryView setCustomFrame: CGRectMake(0, 0, kWIDTH-(dividerBar.frame.origin.x + kDefaultBarWidth)-10, glossaryView.frame.size.height)];
    glossaryView.glossaryItem = [data objectAtIndex:indexPath.row];
	scrollView.contentSize = glossaryView.frame.size;
    [scrollView setContentOffset:CGPointMake(0,0) animated:NO];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[tableView reloadData];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
