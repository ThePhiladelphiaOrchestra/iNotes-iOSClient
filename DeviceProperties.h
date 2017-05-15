//
//  DeviceProperties.h
//  iNotes
//
//  Created by Matthew Prockup on 2/11/14.
//
//  A set of static functions that returns specific properties
//  of the iOS device the code is running on.

#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include "constants.h" 



@interface DeviceProperties : NSObject
{
    
}

+(NSString *) getDeviceType;
+(NSString *) getDeviceTypeSimple;
+(CGSize) getDeviceResolutionLandscape;
+(CGSize) getDeviceResolutionPortrait;
+(BOOL) isIOS7;



@end

