//
//  MulticastClient.m
//  MultiTest
//
//  Created by Matthew Prockup on 3/15/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//
//  This implementation stems from a more general one I wrote. This one however, is specific to iNotes

#import "MulticastClient.h"

@implementation MulticastClient

@synthesize data,listenStarted,socketOpen,previousPush,linkLocation;


//Setup Multicast with a port and group address
-(BOOL)startMulticastListenerOnPort:(int)p withAddress:(NSString*)a
{
    //don't start multicast on 'cell' or 'no network'
    if([NetworkCheck whatIsMyConnectionType]==0 || [NetworkCheck whatIsMyConnectionType]==2)
    {
        return false;
    }
    
    signal(SIGPIPE, SIG_IGN);
    
    address = [[NSString alloc] initWithString:a];
    multicastAddress = (char*)[address UTF8String];
    portNumber = p;
    
    // Create socket
    sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
    if ( sock_fd == -1 ) {
        // Error occurred
        return false;
    }
    
    // Create address from which we want to receive, and bind it
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(portNumber);
    if ( bind(sock_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0 ) {
        // Error occurred
        return false;
    }
    
    // Obtain list of all network interfaces
    struct ifaddrs *addrs;
    if ( getifaddrs(&addrs) < 0 ) {
        // Error occurred
        return false;
    }
    
    // Loop through interfaces, selecting those AF_INET devices that support multicast, but aren't loopback or point-to-point
    const struct ifaddrs *cursor = addrs;
    while ( cursor != NULL ) {
        if ( cursor->ifa_addr->sa_family == AF_INET
            && !(cursor->ifa_flags & IFF_LOOPBACK)
            && !(cursor->ifa_flags & IFF_POINTOPOINT)
            &&  (cursor->ifa_flags & IFF_MULTICAST) )
        {
            
            // Prepare multicast group join request
            struct ip_mreq multicast_req;
            memset(&multicast_req, 0, sizeof(multicast_req));
            multicast_req.imr_multiaddr.s_addr = inet_addr(multicastAddress);
            multicast_req.imr_interface = ((struct sockaddr_in *)cursor->ifa_addr)->sin_addr;
            multicast_request = multicast_req;
            
            // Workaround for some odd join behaviour: It's perfectly legal to join the same group on more than one interface,
            // and up to 20 memberships may be added to the same socket (see ip(4)), but for some reason, OS X spews
            // 'Address already in use' errors when we actually attempt it.  As a workaround, we can 'drop' the membership
            // first, which would normally have no effect, as we have not yet joined on this interface.  However, it enables
            // us to perform the subsequent join, without dropping prior memberships.
            setsockopt(sock_fd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &multicast_req, sizeof(multicast_req));
            
            // Join multicast group on this interface
            if ( setsockopt(sock_fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &multicast_req, sizeof(multicast_req)) < 0 ) {
                // Error occurred
                return false;
            }
        }
        cursor = cursor->ifa_next;
    }
    NSLog(@"ready.");
    
    //init
    data = [[NSData alloc] init];
    previousPush = @""; //set previous push message text to ""
    socketOpen = YES; //the socket is open
    return true;
}

//spawn a thread that constantly listens for messages
-(void)startListen
{
    listenStarted = YES;
    [NSThread detachNewThreadSelector:@selector(listenLoop:) toTarget:self withObject:nil];
}


//Constatly listen for messages
//Check if they are PUSH or  measure updates
//Set the currentMeasure or throw push message alert
-(void)listenLoop:(id)param
{
    pushShowing = NO; //there is currently not a push message showing
    
    
    socklen_t addr_len = sizeof(addr);
    int cnt = 0;
    BOOL error = NO;
    
    //Listen continuously as long as the user requests and there is no receive error
    while(!error&&listenStarted)
    {
        // init date buffer to store received information
        float* buffer = (float*)calloc (kBufferSize, sizeof(float));
        // Receive a message, waiting if there's nothing there yet
        int bytes_received = recvfrom(sock_fd, buffer, sizeof(float)*kBufferSize, 0, (struct sockaddr*)&addr, &addr_len);
        if ( bytes_received < 0 ) {
            NSLog(@"error receiving");
            free(buffer);
            error=true;
        }
        else // we received some data
        {
            //Convert the buffer to NSData
            NSData* tempData = [NSData dataWithBytes:(const void *)buffer length:bytes_received];
            free(buffer);
            
            //Convert NSData to NSString
            NSString* tempString = [[NSString alloc] initWithData:tempData encoding:[NSString defaultCStringEncoding]];
            
            //Is it a PUSH notification message?
            if([tempString hasPrefix:@"PUSH"]){
                
                //The current push gets sent by the server every 10 packets or so. Make sure is not equal to the previous to prevent resending the same notification
                //Also, if the content is blank, don't show an empty message
                if((![tempString isEqualToString:previousPush])&&(![tempString isEqualToString:@"PUSH|||BUTTON||"])&&(![tempString isEqualToString:@"PUSH|||AUTO||"]))
                {
                    NSLog(@"RecievedPush:   %@",tempString);
                    
                    //set previous push to the current one
                    previousPush = [NSString stringWithString:tempString];
                    
                    //get the message components needed to compose the push message
                    NSArray* components = [tempString componentsSeparatedByString:@"|"];
                    if([components count] > 5)
                    {
                        NSString* title = [NSString stringWithString:[components objectAtIndex:1]];
                        NSString* body = [NSString stringWithString:[components objectAtIndex:2]];
                        NSString* buttonText;
                        UIAlertView * pushAlert;
                        
                        //This denotes a link style notification
                        if([title isEqualToString:@"Link"])
                        {
                            pushAlert = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Me There", nil];
                            
                            buttonText = [NSString stringWithString:[components objectAtIndex:4]];
                            [self performSelectorOnMainThread:@selector(setLinkLocation:) withObject:buttonText waitUntilDone:YES];
                            [self performSelectorOnMainThread:@selector(showLinkAlert:) withObject:pushAlert waitUntilDone:NO];
                            
                        }
                        //This is a Button message that includes a title and body
                        else if([[components objectAtIndex:3] isEqualToString:@"BUTTON"] && ((![body isEqualToString:@""]) || (![title isEqualToString:@""])))
                        {
                            buttonText = [NSString stringWithString:[components objectAtIndex:4]];
                            
                            //if the user of the CMS screws up and doesnt enter button text, pretend its an auto dismissed alert.
                            if([buttonText isEqualToString:@""])
                            {
                                buttonText = nil;
                                pushAlert = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil];
                                [self performSelectorOnMainThread:@selector(showDismissedAlert:) withObject:pushAlert waitUntilDone:NO];
                                sleep(2.0);
                            }
                            //compose the full push message
                            else{
                                pushAlert = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil];
                                [self performSelectorOnMainThread:@selector(showAlert:) withObject:pushAlert waitUntilDone:NO];
                            }
                            
                            
                        }
                        //If the title or body are not present...
                        else if((![body isEqualToString:@""]) || (![title isEqualToString:@""]))
                        {
                            buttonText = nil;
                            UIAlertView * pushAlert = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:buttonText otherButtonTitles:nil];
                            [self performSelectorOnMainThread:@selector(showDismissedAlert:) withObject:pushAlert waitUntilDone:NO];
                            sleep(2.0);
                        }
                    }
                    else
                    {
                        NSLog(@"Push error was not the correct format: PUSH|Message Title|MessageContent|{\'BUTTON\',\'AUTO\'}|ButtonText|");
                    }
                }
            }
            else if([tempString hasPrefix:@"CLEAR_PUSH"])
            {
                previousPush = @"";
            }
            //This is a regular message update. Set the current data to the received packet
            else
            {
                data = [NSData dataWithData:tempData];
            }
        }
        
        cnt++;
        
    }
    
    //There was an error, or the user asked to terminate listening by setting listenStarted = FALSE
    close(sock_fd);
    socketOpen = NO;
    
}

//show and alert and then dismiss it (used for AUTO alerts)
-(void)showDismissedAlert:(UIAlertView*)alert
{
    alert.tag = 0;
    [alert show];
    [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:5];
    
}

//show alert and let users interact (used for BUTTON alerts)
-(void)showAlert:(UIAlertView*)alert
{
    alert.tag = 0;
    [alert show];
    
}

//show alert that presents a link
-(void)showLinkAlert:(UIAlertView*)alert
{
    alert.tag = 1;
    [alert show];
}

//used to auto dismiss alerts
-(void)dismissAlert:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

//if its a link alert, and they clicked "take me there", navigate to that link in safari outside of the app
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 1 && buttonIndex==1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkLocation]];
    }
}

-(void) setLinkLocation:(NSString*)location
{
    linkLocation = location;
}

//Allow user to access current data. Non blocking way to access the most recent data at any time without having to sit and wait for the most recent packet
-(NSData*)getCurrentData
{
    NSData* copy = [[NSData alloc] initWithData:data];
    return copy;
}

//stop listen loop
-(void)closeSocket
{
    listenStarted = NO;
}

//force shut the connection
-(void)closeActualSocket
{
    close(sock_fd);
    socketOpen = NO;

}

//check if the socket is open and receiveing data
-(BOOL)isSocketOpen{
    return socketOpen;
}



@end
