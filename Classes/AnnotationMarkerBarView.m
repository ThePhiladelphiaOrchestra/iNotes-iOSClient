//
//  AnnotationMarkerBarView.m
//  iNotesMulti
//
//  Created by Matthew Prockup on 5/2/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//

#import "AnnotationMarkerBarView.h"

@implementation AnnotationMarkerBarView
@synthesize track,barView,waveTrack;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)addWaveform: (Track*) tempTrack
{
    waveTrack = [[Track alloc] init];
    waveTrack = tempTrack;
    
    waveViews = [[NSMutableArray alloc] init];
    
    int numMeasures = track.numMeasures;
    CGRect thisFrame = self.frame;
    int height = thisFrame.size.height;
    int width = thisFrame.size.width;
    int prevX = 0;
    
    NSLog(@"Waveform:");
    for(int i = 1; i< [waveTrack.pages count]; i++)
    {
        //get map color and title
        NSArray *items = [[[waveTrack.pages objectAtIndex:i-1] text] componentsSeparatedByString:@","];
        NSString* dynamics = [items objectAtIndex:0];

        
        //section height is the height of the color structure bar. height in this context includes the markerbar with the dots
        int sectionHeight = height-height/4;
        dynamics = [dynamics lowercaseString];
        if([dynamics isEqualToString:@"ppp"]){
            sectionHeight*=0.08; //(1/12)
        }
        else if([dynamics isEqualToString:@"pp"]){
            sectionHeight*=0.16; // (1/6) or (2/12)
        }
        else if([dynamics isEqualToString:@"p"]){
            sectionHeight*=0.33; // (1/3) or (4/12)
        }
        else if([dynamics isEqualToString:@"mp"]){
            sectionHeight*=0.5; // (1/2) or (6/12)
        }
        else if([dynamics isEqualToString:@"mf"]){
            sectionHeight*=0.66; // (2/3) or (8/12)
        }
        else if([dynamics isEqualToString:@"f"]){
            sectionHeight*=0.83; // (5/6) or (10/12)
        }
        else if([dynamics isEqualToString:@"ff"]){
            sectionHeight*=1.0;
        }
        else if([dynamics isEqualToString:@"fff"]){
            sectionHeight*=1.0;
        }
        else
        {
            sectionHeight*=[dynamics doubleValue];
        }
        
        //get offset to create top of dynamics section relative to the center of the color bar.
        // the waveform should be drawen cented in the color bar.
        int sectionTop = height/4 + (height-height/4 - sectionHeight)/2;
        
        //get position and size
        double newWidth = (int)(((float)[[waveTrack.pages objectAtIndex:i] measure]/(float)numMeasures)*width - prevX);
        CGRect segment = CGRectMake(prevX, sectionTop, newWidth, sectionHeight);
        
        UIView* segmentView = [[UIView alloc] initWithFrame:segment];
        [segmentView setBackgroundColor:[UIColor blackColor]];
        [segmentView setAlpha:0.5];
        [waveViews addObject:segmentView];
        [self addSubview: [waveViews objectAtIndex:[waveViews count]-1]];

        prevX = (int)(((float)[[waveTrack.pages objectAtIndex:i] measure]/(float)numMeasures)*width);
    }
    
    [self bringSubviewToFront:barView];
    [self setNeedsDisplay];
}

-(void)addMarkers: (Track*) tempTrack
{
    track = [[Track alloc] init];
    track = tempTrack;
    
    CGRect thisFrame = self.frame;
    int height = thisFrame.size.height;
    int width = thisFrame.size.width;
    
    UIImage* backgroundImage = [UIImage imageNamed:@"timelineBar.png"];
    UIImageView* backView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backView setFrame:CGRectMake(0,0, width, height/4)];
    
    [self addSubview:backView];
    
    int numMeasures = track.numMeasures;
    
    for(int i = 0; i<[track.pages count]; i++)
    {
        int measureNum = [[track.pages objectAtIndex:i] measure];
        float fractionSpace = (float)measureNum / (float)numMeasures;
        int tempXPos = fractionSpace*width;
        UIImage* dot = [UIImage imageNamed:@"timelineDot.png"];
        UIImageView* dotView = [[UIImageView alloc] initWithImage:dot];
        [dotView setFrame:CGRectMake(tempXPos,height/12, height/12, height/12)];
        
        [self addSubview:dotView];
        
    }
    
    UIImage* colorsImage = MARKER_BAR_BACKGROUND;
    UIImageView* colorsView = [[UIImageView alloc] initWithImage:colorsImage];
    [colorsView setFrame:CGRectMake(0,height/4, width, height*4)];
    [self addSubview:colorsView];
    
    
    UIImage* barImage = [UIImage imageNamed:@"playhead.png"];
    barView = [[UIImageView alloc] initWithImage:barImage];
    [barView setFrame:CGRectMake(50,height/4, 2, height/4*3)];
    [barView setAlpha:0.7];
    [self addSubview:barView];
    
    
    //Test1AppDelegate *appDelegate = (Test1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
}

-(void) updateBarView:(int)measure
{
    
    CGRect thisFrame = self.frame;
    int width = thisFrame.size.width;
    int numMeasures = track.numMeasures;
    float fractionSpace = (float)measure / (float)numMeasures;
    int tempXPos = fractionSpace*width;
    [barView setFrame:CGRectMake(tempXPos,barView.frame.origin.y, 2, barView.frame.size.height)];
    [barView setNeedsDisplay];
    
}

-(void) drawMapSegments:(Track*)mapTrack
{
    mapViews = [[NSMutableArray alloc] init];
    mapLabels = [[NSMutableArray alloc] init];
    int numMeasures = track.numMeasures;
    CGRect thisFrame = self.frame;
    int height = thisFrame.size.height;
    int width = thisFrame.size.width;
    int prevX = 0;
    
    NSLog(@"Structure:");
    for(int i = 1; i< [mapTrack.pages count]; i++)
    {
        //get map color and title
        NSArray *items = [[[mapTrack.pages objectAtIndex:i-1] text] componentsSeparatedByString:@","];
        NSString* sectionName = [items objectAtIndex:0];
        float r = 0;
        float g = 0;
        float b = 0;
        UIColor* color;
        for(NSString* item in items)
        {
            NSLog(@"%@",item);
        }
        //deal with RGB
        if([items count]==4)
        {
            r = [[items objectAtIndex:1] intValue]/255.0;
            g = [[items objectAtIndex:2] intValue]/255.0;
            b = [[items objectAtIndex:3] intValue]/255.0;
            color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
            
        }
        //deal with names
        else if([items count]==2)
        {
            color = [self getUIColor:[items objectAtIndex:1]];
        }
        else{
            color = [self getUIColor:@"rand"];
        }
        
        
        
        //color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        
        //get position and size
        int newWidth = (int)(((float)[[mapTrack.pages objectAtIndex:i] measure]/(float)numMeasures)*width - prevX);
        CGRect segment = CGRectMake(prevX, height/4,newWidth, height-height/4);
        
        
        
        UIView* segmentView = [[UIView alloc] initWithFrame:segment];
        [segmentView setBackgroundColor:color];
        [segmentView setAlpha:0.5];
        [mapViews addObject:segmentView];
        [self addSubview: [mapViews objectAtIndex:[mapViews count]-1]];
        
        CGRect temp = CGRectMake(-100 +  ((UIView*)[mapViews objectAtIndex:i-1]).frame.origin.x + ((UIView*)[mapViews objectAtIndex:i-1]).frame.size.width/2,100-12,
                                 200,
                                 25);
        UILabel* label = [[UILabel alloc] initWithFrame:temp];
        [label setText:sectionName];
        [label setFont:MAP_FONT];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = MAP_TEXT_COLOR;
        label.textAlignment = NSTextAlignmentCenter;
        [label setAlpha:0.0];
        
        
        [mapLabels addObject:label];
        
        ((UIView*)[mapLabels objectAtIndex:[mapLabels count]-1]).transform = CGAffineTransformMakeRotation(-(M_PI)/2);
        [self addSubview:[mapLabels objectAtIndex:[mapLabels count]-1]];
        
        prevX = (int)(((float)[[mapTrack.pages objectAtIndex:i] measure]/(float)numMeasures)*width);
    }
    [self bringSubviewToFront:barView];
    [self setNeedsDisplay];
    
}


-(void) expandView
{
    
    CGRect thisFrame = self.frame;
    int height = thisFrame.size.height;
    int width = thisFrame.size.width;
    int xPos = thisFrame.origin.x;
    int yPos = thisFrame.origin.y;
    
    
    
    [UIView beginAnimations:nil context:NULL]; // animate the following:
    [UIView setAnimationDuration:1.0];
    [self setFrame:CGRectMake(xPos,yPos-height*3, width, height*4)];
    [barView setFrame:CGRectMake(barView.frame.origin.x, barView.frame.origin.y, barView.frame.size.width,barView.frame.size.height+height*3)];
    
    for(int i = 0; i<[mapViews count]; i++)
    {
        [((UIView*)[mapViews objectAtIndex:i]) setFrame:CGRectMake(((UIView*)[mapViews objectAtIndex:i]).frame.origin.x, ((UIView*)[mapViews objectAtIndex:i]).frame.origin.y, ((UIView*)[mapViews objectAtIndex:i]).frame.size.width,((UIView*)[mapViews objectAtIndex:i]).frame.size.height+height*3)];
        [[mapLabels objectAtIndex:i] setAlpha:1.0];
    }
    
    
    for(int i = 0; i<[mapViews count]; i++)
    {
        //        CGRect temp = CGRectMake(-100 +  ((UIView*)[mapViews objectAtIndex:i]).frame.origin.x + ((UIView*)[mapViews objectAtIndex:i]).frame.size.width/2,100-12,
        //                                 200,
        //                                 25);
        //        //label.transform = CGAffineTransformMakeRotation(-(M_PI)/2);
        //        [((UIView*)[mapLabels objectAtIndex:i]) setFrame:temp];
        [[mapLabels objectAtIndex:i] setAlpha:1.0];
    }
    
    
    [self setNeedsDisplay];
    [UIView commitAnimations];
    
    
    
    
    
    
}

-(void) collapseView
{
    [UIView beginAnimations:nil context:NULL]; // animate the following:
    [UIView setAnimationDuration:1.0];
    
    CGRect thisFrame = self.frame;
    int height = thisFrame.size.height;
    int width = thisFrame.size.width;
    int xPos = thisFrame.origin.x;
    int yPos = thisFrame.origin.y;
    
    [self setFrame:CGRectMake(xPos,yPos+height/4*3, width, height/4)];
    [barView setFrame:CGRectMake(barView.frame.origin.x, barView.frame.origin.y, barView.frame.size.width,barView.frame.size.height-height/4*3)];
    
    for(int i = 0; i<[mapViews count]; i++)
    {
        [((UIView*)[mapViews objectAtIndex:i]) setFrame:CGRectMake(((UIView*)[mapViews objectAtIndex:i]).frame.origin.x, ((UIView*)[mapViews objectAtIndex:i]).frame.origin.y, ((UIView*)[mapViews objectAtIndex:i]).frame.size.width,((UIView*)[mapViews objectAtIndex:i]).frame.size.height-height/4*3)];
        
    }
    
    
    
    for(int i = 0; i<[mapViews count]; i++)
    {
        //        CGRect temp = CGRectMake(-100 +  ((UIView*)[mapViews objectAtIndex:i]).frame.origin.x + ((UIView*)[mapViews objectAtIndex:i]).frame.size.width/2,100-12,
        //                                 200,
        //                                 25);
        //label.transform = CGAffineTransformMakeRotation(-(M_PI)/2);
        [[mapLabels objectAtIndex:i] setAlpha:0.0];
        //((UIView*)[mapLabels objectAtIndex:i]).transform = CGAffineTransformMakeRotation((M_PI)/2);
        //[((UIView*)[mapLabels objectAtIndex:i]) setFrame:((UIView*)[mapViews objectAtIndex:i]).frame];
        
    }
    
    [self setNeedsDisplay];
    [UIView commitAnimations];
    
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(UIColor*)getUIColor:(NSString*)string
{
    UIColor *color;
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;
    
    int rNum = 0;
    if([string isEqualToString:@"rand"])
    {
        rNum = arc4random() % 18 + 1;
    }
    
    
    
    if([string isEqualToString:@"red"]||(rNum == 1)) {
        r = 1.0;
        g = 0.0;
        b = 0.0;
    }
    else if([string isEqualToString:@"darkred"]||(rNum == 2)) {
        r = 0.5;
        g = 0.0;
        b = 0.0;
    }
    else if([string isEqualToString:@"green"]||(rNum == 3)) {
        r = 0.0;
        g = 1.0;
        b = 0.0;
    }
    else if([string isEqualToString:@"darkgreen"]||(rNum == 4)) {
        r = 0.0;
        g = 0.5;
        b = 0.0;
    }
    else if([string isEqualToString:@"blue"]||(rNum == 5)) {
        r = 0.0;
        g = 0.0;
        b = 1.0;
    }
    else if([string isEqualToString:@"darkblue"]||(rNum == 6)) {
        r = 0.0;
        g = 0.0;
        b = 0.5;
    }
    else if([string isEqualToString:@"cyan"]||(rNum == 7)) {
        r = 0.0;
        g = 1.0;
        b = 1.0;
    }
    else if([string isEqualToString:@"darkcyan"]||(rNum == 8)) {
        r = 0.0;
        g = 0.5;
        b = 0.5;
    }
    else if([string isEqualToString:@"yellow"]||(rNum == 9)) {
        r = 1.0;
        g = 1.0;
        b = 0.0;
    }
    else if([string isEqualToString:@"darkyellow"]||(rNum == 10)) {
        r = 0.5;
        g = 0.5;
        b = 0.0;
    }
    else if([string isEqualToString:@"magenta"]||(rNum == 11)) {
        r = 1.0;
        g = 0.0;
        b = 1.0;
    }
    else if([string isEqualToString:@"darkmagenta"]||(rNum == 12)) {
        r = 0.5;
        g = 0.0;
        b = 0.5;
    }
    else if([string isEqualToString:@"grey"]||(rNum == 13)) {
        r = 0.6;
        g = 0.6;
        b = 0.6;
    }
    else if([string isEqualToString:@"darkgrey"]||(rNum == 14)) {
        r = 0.3;
        g = 0.3;
        b = 0.3;
    }
    else if([string isEqualToString:@"gray"]||(rNum == 15)) {
        r = 0.6;
        g = 0.6;
        b = 0.6;
    }
    else if([string isEqualToString:@"darkgray"]||(rNum == 16)) {
        r = 0.3;
        g = 0.3;
        b = 0.3;
    }
    else if([string isEqualToString:@"white"]||(rNum == 17)) {
        r = 1.0;
        g = 1.0;
        b = 1.0;
    }
    else if([string isEqualToString:@"black"]||(rNum == 18)) {
        r = 0.0;
        g = 0.0;
        b = 0.0;
    }
    
    color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}




@end
