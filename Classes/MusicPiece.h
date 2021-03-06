//
//  MusicPiece.h
//  Test1
//
//  Created by Matthew Prockup on 11/18/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataPage.h"
#import "Track.h"
#import "constants.h"
@interface MusicPiece : NSObject {

	NSMutableArray *tracks;
	int numMeasures;
	NSString * name;
	NSString * audio;

	UIImage * image;
	NSMutableArray * measureTable;
	
	NSMutableArray * structureArray;
}

-(void) addTrack:(Track *)track;

@property (retain) NSMutableArray *tracks;
@property (retain) NSMutableArray * measureTable;

@property (retain) NSMutableArray * structureArray;


@property (assign) int numMeasures;
@property (retain) NSString * name;
@property (retain) NSString * audio;

@property (retain) UIImage * image;




@end
