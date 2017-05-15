//
//  MapToolBar.m
//  Untitled
//
//  Created by Matthew Prockup on 2/15/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "MapToolBar.h"
#import "Test1AppDelegate.h"

@implementation MapToolBar

Test1AppDelegate *appDelegate;

@synthesize track;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        boundaries = [[NSMutableArray alloc] init];
//		[boundaries addObject:[NSNumber numberWithFloat:30]];
//		[boundaries addObject:[NSNumber numberWithFloat:70]];
//		[boundaries addObject:[NSNumber numberWithFloat:230]];

		appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];


    }
    return self;
}

//-(void) setTrack:(Track *)track{
//	[self setNeedsDisplay];
//}

- (void) addBoundary:(float) n {
	[boundaries addObject:[NSNumber numberWithFloat:n]];
}


- (void)drawRect:(CGRect)rect {
	
	[super drawRect:rect];
	CGRect theRect;
	
	// Grab the drawing context
	CGContextRef context = UIGraphicsGetCurrentContext();
	//CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	
	float start, end;
	UIColor * color = [UIColor whiteColor];
	float * colors = (float*)CGColorGetComponents(color.CGColor);
	CGContextSetRGBFillColor(context, colors[0],  colors[1], colors[2], 1.0);
	CGContextSetRGBStrokeColor(context, colors[0],  colors[1], colors[2], 1.0);

    	
	if(boundaries){
	for(int i=0; i<[boundaries count]; i++){
		color = [Utility randomColor];
		float * colors = (float*)CGColorGetComponents(color.CGColor);
		CGContextSetRGBFillColor(context, colors[0],  colors[1], colors[2], 1.0);
		CGContextSetRGBStrokeColor(context, colors[0],  colors[1], colors[2], 1.0);
		
		if(i == 0){
			start = 0;
			end = [[boundaries objectAtIndex:0] floatValue];
		}
		else if(i < [boundaries count] ){
			start = [[boundaries objectAtIndex:(i-1)] floatValue];
			end = [[boundaries objectAtIndex:(i)] floatValue];

		}
		else {
			start = [[boundaries objectAtIndex:i] floatValue];
			end = self.frame.size.width;
		}
		theRect = CGRectMake(start, 0, end - start, self.frame.size.height);
		CGContextFillRect(context, theRect);
		CGContextStrokeRect(context, theRect);
	}
	
	start = [[boundaries objectAtIndex:([boundaries count]-1)] floatValue];
	end = self.frame.size.width;

	theRect = CGRectMake(start, 0, end - start, self.frame.size.height);
	color = [Utility randomColor];
	float * colors = (float*)CGColorGetComponents(color.CGColor);
	CGContextSetRGBFillColor(context, colors[0],  colors[1], colors[2], 1.0);
	CGContextSetRGBStrokeColor(context, colors[0],  colors[1], colors[2], 1.0);

	CGContextFillRect(context, theRect);
	CGContextStrokeRect(context, theRect);
	}
	else{
		start = 0;
		end = self.frame.size.width;
		
		theRect = CGRectMake(start, 0, end - start, self.frame.size.height);
		color = [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1.0];
		float * colors = (float*)CGColorGetComponents(color.CGColor);
		CGContextSetRGBFillColor(context, colors[0],  colors[1], colors[2], 1.0);
		CGContextSetRGBStrokeColor(context, colors[0],  colors[1], colors[2], 1.0);
		
		CGContextFillRect(context, theRect);
		CGContextStrokeRect(context, theRect);
		
		color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
		colors = (float*)CGColorGetComponents(color.CGColor);
		CGContextSetRGBFillColor(context, colors[0],  colors[1], colors[2], 1.0);
		CGContextSetRGBStrokeColor(context, colors[0],  colors[1], colors[2], 1.0);
		
		if(self.track){
			if(appDelegate.mode == LIVE_MODE){
				for(int i=0; i< [self.track.pages count]; i++){
					float start = self.frame.size.width*(float)((DataPage *)[self.track.pages objectAtIndex:i]).measure/(float)self.track.numMeasures;
					//theRect = CGRectMake(start, 0, 1, self.frame.size.height);
					CGContextMoveToPoint(context,start,0);
					CGContextAddLineToPoint(context,start,self.frame.size.height);
				}
				CGContextStrokePath(context);
			}
			else{
				for(int i=0; i< [self.track.pages count]; i++){
					float start = self.frame.size.width*(float)((DataPage *)[self.track.pages objectAtIndex:i]).time/(float)[appDelegate.player duration];
					//theRect = CGRectMake(start, 0, 3, self.frame.size.height);
					//CGContextFillRect(context, theRect);
					CGContextMoveToPoint(context,start,0);
					CGContextAddLineToPoint(context,start,self.frame.size.height);
				}
				CGContextStrokePath(context);

			}
		}
	}

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate.splashViewController.mainViewController fadeTabBar];
	
}

- (void)dealloc {
//    [super dealloc];
}


@end
