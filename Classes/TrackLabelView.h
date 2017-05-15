//
//  TrackLabelView.h
//  iNotesMulti
//
//  Created by ExCITe on 5/8/13.
//
//

#import <UIKit/UIKit.h>
#import "constants.h"
@interface TrackLabelView : UIButton
{
    bool isLive;
    NSString* pieceName;
    NSString* movementName;
    NSString* composerName;
    int trackTag;
//    UIButton* liveButton; // Juliesays : seems unused, VERIFIED
    UILabel* nameLabel;
}
-(void)setPieceName:(NSString*)pName withMovementName:(NSString*)trackN withTag:(int)t;
-(NSString*)getPieceName;
-(NSString*)getMovementName;
-(int) getTag;
-(void)setLive:(bool)live;
-(void)setLiveTag:(int)t;

@property (assign) int tracktag;
@property (assign) bool isLive;
//@property (retain) UIButton* liveButton; // Juliesays : seems unused, VERIFIED
@property (retain) NSString* pieceName;
@property (retain) NSString* movementName;
@property (retain) NSString* composerName;
@property (retain) UILabel*  nameLabel;


@end
