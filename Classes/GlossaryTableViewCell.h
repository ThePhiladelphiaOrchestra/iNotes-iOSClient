//
//  GlossaryTableViewCell.h
//  Untitled
//
//  Created by Matthew Prockup on 2/2/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlossaryItem.h"
#import "constants.h"

@interface GlossaryTableViewCell : UITableViewCell {
	UILabel * label;
	GlossaryItem * glossaryItem;
}

@property (nonatomic, retain) GlossaryItem * glossaryItem;

@end
