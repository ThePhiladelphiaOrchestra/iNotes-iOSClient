//
//  AnnotationMarkerBarView.h
//  iNotesMulti
//
//  Created by Matthew Prockup on 5/2/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Track.h"
#import "constants.h"
#import "MapSegment.h"
//#import "Test1AppDelegate.h"
@interface AnnotationMarkerBarView : UIView
{
    NSMutableArray * boundaries;
    Track * track;
    Track * waveTrack;
    UIImageView* barView;
    NSMutableArray* mapViews;
    NSMutableArray* waveViews;
    NSMutableArray* mapLabels;
    
}
-(void)addMarkers: (Track*) tempTrack;
-(void)addWaveform: (Track*) tempTrack;
-(void) drawMapSegments:(Track*)mapTrack;

-(void)updateBarView:(int)measure;
-(void) expandView;
-(void) collapseView;
@property (nonatomic,retain) Track * track;
@property (nonatomic,retain) Track * waveTrack;
@property (nonatomic,retain) UIImageView* barView;
@end

