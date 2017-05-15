//
//  DataPage.m
//  Test1
//
//  Created by Matthew Prockup on 11/18/09.
//  Copyright 2009 Drexel University. All rights reserved.
//

#import "DataPage.h"
#import "constants.h"

@implementation DataPage

@synthesize measure, text, time, html, images, imageDataPath, imageData, structure, parentTrack, hasImages, imageWidth, imageHeight, pieceName;
//NSString * urlImageFolder = @"http://music.ece.drexel.edu/~mprockup/iNotesDev/images/";

NSString * urlImageFolder = IMAGE_SERVER;

//NSString * urlImageFolder = @"http://172.16.101.10/images/";
//NSString * urlImageFolder = @"http://204.75.178.37/images/";

- (id) init
{
	 if (self = [super init]);
	{
		self.measure = 0;
		self.text = nil;
		self.structure = nil;
		self.parentTrack = nil;
		self.time = 0.0;
		self.html = TEXT_ONLY;
		//images = [[NSMutableArray alloc] init];
		self.imageDataPath = [[NSMutableArray alloc] init];
		self.imageData = [[NSMutableArray alloc] init];
        self.hasImages = FALSE;
        self.imageWidth = 0;
        self.imageHeight = 0;

	}
    
	return self;
}

- (NSString*) extractAndRemoveImageData:(NSString *) theText{
	NSArray * parts = [theText componentsSeparatedByString:@"$"];
	if([parts count] > 1){
		if([[parts objectAtIndex:0] isEqualToString:@""]){
			NSString * image1 = [parts objectAtIndex:1];
			NSArray * partsImages = [image1 componentsSeparatedByString:@","];
			for (int j = 0; j<([partsImages count]-1);j++) {
				NSString *tempImageStr = [partsImages objectAtIndex:j];
				
                
                //EDIT ME
                //Load from saved file rather then from internet
                
				NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"%@%@",urlImageFolder,tempImageStr];
				
                NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
                
                NSLog(@"%@",tempImageStrUrl);
				NSURL *url = [NSURL URLWithString:tempImageStrUrl];
				NSData *data = [NSData dataWithContentsOfURL:url];
				UIImage *image = [[UIImage alloc] initWithData:data];
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
				NSString *documentsDirectory = [paths objectAtIndex:0];
				NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",tempImageStr]];
				NSLog(@"%@",savedImagePath);
				[data writeToFile:savedImagePath atomically:NO];
				
                hasImages = TRUE;
                imageWidth = image.size.width;
                imageHeight = image.size.height;
			}
			self.images = partsImages;
			self.html = PICTURE_ONLY;

		}
		else{
			for(int i=1; i<[parts count]; i++){
				NSString * image1 = [parts objectAtIndex:i];
				NSArray * partsImages = [image1 componentsSeparatedByString:@","];
				self.images = partsImages;
				
                NSCharacterSet *charactersToRemove = [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                NSString* fileTemp = [[self.pieceName componentsSeparatedByCharactersInSet:charactersToRemove ] componentsJoinedByString:@"" ];
                
                fileTemp = [NSString stringWithFormat:@"/POA%@",fileTemp];
                NSString* imageDirectory = [SavedContentManager getDocumentsDir];
                NSString* pieceDir = [imageDirectory stringByAppendingString:fileTemp];
                
                
                
                
				for (int j = 0; j<([partsImages count]-1);j++) {
					NSString *tempImageStr = [partsImages objectAtIndex:j];
					
					NSString *tempImageStrUrltemp = [NSString stringWithFormat:@"%@/%@",pieceDir,tempImageStr];
                    
                    NSString* tempImageStrUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)tempImageStrUrltemp,	 NULL,	 (CFStringRef)@"!’\"();@&=+$,?%#[]% ", kCFStringEncodingISOLatin1));
                   

                    NSData* data = [SavedContentManager loadDataFileAtPath:tempImageStrUrl];
					UIImage *image = [[UIImage alloc] initWithData:data];
					[imageData addObject:image];

					[imageDataPath addObject:tempImageStrUrltemp];
					
					NSLog(@"saved ok!");
                    hasImages = TRUE;
                    imageWidth = image.size.width;
                    imageHeight = image.size.height;
				}
				
				
				NSString * temp = [theText stringByReplacingOccurrencesOfString:image1 withString:@""];
				theText = temp;
			}
			
			NSString * temp1 = [theText stringByReplacingOccurrencesOfString:@"$" withString:@""];
			theText = temp1;
			self.html = TEXT_AND_PICTURE;
		}
		
	}
	else{
		self.html = TEXT_ONLY;
	}
    return theText;
	
}

@end
