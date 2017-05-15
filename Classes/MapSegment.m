//
//  MapSegment.m
//  iNotesMulti
//
//  Created by Matthew Prockup on 5/3/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//

#import "MapSegment.h"

@implementation MapSegment
-(int)getMeasureNum{
    return measureNumber;
}
-(NSString*)getTitle{
    return title;
}
-(void)setMeasureNum:(int) meas withTitle:(NSString*)tit{
    title = tit;
    measureNumber = meas;
}
@end
