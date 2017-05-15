//
//  GlossaryViewController.h
//  Untitled
//
//  Created by Matthew Prockup on 2/2/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlossaryDataSource.h"
#import "GlossaryItemView.h"
#import "constants.h"
#import "DeviceProperties.h"

@interface GlossaryViewController : UIViewController <UITableViewDelegate> {
	UITableView *tableView;
	GlossaryDataSource * dataSource1;
	
	GlossaryItemView * glossaryView;
	
	UIScrollView * scrollView;
	
	UIImageView * dividerBar;
	UIImage * dividerUnselectedImage;
	UIImage * dividerSelectedImage;

	CGPoint startTouchPosition;
    int kWIDTH;
    int kHEIGHT;
}
-(BOOL) goToPage:(NSString *)page;
@property (nonatomic, retain) GlossaryDataSource * dataSource1;
@end
