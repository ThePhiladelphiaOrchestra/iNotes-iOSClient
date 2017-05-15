//
//  TrackControlView.m
//  Test1
//
//  Created by Matthew Prockup on 12/19/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "TrackControlView.h"


@implementation TrackControlView

CGFloat kViewWidth;
const CGFloat kViewHeight = 25;
const CGFloat kButtonWidth = 20;

+ (CGFloat)viewWidth
{
    return kViewWidth;
}

+ (CGFloat)viewHeight 
{
    return kViewHeight;
}

- (id)initWithFrame:(CGRect)frame
{
	// use predetermined frame size
	if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];	// make the background transparent
	}
    kViewWidth = [DeviceProperties getDeviceResolutionLandscape].width;
	return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed: @"glossaryBackSelected.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

}


@end
