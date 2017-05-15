//
//  MapViewController.h
//  MapDemo
//
//  Created by Administrator on 4/5/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "Utility.h"
#import "MapView.h"
#import "MapScrollView.h"
#import "MarkerView.h"
#import "Matrix.h"
#import "PageViewTemp.h"
#import "PathView.h"
#import "CursorView.h"
#import "BulletView.h"
#import "MusicPiece.h"
#import "BackgroundView.h"

typedef enum {
	MAP, PLAY
} MapMode;

@interface MapViewController : UIViewController <UIScrollViewDelegate, UITabBarDelegate> {
	MapScrollView * scrollView;
	UIView * mapBackground;
	UITabBar * bottomBar;
	NSMutableArray * pinArray;
	NSMutableArray * pathArray;
	
	MusicPiece * dataArray;
	
	PathView * path;
	
	NSTimer * myTimer;
	
	UILabel * timeLabel;
	
	MapMode mode;
	
	BackgroundView * backgroundView;
}

@property (nonatomic, retain) MusicPiece * dataArray;
@property (nonatomic, assign) MapMode mode;
@end
