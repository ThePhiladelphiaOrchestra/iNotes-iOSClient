//
//  MulticastClient.h
//  MultiTest
//
//  Created by Matthew Prockup on 3/15/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//


//////////////
//          //
//  Usage   //
//          //
/////////////////////////////////////////////////////////////////////////////////////////////
//
//  Create the client:
//      MulticastClient* client = [[MulticastClient alloc] init];
//
//  Setup the multicast parameters
//      [client startMulticastListenerOnPort:12345 withAddress:@"239.254.254.251"];
//
//  Start the listener thread
//      [client startListen];
//
//  Poll for most recent reveived data
//      NSData* buffer = [client getCurrentData];
//
////////////////////////////////////////////////////////////////////////////////////////////




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include "NetworkCheck.h"
#define kBufferSize 250
#define kMaxSockets 16

@interface MulticastClient : NSObject
{
    int sock_fd;
    struct sockaddr_in addr;
    NSData* data;
    NSString* address;
    char* multicastAddress;
    int portNumber;
    NSMutableArray* fuckyeah;
    struct ip_mreq multicast_request;
    float soundFieldAdd;
    float soundFieldMult;
    BOOL socketOpen;
    BOOL listenStarted;
    BOOL pushShowing;
    NSString* previousPush;
    NSString* linkLocation;
}
-(BOOL)startMulticastListenerOnPort:(int)p withAddress:(NSString*)a; //setup the multicast session
-(void)startListen; //spawns a listener thread inside the object.  
-(NSData*)getCurrentData; //returns the latest data
-(NSMutableArray*)getCurrentLocations;
-(float)getSoundFieldMult;
-(float)getSoundFieldAdd;
-(void)closeSocket;
-(BOOL)isSocketOpen;
@property (retain) NSData* data;
@property (retain) NSString* previousPush;
@property (retain,nonatomic) NSString* linkLocation;
@property (assign) BOOL listenStarted;
@property (assign) BOOL socketOpen;

@end
