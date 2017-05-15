//
//  GlossaryTableViewCell.m
//  Untitled
//
//  Created by Matthew Prockup on 2/2/10.
//  Copyright 2010 Drexel University. All rights reserved.
//

#import "GlossaryTableViewCell.h"


@implementation GlossaryTableViewCell

@synthesize glossaryItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
		label.backgroundColor = [UIColor clearColor];
		label.font = GLOSSARY_TABLE_FONT;
		label.textColor = GLOSSARY_TABLE_FONT_COLOR;
		[self.contentView addSubview:label];
    }
    return self;
}

-(void) setGlossaryItem:(GlossaryItem *)theItem {
	label.text = theItem.name;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	label.textColor = GLOSSARY_TABLE_FONT_COLOR;
    label.font = GLOSSARY_TABLE_SELECTED_FONT;
    // Configure the view for the selected state
}

- (void)dealloc {
//    [super dealloc];
}


@end
