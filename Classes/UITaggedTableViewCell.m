//
//  UITaggedTableViewCell.m
//  iNotes
//
//  Created by Matthew Prockup on 2/15/14.
//
//

#import "UITaggedTableViewCell.h"

@implementation UITaggedTableViewCell
@synthesize tagText, tagPiece;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
