//
//  DataPage.h
//  Test1
//
//  Created by Matthew Prockup on 11/18/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
#import "SavedContentManager.h"
typedef enum {
	TEXT_ONLY, TEXT_AND_PICTURE, PICTURE_ONLY
} HTMLTemplate;

@interface DataPage : NSObject {

	int measure;
	NSString * text;
	double time;
	
	HTMLTemplate html;
	
	NSArray * images;
	NSMutableArray * imageDataPath;
	NSMutableArray * imageData;
	NSString * structure;
	BOOL hasImages;
    CGFloat imageWidth;
    CGFloat imageHeight;
	NSString * parentTrack;
}
- (NSString*) extractAndRemoveImageData:(NSString*) theText;
@property (nonatomic, assign) int measure;
@property (assign) double time;
@property (assign) HTMLTemplate html;
@property (assign) CGFloat imageWidth;
@property (assign) CGFloat imageHeight;
@property (assign) BOOL hasImages;

 
@property (retain) NSString * text;
@property (retain) NSString * structure;
@property (retain) NSString * parentTrack;
@property (assign) NSString * pieceName;

@property (retain) NSArray * images;
@property (retain) NSMutableArray * imageDataPath;
@property (retain) NSMutableArray * imageData;
@end
