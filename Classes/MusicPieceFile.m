//
//  MusicPieceFile.m
//  iNotes
//
//  Created by Matthew Prockup on 1/14/14.
//
//

#import "MusicPieceFile.h"

@implementation MusicPieceFile


-(id)initWithName:(NSString*) name withData:(NSString*)data withImages:(NSArray*) images thatHaveNames: (NSArray*) imageNames{
    self = [super init];
    pieceName = name;
    pieceData = data;
    pictures = images;
    pictureNames = imageNames;
    return self;
}

-(bool) loadPiece:(NSString*) fileName{
    
    
    NSLog(@"Working with file %@", fileName);
    
    NSString* docsDir = [SavedContentManager getDocumentsDir];
    NSLog(@"When loading piece, docsDir is %@",docsDir);
    
    [SavedContentManager createFolderAtPath:docsDir withName:fileName];
    NSString* savedPiecePath = [NSString stringWithFormat:@"%@/%@/",docsDir,fileName];
    NSLog(@"When loading piece, savedPiecePath %@",savedPiecePath);
    
    
    if(![SavedContentManager fileExistsAtPath:savedPiecePath withName:@"data.xml"])
    {
        NSLog(@"no data file at that path");
        return false;
    }
    pieceData = [SavedContentManager loadTextFileAtPath:savedPiecePath withName:@"data.xml"];
    NSLog(@"loaded text file at path %@", savedPiecePath);
    
    
    if(![SavedContentManager fileExistsAtPath:savedPiecePath withName:@"name.txt"])
    {
        NSLog(@"no name file at that path");
        return false;
    }
    pieceName = [SavedContentManager loadTextFileAtPath:savedPiecePath withName:@"name.txt"];
    NSLog(@"loaded text file at path %@", savedPiecePath);
    
    if(![SavedContentManager fileExistsAtPath:savedPiecePath withName:@"imageNames.txt"])
    {
        NSLog(@"no image names at that path");
        return false;
    }
    NSString* picNamesText = [SavedContentManager loadTextFileAtPath:savedPiecePath withName:@"imageNames.txt"];
    NSLog(@"loaded pictures %@", picNamesText);
    pictureNames = [[NSArray alloc] initWithArray:[picNamesText componentsSeparatedByString:@";"]];
    
    
    NSMutableArray* tempPicArray = [[NSMutableArray alloc] init];
    for(NSString* name in pictureNames)
    {
        NSData* tempdata = [SavedContentManager loadDataFileAtPath:savedPiecePath withName:name];
        [tempPicArray addObject:tempdata];
    }
    pictures = [[NSArray alloc] initWithArray:tempPicArray copyItems:YES];
    

    
    return true;
}

-(bool) savePiece:(NSString*) fileName{
    
    NSString* docsDir = [SavedContentManager getDocumentsDir];
    
    [SavedContentManager createFolderAtPath:docsDir withName:fileName];
    NSString* savedPiecePath = [NSString stringWithFormat:@"%@/%@/",docsDir,fileName];
    
    [SavedContentManager saveTextFileWithContents:pieceData atPath:savedPiecePath withName:@"data.xml"];
    [SavedContentManager saveTextFileWithContents:pieceName atPath:savedPiecePath withName:@"name.txt"];
    
    NSString* pieceList = [[NSString alloc] init];
    
    for(int i = 0;i<[pictures count]; i++)
    {
        if(i == 0)
        {
            pieceList = [pictureNames objectAtIndex:0];
        }
        else{
            pieceList = [pieceList stringByAppendingString:[NSString stringWithFormat:@";%@",[pictureNames objectAtIndex:i]]];
        }
        
        
        [SavedContentManager saveDataFileWithContents:[pictures objectAtIndex:i] atPath:savedPiecePath withName:[pictureNames objectAtIndex:i]];
        
        NSString *savedImagePath = [savedPiecePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[pictureNames objectAtIndex:i]]];
        NSLog(@"%@",savedImagePath);
        [SavedContentManager saveTextFileWithContents:pieceList atPath:savedPiecePath withName:@"imageNames.txt"];
    }
    
    return true;
}


-(NSString*) getName{
    return pieceName;
}

-(NSArray*) getImages{
    return pictures;
}

-(NSArray*) getImageNames{
    return pictureNames;
}

-(NSString*) getPieceData{
    return pieceData;
}


@end
