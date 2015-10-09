//
//  FwFtpCreateDir.m
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwFtpCreateDir.h"
#import "FwString.h"

#include <CFNetwork/CFNetwork.h>

@interface FwFtpCreateDir () <NSStreamDelegate>

// Properties about ftp
@property (nonatomic, assign, readwrite) NSString *         userName;
@property (nonatomic, assign, readwrite) NSString *         passWord;
@property (nonatomic, assign, readwrite) NSString *         serverAddress;

// Properties about stream

@property (nonatomic, assign, readonly ) BOOL              isCreating;
@property (nonatomic, strong, readwrite) NSOutputStream *  networkStream;

@end

@implementation FwFtpCreateDir


NSString * const CreateDirStatusChangedNotification = @"Create Dir Status";

# pragma mark * Init

- (instancetype)init
{
    NSAssert(NO, @"Initializer not allowed. Use designated initializer initWithUsername:username:password:");
    return nil;
}

- (instancetype)initWithUserName:(NSString *)userName andPassWord:(NSString *)password andServerAddress:(NSString *)serverAddress {
    
    self = [super init];
    if (self) {
        self.userName = userName;
        self.passWord = password;
        self.serverAddress = serverAddress;
    }
    return self;
    
}

#pragma mark * Out methods

- (void)createFolder:(NSString *)folderName{
    
    //    assert(remoteFolder != nil);
    
    [self startCreate:folderName];
    
}


# pragma mark * Status

- (void)updateStatus:(NSString *)statusString{
    assert(statusString != nil);
    self.status = statusString;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //    NSLog(@"Sending notification");
    [nc postNotificationName:CreateDirStatusChangedNotification object:self];
}

// These methods are used by the core transfer code to update the UI.

- (void)createDidStart
{
    [self updateStatus:@"Setting"];
}


- (void)createDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Succeeded";
    }
    [self updateStatus:statusString];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)isCreating
{
    return (self.networkStream != nil);
}

- (void)startCreate: (NSString *) folderName
{
    BOOL                    success;
    NSURL *                 url;
    
    assert(self.networkStream == nil);      // don't tap create twice in a row!
    
    // First get and check the URL.
    
    url = [[FwString sharedInstance] smartURLForString:self.serverAddress];
    success = (url != nil);
    
    if (success) {
        // Add the directory name to the end of the URL to form the final URL
        // that we're going to create.  CFURLCreateCopyAppendingPathComponent will
        // percent encode (as UTF-8) any wacking characters, which is the right thing
        // to do in the absence of application-specific knowledge about the encoding
        // expected by the server.
        
        url = CFBridgingRelease(
                                CFURLCreateCopyAppendingPathComponent(NULL, (__bridge CFURLRef) url, (__bridge CFStringRef) folderName, true)
                                );
        success = (url != nil);
    }
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        [self updateStatus:@"Invalid URL"];
    } else {
        
        // Open a CFFTPStream for the URL.
        
        self.networkStream = CFBridgingRelease(
                                               CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url)
                                               );
        assert(self.networkStream != nil);
        
        success = [self.networkStream setProperty:self.userName forKey:(id)kCFStreamPropertyFTPUserName];
        assert(success);
        success = [self.networkStream setProperty:self.passWord forKey:(id)kCFStreamPropertyFTPPassword];
        assert(success);
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Tell the UI we're creating.
        
        [self createDidStart];
    }
}

- (void)stopCreateWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    [self createDidStopWithStatus:statusString];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self updateStatus:@"Opened connection"];
            // Despite what it says in the documentation <rdar://problem/7163693>,
            // you should wait for the NSStreamEventEndEncountered event to see
            // if the directory was created successfully.  If you shut the stream
            // down now, you miss any errors coming back from the server in response
            // to the MKD command.
            //
            // [self stopCreateWithStatus:nil];
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);
        } break;
        case NSStreamEventErrorOccurred: {
            CFStreamError   err;
            
            // -streamError does not return a useful error domain value, so we
            // get the old school CFStreamError and check it.
            
            err = CFWriteStreamGetError( (__bridge CFWriteStreamRef) self.networkStream );
            if (err.domain == kCFStreamErrorDomainFTP) {
//                [self stopCreateWithStatus:[NSString stringWithFormat:@"FTP error %d", (int) err.error]];
                [self stopCreateWithStatus:[NSString stringWithFormat:@""]];
            } else {
                [self stopCreateWithStatus:@"Stream open error"];
            }
        } break;
        case NSStreamEventEndEncountered: {
            [self stopCreateWithStatus:nil];
        } break;
        default: {
            assert(NO);
        } break;
    }
}





@end
