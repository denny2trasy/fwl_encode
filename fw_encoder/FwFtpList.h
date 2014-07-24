//
//  FwFtpList.h
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FwFtpList : NSObject

// Property about status
@property (nonatomic, assign, readwrite)  NSString *         status;
@property (nonatomic, strong, readwrite)  NSMutableArray *  listFolderName;


extern NSString * const ListStatusChangedNotification;

- (instancetype)initWithUserName:(NSString *)userName andPassWord:(NSString *)password andServerAddress:(NSString *)serverAddress;

// Methods

- (void)listFolder:(NSString *)remoteFolder;

@end
