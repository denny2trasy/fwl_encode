//
//  FwFileInfo.h
//  fw_encoder
//
//  Created by Lee Denny on 12/19/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FwFileInfo : NSObject

+ (NSURL *)smartURLForString:(NSString *)str;
+ (uint64_t) getFTPStreamSize:(CFReadStreamRef)stream;

+ (NSString*) pathForDocument;
+ (uint64_t) getFileSize:(NSString *)filePath;

@end
