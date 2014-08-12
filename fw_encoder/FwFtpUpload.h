//
//  FwFtpUpload.h
//  fw_encoder
//
//  Created by Lee Denny on 7/18/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FwFtpUpload : NSObject

// Property about status
@property (nonatomic, assign, readwrite)  NSString *         status;

extern NSString * const UploadStatusChangedNotification;

- (instancetype)initWithUserName:(NSString *)userName andPassWord:(NSString *)password andServerAddress:(NSString *)serverAddress andFiles: (NSMutableArray *)files;

// Methods
- (void)uploadFile:(NSString *)localFile toRemote:(NSString *)remoteFile;
- (void)uploadFileAtFirstPlace;
- (void)cancelUpload:(NSString *)statuString;
- (BOOL)isSending;


@end
