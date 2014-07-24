//
//  FwString.h
//  fw_encoder
//
//  Created by Lee Denny on 7/15/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FwString : NSObject

+ (FwString *)sharedInstance;

- (NSURL *)smartURLForString:(NSString *)str;


- (NSString *)getExtensionFromPath:(NSString *)fullPath;
- (NSString *)getFileNameFromPath:(NSString *)fullPath;
- (NSString *)generateMP4FileFullPath:(NSString *)outPutPath withFileName:(NSString *)fileName;
- (NSString *)generateMP4FileFullPath:(NSString *)outPutPath withFileName:(NSString *)fileName andNumber:(int)number;
- (NSArray *)getEncodeArgumentsForFlo2Screen:(NSString *)inputFile with:(NSString *)outputFile andFormat:(NSString *)format;
- (NSArray *)getEncodeArgumentsForGloo:(NSString *)inputFile with:(NSString *)outputFile andNumber:(int)number;

- (NSString *)formatEncodingResult:(NSString *)outputString;

@end

