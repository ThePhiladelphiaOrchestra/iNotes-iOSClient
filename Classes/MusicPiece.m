//
//  MusicPiece.m
//  Test1
//
//  Created by Matthew Prockup on 11/18/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "MusicPiece.h"

@implementation MusicPiece

@synthesize tracks, numMeasures, name, image, audio, measureTable, structureArray;

- (id) init
{
	self = [super init];
	if (self != nil) {
		numMeasures = 0;
		name = nil;
		tracks = [[NSMutableArray alloc] init];
		measureTable = [[NSMutableArray alloc] init];	
		structureArray = [[NSMutableArray alloc] init];

	}
	return self;
}

-(NSNumber *) getClosestTimeToMeasure:(int) m {
	if(measureTable){
		if(m > [measureTable count]){
			return ((NSNumber *)[measureTable objectAtIndex:[measureTable count] -1]) ;
		}
		else{
			return ((NSNumber *)[measureTable objectAtIndex:m-1]);
		}
	}
	else{
		return nil;
	}
}

- (Track *) trackWithName:(NSString *) n {
	for(Track * t in self.tracks){
		if([t.name isEqualToString:n])
			return t;
	}
	return nil;
}

-(void) addMeasure:(DataPage *) d {
	
	if(d.measure > [measureTable count]){
		[measureTable addObject:[NSNumber numberWithDouble:d.time]];
	}
	
}

-(void) addTrack:(Track *)track {
	[tracks addObject:track];
}

-(DataPage *) getDataPage:(int)trackNumber :(int)measureNumber{
	Track * thisTrack = [tracks objectAtIndex:trackNumber];
	return [thisTrack pageWithLastAnnotation:measureNumber];
}

@end
