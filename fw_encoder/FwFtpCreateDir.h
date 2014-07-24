//
//  FwFtpCreateDir.h
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FwFtpCreateDir : NSObject

// Property about status
@property (nonatomic, assign, readwrite)  NSString *         status;


extern NSString * const CreateDirStatusChangedNotification;

- (instancetype)initWithUserName:(NSString *)userName andPassWord:(NSString *)password andServerAddress:(NSString *)serverAddress;

// Methods

- (void)createFolder:(NSString *)folderName;

@end
