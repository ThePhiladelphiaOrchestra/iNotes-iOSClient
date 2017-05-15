//
//  DeviceProperties.m
//  iNotes
//
//  Created by Matthew Prockup on 2/11/14.
//
//

#import "DeviceProperties.h"

@implementation DeviceProperties


+ (NSString *) getDeviceType{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])        return @"iPhone 1G";
    else if ([platform isEqualToString:@"iPhone1,2"])   return @"iPhone 3G";
    else if ([platform isEqualToString:@"iPhone2,1"])   return @"iPhone 3GS";
    else if ([platform isEqualToString:@"iPhone3,1"])   return @"iPhone 4";
    else if ([platform isEqualToString:@"iPhone3,3"])   return @"Verizon iPhone 4";
    else if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
    else if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM)";
    else if ([platform isEqualToString:@"iPhone5,2"])   return @"iPhone 5 (GSM+CDMA)";
    else if ([platform isEqualToString:@"iPhone5,3"])   return @"iPhone 5c (GSM)";
    else if ([platform isEqualToString:@"iPhone5,4"])   return @"iPhone 5c (GSM+CDMA)";
    else if ([platform isEqualToString:@"iPhone6,1"])   return @"iPhone 5s (GSM)";
    else if ([platform isEqualToString:@"iPhone6,2"])   return @"iPhone 5s (GSM+CDMA)";
    else if ([platform isEqualToString:@"iPhone7,1"])   return @"iPhone 6";
    else if ([platform isEqualToString:@"iPhone7,2"])   return @"iPhone 6 Plus";
    else if ([platform containsString:@"iPhone"])       return @"iPhone New Generic";
    
    //iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    else if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    else if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    else if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    else if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    else if ([platform containsString:@"iPod"])     return @"iPod New Generic";
    
    //iPad
    else if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    else if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    else if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    else if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    else if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    else if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    else if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    else if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    else if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    else if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    else if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    else if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    else if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    else if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air (CDMA)";
    else if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    else if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (CDMA)";
    //iPad Mini
    else if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    else if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    else if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    else if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    else if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (CDMA)";
    else if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    else if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (CDMA)";
    else if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (CDMA)";
    else if ([platform containsString:@"iPad"])     return @"iPad New Generic";
    
    //simulator
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}


+ (NSString *) getDeviceTypeSimple{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1";
    else if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3";
    else if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3";
    else if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    else if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    else if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4";
    else if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    else if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    else if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5";
    else if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5";
    else if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5";
    else if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5";
    else if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6";
    else if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    else if ([platform containsString:@"iPhone"])       return @"iPhone New Generic";
    
    //iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1";
    else if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2";
    else if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3";
    else if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4";
    else if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5";
    else if ([platform containsString:@"iPod"])     return @"iPod New Generic";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    else if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    else if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    else if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    else if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    else if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    else if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    else if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    else if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    else if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    else if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    else if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    else if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    else if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    else if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    else if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    //iPad Mini
    else if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    else if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    else if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    else if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina";
    else if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina";
    else if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    else if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    else if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    else if ([platform containsString:@"iPad"])     return @"iPad New Generic";
    
    //simulator
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;

    return platform;
}


+ (CGSize) getDeviceResolutionLandscape{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPhone1,2"])    return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPhone2,1"])    return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPhone3,1"])    return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPhone3,3"])    return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPhone4,1"])    return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPhone5,1"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone5,2"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone5,3"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone5,4"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone6,1"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone6,2"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone7,1"])    return CGSizeMake(568, 320);
    else if ([platform isEqualToString:@"iPhone7,2"])    return CGSizeMake(568, 320);
    else if ([platform containsString:@"iPhone"])       return CGSizeMake(568, 320);
    
    //iPod
    else if ([platform isEqualToString:@"iPod1,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPod2,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPod3,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPod4,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPod5,1"])      return CGSizeMake(568, 320);
    else if ([platform containsString:@"iPod"])          return CGSizeMake(568, 320);
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad2,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad2,2"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad2,3"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad2,4"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad3,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad3,2"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad3,3"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad3,4"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad3,5"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad3,6"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,1"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,2"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,3"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad5,3"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad5,4"])      return CGSizeMake(480, 320);
    //iPad Mini
    else if ([platform isEqualToString:@"iPad2,5"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad2,6"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad2,7"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,4"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,5"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,7"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,8"])      return CGSizeMake(480, 320);
    else if ([platform isEqualToString:@"iPad4,9"])      return CGSizeMake(480, 320);
    else if ([platform containsString:@"iPad"])          return CGSizeMake(480, 320);
    
    NSString* model = [[UIDevice currentDevice] model];
    if(([model isEqualToString:@"iPhone Simulator"])) return CGSizeMake(568, 320);
    if(([model isEqualToString:@"iPad Simulator"]))   return CGSizeMake(1024,768);
    
    if([platform containsString:@"iPad"])
    {
        return CGSizeMake(480, 320);
    }
    if([platform containsString:@"iPod"] || [platform containsString:@"iPhone"])
    {
        return CGSizeMake(568, 320);
    }
    
    return CGSizeMake(568,320);
}



+ (BOOL) isIOS7{
   
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ([[vComp objectAtIndex:0] intValue] >= 7) {
        return YES;
    }
    else
    {
        return  NO;
    }
}

+ (CGSize) getDeviceResolutionPortrait{
    CGSize reso = [self getDeviceResolutionLandscape];
    reso = CGSizeMake(reso.height, reso.width);
    return reso;
    
}


@end
