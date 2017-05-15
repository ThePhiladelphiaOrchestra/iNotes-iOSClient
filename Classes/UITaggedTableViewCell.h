//
//  UITaggedTableViewCell.h
//  iNotes
//
//  Created by Matthew Prockup on 2/15/14.
//
//  This is a simple UITableViewCell subclassed to add text tag attribute and a music piece attribute

#import <UIKit/UIKit.h>
#import "MusicPiece.h"
@interface UITaggedTableViewCell : UITableViewCell
{
    NSString* tagText;
    MusicPiece* tagPiece;
}

@property (nonatomic,retain)NSString* tagText;
@property (nonatomic,retain)MusicPiece* tagPiece;
@end
