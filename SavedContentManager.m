//
//  SavedContentManager.m
//  iNotes
//
//  Created by Matthew Prockup on 1/14/14.
//
//

#import "SavedContentManager.h"

@implementation SavedContentManager

#pragma mark Directory Information
+(NSString *)getDocumentsDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    return documentsDirectory;
}


+(NSArray *)listDocumentsDir
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND IN DOCS");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}



+(NSArray *)listFilesForPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

+(bool) fileExistsAtPath:(NSString*) path withName:(NSString*) fileName
{
    NSString *dataPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        return true;
    }
    else
    {
        return false;
    }
}


#pragma mark Directory Management
+(bool) createFolderAtPath:(NSString*) path withName:(NSString*) folderName
{
    NSString *dataPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",folderName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
        return true;
    }
    else{
        return false;
    }
    
}

+(bool) createFolderInDocuments:(NSString*) folderName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",folderName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
        return true;
    }
    else{
        return false;
    }
    
}

+(bool) copyFileAtPath:(NSString*)folderNameAndPath toPath:(NSString*)destinationPath
{
    
    NSError *copyError = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:folderNameAndPath toPath:destinationPath error:&copyError]) {
        NSLog(@"Error copying files: %@", [copyError localizedDescription]);
        return false;
    }
    return true;
}

+(bool) deleteFileAtPath:(NSString*) filepath;
{
    NSLog(@"removing an item from the savedcontent");
    NSLog(@"we are removing the file at path %@", filepath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filepath error:NULL];
    [self listFilesForPath:filepath];
    return true;
}


#pragma mark Save Data

+(bool) saveTextFileWithContents:(NSString*)textContent atPath:(NSString*)path withName:(NSString*) fileName
{
    NSString *savePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    if([textContent writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:NULL])
        return true;
    else
        return false;
    
}

+(bool) saveTextFileInDocumentsWithContents:(NSString*)textContent withName:(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    if([textContent writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:NULL])
        return true;
    else
        return false;
    
}

+(bool) saveDataFileWithContents:(NSData*)data atPath:(NSString*)path withName:(NSString*) fileName
{
    NSString *savePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    if([data writeToFile:savePath atomically:YES])
        return true;
    else
        return false;
    
}

+(bool) saveDataFileInDocumentsWithContents:(NSData*)data withName:(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    if([data writeToFile:savePath atomically:YES])
        return true;
    else
        return false;
}

#pragma mark Load Data

+(NSString*) loadTextFileAtPath:(NSString*)path withName:(NSString*) fileName
{
    NSString *loadPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    NSString* loadedStringData = [[NSString alloc] initWithContentsOfFile:loadPath encoding:NSUTF8StringEncoding error:nil];
    return loadedStringData;
}

+(NSString*) loadTextFileInDocumentsWithName:(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *loadPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    NSString* loadedStringData = [[NSString alloc] initWithContentsOfFile:loadPath encoding:NSUTF8StringEncoding error:nil];
    return loadedStringData;
}

+(NSData*) loadDataFileAtPath:(NSString*)path withName:(NSString*) fileName
{
    NSString *loadPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    NSData* loadedData = [[NSData alloc] initWithContentsOfFile:loadPath];
    return loadedData;
    
}

+(NSData*) loadDataFileAtPath:(NSString*)path
{
    NSString *loadPath = path;
    
    NSData* loadedData = [[NSData alloc] initWithContentsOfFile:loadPath];
    return loadedData;
    
}

+(NSData*) loadDataFileInDocumentsWithName:(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *loadPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    NSData* loadedData = [[NSData alloc] initWithContentsOfFile:loadPath];
    return loadedData;
}

@end
