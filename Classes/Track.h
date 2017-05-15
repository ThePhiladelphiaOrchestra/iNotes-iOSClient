//
//  Track.h
//  Test1
//
//  Created by Matthew Prockup on 11/23/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataPage.h"
#import "constants.h"
#import "MapSegment.h"
@interface Track : NSObject {

	NSMutableArray *pages;
	NSString * name;
	
	NSString * pieceName;
    NSMutableArray* mapSegments;
	int numMeasures;
	
}

@property (retain) NSMutableArray *pages;
@property (retain) NSMutableArray* mapSegments;
@property (retain) NSString * name;
@property (retain) NSString * pieceName;

@property (assign) int numMeasures;


- (void)addDataPage:(DataPage *)page;
- (DataPage *) pageWithMeasure:(int) m;
- (void) setMapInfo:(NSMutableArray*)segs;
-(DataPage *) pageWithLastAnnotation:(int) measure;
-(DataPage *) pageWithLastTime:(double)time ;
-(DataPage *) pageWithClosestTime:(double)time;

@end
