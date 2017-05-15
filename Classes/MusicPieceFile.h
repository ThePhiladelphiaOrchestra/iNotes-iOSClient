//
//  MusicPieceFile.h
//  iNotes
//
//  Created by Matthew Prockup on 1/14/14.
//
//

#import <Foundation/Foundation.h>
#import "SavedContentManager.h"
@interface MusicPieceFile : NSObject
{
    NSString* pieceName;
    NSArray* pictures;
    NSString* pieceData;
    NSArray*pictureNames;
}
-(id) initWithName:(NSString*) name withData:(NSString*)data withImages:(NSArray*) images thatHaveNames: (NSArray*) imageNames;
-(bool) loadPiece:(NSString*) fileName;
-(bool) savePiece:(NSString*) fileName;
-(NSString*) getName;
-(NSArray*) getImages;
-(NSString*) getPieceData;
-(NSArray*) getImageNames;

@end
