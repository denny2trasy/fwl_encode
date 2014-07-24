//
//  FwFtpList.m
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwFtpList.h"
#import "FwString.h"

#include <CFNetwork/CFNetwork.h>

@interface FwFtpList () <NSStreamDelegate>

// Properties about ftp
@property (nonatomic, assign, readwrite) NSString *         userName;
@property (nonatomic, assign, readwrite) NSString *         passWord;
@property (nonatomic, assign, readwrite) NSString *         serverAddress;

// Properties about stream
@property (nonatomic, assign, readonly ) BOOL              isReceiving;
@property (nonatomic, strong, readwrite) NSInputStream *   networkStream;
@property (nonatomic, strong, readwrite) NSMutableData *   listData;
@property (nonatomic, strong, readwrite) NSMutableArray *  listEntries;




@end


@implementation FwFtpList



NSString * const ListStatusChangedNotification = @"List Status";

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
        self.listEntries = [NSMutableArray array];
    }
    return self;
    
}

#pragma mark * Out methods

- (void)listFolder:(NSString *)remoteFolder{
    
//    assert(remoteFolder != nil);
  
    [self startReceive:remoteFolder];
    
}


# pragma mark * Status

- (void)updateStatus:(NSString *)statusString{
    assert(statusString != nil);
    self.status = statusString;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //    NSLog(@"Sending notification");
    [nc postNotificationName:ListStatusChangedNotification object:self];
}

- (void)addListEntries:(NSArray *)newEntries
{
    assert(self.listEntries != nil);
    
    [[self listEntries] addObjectsFromArray:newEntries];
    
    [self extractFolderFromEntries];

}

- (void)extractFolderFromEntries{
    
    NSNumber *          typeNum;
    int                 type;
    NSDictionary *      listEntry;
    self.listFolderName = [NSMutableArray array];
    long int count = [[self listEntries] count];
    
    if (count > 0) {
        
        for (int i = 0; i < count; i++) {
            
            listEntry = [self.listEntries objectAtIndex:i];
            assert([listEntry isKindOfClass:[NSDictionary class]]);
            
            // The first line of the cell is the item name.
            
            NSString *fName = [listEntry objectForKey:(id) kCFFTPResourceName];
            
            // Use the second line of the cell to show various attributes.
            
            typeNum = [listEntry objectForKey:(id) kCFFTPResourceType];
            if (typeNum != nil) {
                assert([typeNum isKindOfClass:[NSNumber class]]);
                type = [typeNum intValue];
            } else {
                type = 0;
            }
            
            if (type == 4) {
                [[self listFolderName] addObject:fName];
            }            
            
        }
    }
    
}

- (void)receiveDidStart
{
    // Clear the current image so that we get a nice visual cue if the receive fails.
    [self.listEntries removeAllObjects];

    [self updateStatus:@"Start"];

}




#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)isReceiving
{
    return (self.networkStream != nil);
}

- (void)startReceive: (NSString *)remoteFolder
// Starts a connection to download the current URL.
{
    BOOL                success;
    NSURL *             url;
    
    assert(self.networkStream == nil);      // don't tap receive twice in a row!
    
    // First get and check the URL.
    
    NSString *remoteURL = [NSString stringWithFormat:@"%@/%@", self.serverAddress, remoteFolder];
    
    url = [[FwString sharedInstance] smartURLForString:remoteURL];
    NSLog(@"URL for list - %@", url);
    
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        [self updateStatus:@"Invalid URL"];
    } else {
        
        // Create the mutable data into which we will receive the listing.
        
        self.listData = [NSMutableData data];
        assert(self.listData != nil);
        
        // Open a CFFTPStream for the URL.
        
        self.networkStream = CFBridgingRelease(
                                               CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url)
                                               );
        assert(self.networkStream != nil);
        
        success = [self.networkStream setProperty:self.userName forKey:(id)kCFStreamPropertyFTPUserName];
        assert(success);
        success = [self.networkStream setProperty:self.passWord forKey:(id)kCFStreamPropertyFTPPassword];
        assert(success);
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Tell the UI we're receiving.
        
        [self receiveDidStart];

    }
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"List succeeded";
    }
    [self updateStatus:statusString];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil)
// or the error status (otherwise).
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
    self.listData = nil;
}

- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding
// CFFTPCreateParsedResourceListing always interprets the file name as MacRoman,
// which is clearly bogus <rdar://problem/7420589>.  This code attempts to fix
// that by converting the Unicode name back to MacRoman (to get the original bytes;
// this works because there's a lossless round trip between MacRoman and Unicode)
// and then reconverting those bytes to Unicode using the encoding provided.
{
    NSDictionary *  result;
    NSString *      name;
    NSData *        nameData;
    NSString *      newName;
    
    newName = nil;
    
    // Try to get the name, convert it back to MacRoman, and then reconvert it
    // with the preferred encoding.
    
    name = [entry objectForKey:(id) kCFFTPResourceName];
    if (name != nil) {
        assert([name isKindOfClass:[NSString class]]);
        
        nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
        if (nameData != nil) {
            newName = [[NSString alloc] initWithData:nameData encoding:newEncoding];
        }
    }
    
    // If the above failed, just return the entry unmodified.  If it succeeded,
    // make a copy of the entry and replace the name with the new name that we
    // calculated.
    
    if (newName == nil) {
        assert(NO);                 // in the debug builds, if this fails, we should investigate why
        result = (NSDictionary *) entry;
    } else {
        NSMutableDictionary *   newEntry;
        
        newEntry = [entry mutableCopy];
        assert(newEntry != nil);
        
        [newEntry setObject:newName forKey:(id) kCFFTPResourceName];
        
        result = newEntry;
    }
    
    return result;
}

- (void)parseListData
{
    NSMutableArray *    newEntries;
    NSUInteger          offset;
    
    // We accumulate the new entries into an array to avoid a) adding items to the
    // table one-by-one, and b) repeatedly shuffling the listData buffer around.
    
    newEntries = [NSMutableArray array];
    assert(newEntries != nil);
    
    offset = 0;
    do {
        CFIndex         bytesConsumed;
        CFDictionaryRef thisEntry;
        
        thisEntry = NULL;
        
        assert(offset <= [self.listData length]);
        bytesConsumed = CFFTPCreateParsedResourceListing(NULL, &((const uint8_t *) self.listData.bytes)[offset], (CFIndex) ([self.listData length] - offset), &thisEntry);
        if (bytesConsumed > 0) {
            
            // It is possible for CFFTPCreateParsedResourceListing to return a
            // positive number but not create a parse dictionary.  For example,
            // if the end of the listing text contains stuff that can't be parsed,
            // CFFTPCreateParsedResourceListing returns a positive number (to tell
            // the caller that it has consumed the data), but doesn't create a parse
            // dictionary (because it couldn't make sense of the data).  So, it's
            // important that we check for NULL.
            
            if (thisEntry != NULL) {
                NSDictionary *  entryToAdd;
                
                // Try to interpret the name as UTF-8, which makes things work properly
                // with many UNIX-like systems, including the Mac OS X built-in FTP
                // server.  If you have some idea what type of text your target system
                // is going to return, you could tweak this encoding.  For example,
                // if you know that the target system is running Windows, then
                // NSWindowsCP1252StringEncoding would be a good choice here.
                //
                // Alternatively you could let the user choose the encoding up
                // front, or reencode the listing after they've seen it and decided
                // it's wrong.
                //
                // Ain't FTP a wonderful protocol!
                
                entryToAdd = [self entryByReencodingNameInEntry:(__bridge NSDictionary *) thisEntry encoding:NSUTF8StringEncoding];
                
                [newEntries addObject:entryToAdd];
            }
            
            // We consume the bytes regardless of whether we get an entry.
            
            offset += (NSUInteger) bytesConsumed;
        }
        
        if (thisEntry != NULL) {
            CFRelease(thisEntry);
        }
        
        if (bytesConsumed == 0) {
            // We haven't yet got enough data to parse an entry.  Wait for more data
            // to arrive.
            break;
        } else if (bytesConsumed < 0) {
            // We totally failed to parse the listing.  Fail.
            [self stopReceiveWithStatus:@"Listing parse failed"];
            break;
        }
    } while (YES);
    
    if ([newEntries count] != 0) {
        [self addListEntries:newEntries];
    }
    if (offset != 0) {
        [self.listData replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
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
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSInteger       bytesRead;
            uint8_t         buffer[32768];
            
            [self updateStatus:@"Receiving..."];
            
            // Pull some data off the network.
            
            bytesRead = [self.networkStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead < 0) {
                [self stopReceiveWithStatus:@"Network read error"];
            } else if (bytesRead == 0) {
                [self parseListData];
                [self stopReceiveWithStatus:nil];
            } else {
                assert(self.listData != nil);
                
                // Append the data to our listing buffer.
                
                [self.listData appendBytes:buffer length:(NSUInteger) bytesRead];
                
                // Check the listing buffer for any complete entries and update
                // the UI if we find any.
                
                [self parseListData];                
                
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopReceiveWithStatus:@"Stream open error"];
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
