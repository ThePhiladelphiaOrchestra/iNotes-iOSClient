//
//  MapSegment.h
//  iNotesMulti
//
//  Created by Matthew Prockup on 5/3/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapSegment : NSObject
{
    int measureNumber;
    NSString* title;
}

-(int)getMeasureNum;
-(NSString*)getTitle;
-(void)setMeasureNum:(int) meas withTitle:(NSString*)tit;
@end
