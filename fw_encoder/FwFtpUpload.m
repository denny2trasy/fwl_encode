//
//  FwFtpUpload.m
//  fw_encoder
//
//  Created by Lee Denny on 7/18/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwFtpUpload.h"
#import "FwString.h"

#include <CFNetwork/CFNetwork.h>

enum{
    kSendBufferSize = 32768
};


@interface FwFtpUpload () <NSStreamDelegate> 

// Properties about ftp
@property (nonatomic, assign, readwrite) NSString *         userName;
@property (nonatomic, assign, readwrite) NSString *         passWord;
@property (nonatomic, assign, readwrite) NSString *         serverAddress;

// Properties about stream
@property (nonatomic, strong, readwrite) NSOutputStream *   networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *    fileStream;
@property (nonatomic, assign, readonly)  uint8_t *          buffer;
@property (nonatomic, assign, readwrite) size_t             bufferOffset;
@property (nonatomic, assign, readwrite) size_t             bufferLimit;




@end




@implementation FwFtpUpload
{
    uint8_t                     _buffer[kSendBufferSize];
}

NSString * const UploadStatusChangedNotification = @"Upload Status";

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

- (void)uploadFile:(NSString *)localFile toRemote:(NSString *)remoteFile{
    
    assert(localFile != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:localFile]);
//    assert([localFile.pathExtension isEqual:@"mp4"]);
    
    [self startSend:localFile toRemote:remoteFile];
    
}

- (void)cancelUpload:(NSString *)statusString
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self updateStatus:statusString];
}


# pragma mark * Status

- (void)updateStatus:(NSString *)statusString{
    assert(statusString != nil);
    self.status = statusString;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    NSLog(@"Sending notification");
    [nc postNotificationName:UploadStatusChangedNotification object:self];
}


#pragma mark * Core transfer code

// This is the code that actually does the networking.

// Because buffer is declared as an array, you have to use a custom getter.
// A synthesised getter doesn't compile.

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)isSending
{
    return (self.networkStream != nil);
}


- (void)startSend:(NSString *)localFile toRemote:(NSString *)remoteFile{
 
    BOOL success;
    NSURL * url;
    
    assert(self.networkStream == nil);
    assert(self.fileStream == nil);
    
    url = [[FwString sharedInstance] smartURLForString:self.serverAddress];
    success = (url != nil);
    
    if (success) {
        // Add the last part of the file name to the end of the URL to form the final
        // URL that we're going to put to.
        
        NSLog(@"remote file - %@", remoteFile);
                
        url = CFBridgingRelease(
                                CFURLCreateCopyAppendingPathComponent(NULL, (__bridge CFURLRef) url, (__bridge CFStringRef) remoteFile, false)
                                );
        success = (url != nil);
        
        NSLog(@"remoteFile lastComponent - %@", [remoteFile lastPathComponent]);

        NSLog(@"Upload url - %@", url);
    }
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.status = @"Invalid URL";
    } else {
        
        // Open a stream for the file we're going to send.  We do not open this stream;
        // NSURLConnection will do it for us.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:localFile];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
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
        
        
        [self updateStatus:@"Start"];
    }
    
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
            NSLog(@"Opened connection");
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            [self updateStatus:@"Sending..."];
            NSLog(@"Sending...");
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self updateStatus:@"File read error"];
                    NSLog(@"File read error");
                } else if (bytesRead == 0) {
                    [self updateStatus:@"Upload succeeded"];
                    NSLog(@"Upload succeeded");
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self updateStatus:@"Network write error"];
                    NSLog(@"Network write error");
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self updateStatus:@"Stream open error"];
            NSLog(@"Stream open error");
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}



@end
