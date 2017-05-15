//
//  GlossaryItemView.h
//  Untitled
//
//  Created by Matthew Prockup on 2/8/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlossaryItem.h"
#import "constants.h"

@interface GlossaryItemView : UIView {
	UILabel * title;
	
	UITextView * description;
    UILabel * descriptionLabel;
	UITextView * history;
	
	GlossaryItem * glossaryItem;        // seems unused
	UIImageView * backGroundImageView;
	UILabel * historyLabel;
	
}
- (void) setCustomFrame:(CGRect)frame;
@property (nonatomic, retain) GlossaryItem * glossaryItem;

@end
