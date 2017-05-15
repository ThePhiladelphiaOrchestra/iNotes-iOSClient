//
//  UITaggedButton.h
//  iNotes
//
//  Created by Matthew Prockup on 2/15/14.
//
//  This is a simple UIButton subclassed to add text tag attribute rather than an integer tag

#import <UIKit/UIKit.h>

@interface UITaggedButton : UIButton
{
    NSString* tagText;
}

@property (nonatomic,retain)NSString* tagText;

@end
