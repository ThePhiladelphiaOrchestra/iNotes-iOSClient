//
//  GlossaryItem.h
//  Untitled
//
//  Created by Matthew Prockup on 2/8/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"


@interface GlossaryItem : NSObject {
	NSString * category;
	NSString * name;
	NSString * description;
	NSString * history;
}

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSString * history;

@end
