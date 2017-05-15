//
//  SavedContentManager.h
//  iNotes
//
//  Created by Matthew Prockup on 1/14/14.
//
//  This class manages all saved content for iOS sandbox
//  Mostly works, needs better error checking.
//
//  Note:   all files that have a "path" and a "filename" as arguments
//          are structure that such that the path does not include the
//          filename.
//          For example:
//              this/is/the/path/to/filename.jawn
//              path     =  /this/is/the/path/to/
//              filename =  filename.jawn

#import <Foundation/Foundation.h>

@interface SavedContentManager : NSObject

//Navigate/Explore sandboxed content
+(NSString *)getDocumentsDir;
+(NSArray *)listFilesForPath:(NSString *)path;
+(NSArray *)listDocumentsDir;
+(bool) fileExistsAtPath:(NSString*) path withName:(NSString*) fileName;
+(bool) deleteFileAtPath:(NSString*) filepath;

//File system unitities for sandboxed content
+(bool) createFolderAtPath:(NSString*) path withName:(NSString*) folderName;
+(bool) createFolderInDocuments:(NSString*) folderName;
+(bool) copyFileAtPath:(NSString*)folderNameAndPath toPath:(NSString*)destinationPath;

//Various methods for saving files
//NSString: textfiles
+(bool) saveTextFileWithContents:(NSString*)textContent atPath:(NSString*)path withName:(NSString*) fileName;   
+(bool) saveTextFileInDocumentsWithContents:(NSString*)textContent withName:(NSString*) fileName;               
//NSData: everything else
+(bool) saveDataFileWithContents:(NSData*)data atPath:(NSString*)path withName:(NSString*) fileName;
+(bool) saveDataFileInDocumentsWithContents:(NSData*)data withName:(NSString*) fileName;

//Various methods for loading files
//NSString: textfiles
+(NSString*) loadTextFileAtPath:(NSString*)path withName:(NSString*) fileName;
+(NSString*) loadTextFileInDocumentsWithName:(NSString*) fileName;
//NSData: everything else
+(NSData*) loadDataFileAtPath:(NSString*)path withName:(NSString*) fileName;
+(NSData*) loadDataFileInDocumentsWithName:(NSString*) fileName;
+(NSData*) loadDataFileAtPath:(NSString*)path;



@end
