//
//  Utility.h
//  Untitled
//
//  Created by Matthew Prockup on 2/15/10.
//  Copyright 2010 Drexel University. All rights reserved.
//
// This class contains some simple image editing tools.

#import <Foundation/Foundation.h>


@interface Utility : NSObject {

}

+ (UIColor *) randomColor;
+ (UIImage *) colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;
+ (UIImage *) resizeImage:(UIImage*) input toSize:(CGSize) size;

@end
