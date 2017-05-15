//
//  TrackLabelView.m
//  iNotesMulti
//
//  Created by ExCITe on 5/8/13.
//
//

#import "TrackLabelView.h"

@implementation TrackLabelView
@synthesize tracktag,isLive,pieceName,movementName,nameLabel,composerName; //liveButton
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)setPieceName:(NSString*)pName withMovementName:(NSString*)trackN withTag:(int)t
{
    pieceName = pName;
    movementName = trackN;
    trackTag = t;
    composerName = [[NSString alloc] init];
    composerName = @"";
//    liveButton = [[UIButton alloc] initWithFrame: CGRectMake(self.frame.size.width-self.frame.size.height-2, 0, self.frame.size.height,self.frame.size.height)]; // Juliesays : seems unused, VERIFIED
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];
    [nameLabel setText:movementName];
    [nameLabel setTextAlignment: NSTextAlignmentCenter];
    [nameLabel setFont:ALBUM_MVT_FONT];
    [nameLabel setTextColor:ALBUM_MVT_TEXT_COLOR];
    [nameLabel setBackgroundColor:ALBUM_MVT_BG_COLOR];
    [self addSubview:nameLabel];


    
}
-(NSString*) getPieceName{
    return pieceName;
}
-(NSString*) getMovementName{
    return movementName;
}
-(NSString*) getComposerName{
    return composerName;
}
-(int) getTag{
    return trackTag;
}
-(void)setLive:(bool)live{
    isLive = live;
}

-(void)setLiveTag:(int)t{
    if(trackTag == t)
    {
        isLive = YES;
    }
}

@end
