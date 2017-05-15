//
//  MapToolBar.h
//  Untitled
//
//  Created by Matthew Prockup on 2/15/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Track.h"
#import "constants.h"

@interface MapToolBar : UIView {
	NSMutableArray * boundaries;
	Track * track;
}

@property (nonatomic,retain) Track * track;

@end
