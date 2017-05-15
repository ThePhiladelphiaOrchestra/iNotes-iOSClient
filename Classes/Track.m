//
//  Track.m
//  Test1
//
//  Created by Matthew Prockup on 11/23/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "Track.h"

@implementation Track

@synthesize pages, name, numMeasures, pieceName, mapSegments;

- (id) init
{
	self = [super init];
	if (self != nil) {
		numMeasures = 0;
		name = nil;
		pieceName = nil;
		pages = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addDataPage:(DataPage *)page {
	[pages addObject:page];
}

-(DataPage *) pageWithMeasure:(int)m {
	for (int i=0; i<[pages count]; i++){
		if (((DataPage *)[pages objectAtIndex:i]).measure == m){
			// found a datapage with this measure
			return (DataPage *)[pages objectAtIndex:i];
		}
	}
	// didn't find a datapage
	return nil;
}

-(DataPage *) pageWithClosestTime:(double)time {
	if([pages count] > 0){
	double MIN_DIF = 999999;
	int index = 0;
	double dif = 0;
	for (int i=0; i<[pages count]; i++){
		dif = time - ((DataPage *)[pages objectAtIndex:i]).time;
		if (fabs( dif ) < MIN_DIF){
			MIN_DIF = dif;
			index = i;
		}
	}
	
	if(MIN_DIF >= 0 || index == 0)
		return (DataPage *)[pages objectAtIndex:index];
	else
		return (DataPage *)[pages objectAtIndex:(index - 1)];
	}
	else{
		return nil;
	}

}

-(DataPage *) pageWithLastTime:(double)time {
	int MIN_DIF = INT32_MAX;
	int index = 0;
	//DataPage * page;
	for (int i=0; i<[pages count]; i++){
		double dif = fabs( ((DataPage *)[pages objectAtIndex:i]).time - time );
		if (dif > 0 && dif < MIN_DIF){
			MIN_DIF = dif;
			index = i;
		}
		else{
			break;
		}
	}
	
	// didn't find a datapage
	return (DataPage *)[pages objectAtIndex:index];
}

-(DataPage *) firstPage {
	for (int i=0; i<[pages count]; i++){
		DataPage * tempPage = [self pageWithMeasure:i];
		if(tempPage)
			return tempPage;
	}
	// didn't find a datapage
	return nil;
}

-(DataPage *) pageWithLastAnnotation:(int) measure {
	
	if([pages count] != 0){
	for(int i=measure; i>=0; i--){
		DataPage* tempPage = [self pageWithMeasure:i];
		if(tempPage){
			return tempPage;
		}
	}
	
	return [pages objectAtIndex:0];
	}
	else
		return nil;
}

-(DataPage *) pageWithLastTextAnnotation:(float) time {
	
	int MIN_DIF = INT32_MAX;
	int index = 0;
	//DataPage * page;
	for (int i=0; i<[pages count]; i++){
		DataPage * d =  (DataPage *)[pages objectAtIndex:i];
		if(d.text && ![d.text isEqualToString:@""] && ![d.text isEqualToString:@"NaN"]){
		double dif = fabs(d.time - time );
		if (dif > 0 && dif < MIN_DIF){
			MIN_DIF = dif;
			index = i;
		}
		else{
			break;
		}
		}
	}
	
	// didn't find a datapage
	return (DataPage *)[pages objectAtIndex:index];
}


-(DataPage *) pageWithNextAnnotation:(int) measure {
	
	for(int i=measure; i<=numMeasures; i++){
		DataPage* tempPage = [self pageWithMeasure:i];
		if(tempPage){
			return tempPage;
		}
	}
	
	return [pages lastObject];
}

-(int) pagesWithAnnotations {
	int count = 0;
	for(int i=0; i<[pages count]; i++){
		DataPage* tempPage = [pages objectAtIndex:i];
		if(tempPage.text && ![tempPage.text isEqualToString:@"NaN"] && ![tempPage.text isEqualToString:@""]){
			count++;
		}
	}
	return count;
}

- (void) setMapInfo:(NSMutableArray*)segs{
    mapSegments = [[NSMutableArray alloc] initWithArray:segs];
}

@end
