//
//  GlossaryDataSource.h
//  Untitled
//
//  Created by Matthew Prockup on 2/2/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlossaryTableViewCell.h"
#import "GlossaryItem.h"
#import "constants.h"
#import "NetworkCheck.h"

@interface GlossaryDataSource : NSObject<UITableViewDataSource,NSXMLParserDelegate> {

	NSMutableArray * glossaryData;
	NSMutableDictionary * categories;
	NSMutableArray * categoryNames;
	
	// For XML parsing
	GlossaryItem * currentItem;
	NSMutableString * currentProperty;

}
- (id) initWithXML:(NSString *) file;

@property (nonatomic, retain) GlossaryItem * currentItem;
@property (nonatomic, retain) NSMutableString * currentProperty;
@property (nonatomic, retain) NSMutableDictionary * categories;
@property (nonatomic, retain) NSMutableArray * categoryNames;
@property (nonatomic, retain) NSMutableArray * glossaryData;

@end
