//
//  GlossaryDataSource.m
//  Untitled
//
//  Created by Matthew Prockup on 2/2/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "GlossaryDataSource.h"


@implementation GlossaryDataSource

@synthesize currentProperty, currentItem, categories, categoryNames, glossaryData;

- (id) initWithXML:(NSString *) file {
	if(self = [super init]){
        
        
        NSString* xmlString;
        if(([NetworkCheck whatIsMyConnectionType] == 0)||([NetworkCheck whatIsMyConnectionType] == 2) || ![[NetworkCheck whatIsMySSID] isEqualToString:SSID]) // No Internet or 3G
        {
            NSLog(@"Using Built-in Glossary");
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:file ofType:@"xml"]];
            xmlString = [[NSString alloc] initWithContentsOfURL:fileURL  usedEncoding:nil error:nil];
            NSLog(@"...Loaded.");
        }
        else
        {
            NSLog(@"Using Network Glossary");
            // Gets the path of the folder where the images are on the server
            NSString* tempStr = IMAGE_SERVER;
            NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"%@glossary.xml", tempStr];
            // It's not an image, it's an .xml file
            NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
                                                                      
            NSLog(@"%@",tempImageStrUrl);
            
            NSURL *url = [NSURL URLWithString:tempImageStrUrl];
            
            xmlString = [[NSString alloc] initWithContentsOfURL:url  usedEncoding:nil error:nil];
            NSLog(@"...Loaded.");
            
        }
		
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
//        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[xmlString dataUsingEncoding:NSISOLatin1StringEncoding]];
		glossaryData  = [[NSMutableArray alloc] init];
		categories    = [[NSMutableDictionary alloc] init];
		categoryNames = [[NSMutableArray alloc] init];
		
		[parser setDelegate:self]; // The parser calls methods in this class
		[parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
		[parser setShouldReportNamespacePrefixes:NO]; //
		[parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
		
		[parser parse]; // Parse that data..
		
		//DataPage * thisPage = [((MusicPiece *)[thePieces objectAtIndex:0]) pageWithMeasure:3];
		//NSLog(@"%@",[parser parseError]);
		if ([parser parserError]) {
            NSLog(@"Parsing error in the Glossary");
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark XML parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (qName) {
        elementName = qName;
    }
	
    if (self.currentItem) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"description"] || [elementName isEqualToString:@"history"]) {
            self.currentProperty = [NSMutableString string];
        } 
		

    } 
	else {
		if ([elementName isEqualToString:@"item"]) {
			
			self.currentItem = [[GlossaryItem alloc] init];
			
			if([attributeDict objectForKey:@"name"]){
				self.currentItem.name = [attributeDict objectForKey:@"name"];
			}
			
			if([attributeDict objectForKey:@"category"] ){
				self.currentItem.category = [attributeDict objectForKey:@"category"];
				
				// if we don't have the catagory yet, then add an array for it
				if(![categories objectForKey:self.currentItem.category]){
					
					[categories setObject:[[NSMutableArray alloc] init] forKey:self.currentItem.category];
					[categoryNames addObject:self.currentItem.category];
				}
				// Adds current item to the category
				NSMutableArray * catagoryItems = [categories objectForKey:self.currentItem.category];
				[catagoryItems addObject:self.currentItem];
				
			}
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.currentProperty) {
        [currentProperty appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (qName) {
        elementName = qName;
    }
	
	if (self.currentItem) { // Are we in a
        // Check for standard nodes
        if ([elementName isEqualToString:@"history"]) {
            self.currentItem.history = self.currentProperty;
        } else if ([elementName isEqualToString:@"description"]) {
			self.currentItem.description = self.currentProperty;
        } else if ([elementName isEqualToString:@"item"]) {
            [glossaryData addObject:currentItem];  
            self.currentItem = nil;
        }
    }

	
    // We reset the currentProperty, for the next textnodes..
    self.currentProperty = nil;

	 
}

- (void)parser :(NSXMLParser *)parser parseErrorOccurred :(NSError *)parseError {
	NSString *errorString = [NSString stringWithFormat:@"Error %i, Description: %@, Line: %i, Column: %i", [parseError code], [[parser parserError] localizedDescription], [parser lineNumber],	[parser columnNumber]];
	
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Parsing Error!" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}
#pragma mark -
#pragma mark Tabel Cell methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	GlossaryTableViewCell *cell = (GlossaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (cell == nil) {
		cell = [[GlossaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.backgroundView =[[UIImageView alloc] init] ;
		cell.selectedBackgroundView = [[UIImageView alloc] init];
	}
	
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
	NSInteger row = [indexPath row];
	if (row == 0 && row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"glossaryBack.png"];
		selectionBackground = [UIImage imageNamed:@"glossaryBackSelected.png"];
	}
	else if (row == 0)
	{
		rowBackground = [UIImage imageNamed:@"glossaryBack.png"];
		selectionBackground = [UIImage imageNamed:@"glossaryBackSelected.png"];
	}
	else if (row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"glossaryBack.png"];
		selectionBackground = [UIImage imageNamed:@"glossaryBackSelected.png"];
	}
	else
	{
		rowBackground = [UIImage imageNamed:@"glossaryBack.png"];
		selectionBackground = [UIImage imageNamed:@"glossaryBackSelected.png"];
	}
	((UIImageView *)cell.backgroundView).image = rowBackground;
	((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	NSString * section = [categoryNames objectAtIndex: indexPath.section];
	NSMutableArray * data = [categories objectForKey:section];
	cell.glossaryItem = [data objectAtIndex:indexPath.row];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
	
	// return the number of items in the states array
	return [categories count];
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
	// this table has multiple sections. One for each physical state
	// [solid, liquid, gas, artificial]
	
	// get the state key for the requested section
	
	// return the number of items that are in the array for that state
	NSMutableArray * t = [categories objectForKey:[categoryNames objectAtIndex:section]];
	return [t count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// this table has multiple sections. One for each physical state
	
	// [solid, liquid, gas, artificial]
	// return the state that represents the requested section
	// this is actually a delegate method, but we forward the request to the datasource in the view controller
	
	return [categoryNames objectAtIndex:section];
}



@end
