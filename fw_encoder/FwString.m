//
//  FwString.m
//  fw_encoder
//
//  Created by Lee Denny on 7/15/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwString.h"

@implementation FwString

+ (FwString *)sharedInstance{
    
    static dispatch_once_t onceToken;
    static FwString * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[FwString alloc]  init];
    });
    
    return sSharedInstance;
    
}

# pragma FTP methods

- (NSURL *)smartURLForString:(NSString *)str{
  
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && ([trimmedStr length] != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
    
    
}

# pragma String File methods

- (NSString *)getExtensionFromPath:(NSString *)fullPath{
        
    NSArray *paths = [fullPath componentsSeparatedByString:@"/"];
    
    long int count = [paths count];
    
    if (count > 0) {
        
        NSString *lastPath = [paths objectAtIndex:(count - 1)];
        
        NSArray *name = [lastPath componentsSeparatedByString:@"."];
            
        if ([name count] > 0) {
            NSString *extension = [name objectAtIndex:([name count] - 1)];
            return extension;
        }    
    }  
    
    return nil;
}

- (NSString *)getFileNameFromPath:(NSString *)fullPath{
    
    NSArray *paths = [fullPath componentsSeparatedByString:@"/"];
    
    long int count = [paths count];
    
    if (count > 0) {
        
        NSString *lastPath = [paths objectAtIndex:(count - 1)];
        
        NSArray *name = [lastPath componentsSeparatedByString:@"."];
        
        if ([name count] > 0) {
            NSString *fileName = [name objectAtIndex:0];
            
            return fileName;
        }
    }
    
    return nil;
}

- (NSString *)generateMP4FileFullPath:(NSString *)outPutPath withFileName:(NSString *)fileName {
    
    NSString *fullPath;
    
    NSString *filePath = [NSString stringWithFormat:@"%@.mp4",fileName];
    
    NSArray *item = [NSArray arrayWithObjects:outPutPath,filePath,nil];
    
    fullPath = [NSString pathWithComponents:item];
    
    return fullPath;
}

- (NSString *)generateMP4FileFullPath:(NSString *)outPutPath withFileName:(NSString *)fileName andNumber:(int)number{
    
    NSString *fullPath;
    
    NSString *filePath = [NSString stringWithFormat:@"%@_%d.mp4",fileName,number];
    
    NSArray *item = [NSArray arrayWithObjects:outPutPath,filePath,nil];
    
    fullPath = [NSString pathWithComponents:item];
    
    return fullPath;
}


# pragma Encode methods

-(NSArray *)getEncodeArgumentsForFlo2Screen:(NSString *)inputFile with:(NSString *)outputFile andFormat:(NSString *)format {
    
    NSString *lowerFormat = [format lowercaseString];
    
    if ([lowerFormat isEqualToString:@"mov"]) {        
        return [self argumentsForFlo2ScreenMov:inputFile with:outputFile];        
    }
    
    if ([lowerFormat isEqualToString:@"ts"]) {
        return [self argumentsForFlo2ScreenTs:inputFile with:outputFile];
    }
    
    if ([lowerFormat isEqualToString:@"avi"]) {
        return [self argumentsForFlo2ScreenAvi:inputFile with:outputFile];
    }
    
    if ([lowerFormat isEqualToString:@"mp4"]) {
        return [self argumentsForFlo2ScreenMp4:inputFile with:outputFile];
    }
    
    return nil;
    
}

- (NSArray *)argumentsForFlo2ScreenMov:(NSString *)fromFile with:(NSString *)toFile{
    
    // -e x264 --x264-profile baseline -x level=3.0 -w 1280 -l 720 -r 15 -b 2000
    //--two-pass --turbo --decomb --crop 0:0:0:0 -R 24 -B 32"
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"1280",
                 @"-l",
                 @"720",
                 @"-r",
                 @"15",
                 @"-b",
                 @"2000",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"--crop",
                 @"0:0:0:0",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;  
    
}

- (NSArray *)argumentsForFlo2ScreenTs:(NSString *)fromFile with:(NSString *)toFile{
    
    //-e x264 --x264-profile baseline -x level=3.0 -w 1280 -l 720 -r 15 -b 2000
    //--two-pass --turbo --decomb --crop 0:0:0:0 -R 24 -B 32
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"1280",
                 @"-l",
                 @"720",
                 @"-r",
                 @"15",
                 @"-b",
                 @"2000",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"--crop",
                 @"0:0:0:0",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;
}

- (NSArray *)argumentsForFlo2ScreenAvi:(NSString *)fromFile with:(NSString *)toFile{
    
    //-e x264 --x264-profile baseline -x level=3.0 -w 1280 -l 720 -r 15 -b 2000
    //--two-pass --turbo --decomb --crop 0:0:0:0 -R 24 -B 32
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"1280",
                 @"-l",
                 @"720",
                 @"-r",
                 @"15",
                 @"-b",
                 @"2000",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"--crop",
                 @"0:0:0:0",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;
}

- (NSArray *)argumentsForFlo2ScreenMp4:(NSString *)fromFile with:(NSString *)toFile{
    
    //-e x264 --x264-profile baseline -x level=3.0 -w 1280 -l 720 -r 15 -b 2000
    //--two-pass --turbo --decomb --crop 0:0:0:0 -R 24 -B 32
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"1280",
                 @"-l",
                 @"720",
                 @"-r",
                 @"15",
                 @"-b",
                 @"2000",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"--crop",
                 @"0:0:0:0",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;
    
}

- (NSArray *)getEncodeArgumentsForGloo:(NSString *)inputFile with:(NSString *)outputFile andNumber:(int)number{
    
    
    if (number == 1) {
        return [self argumentsForGlooOne:inputFile with:outputFile];
    }
    
    if (number == 2) {
        return [self argumentsForGlooTwo:inputFile with:outputFile];
    }
    
    if (number == 3) {
        return [self argumentsForGlooThree:inputFile with:outputFile];
    }
    
    return nil;   
}

- (NSArray *)argumentsForGlooOne:(NSString *)fromFile with:(NSString *)toFile{
    
    //-e x264 --x264-profile baseline -x level=3.0 -w 1024 -l 576 -r 15 -b 600 --two-pass --turbo --decomb -R 24 -B 32
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"1024",
                 @"-l",
                 @"576",
                 @"-r",
                 @"15",
                 @"-b",
                 @"600",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;
}

- (NSArray *)argumentsForGlooTwo:(NSString *)fromFile with:(NSString *)toFile{
    
    //-e x264 --x264-profile baseline -x level=3.0 -w 1280 -l 720 -r 15 -b 800 --two-pass --turbo --decomb -R 24 -B 32
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"1280",
                 @"-l",
                 @"720",
                 @"-r",
                 @"15",
                 @"-b",
                 @"800",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;
}

- (NSArray *)argumentsForGlooThree:(NSString *)fromFile with:(NSString *)toFile{
    
    //-e x264 --x264-profile baseline -x level=3.0 -w 640 -l 360 -r 15 -b 300 --two-pass --turbo --decomb -R 24 -B 32
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:
                 @"-i",
                 fromFile,
                 @"-o",
                 toFile,
                 @"-e",
                 @"x264",
                 @"--x264-profile",
                 @"baseline",
                 @"-x",
                 @"level=3.0",
                 @"-w",
                 @"640",
                 @"-l",
                 @"360",
                 @"-r",
                 @"15",
                 @"-b",
                 @"300",
                 @"--two-pass",
                 @"--turbo",
                 @"--decomb",
                 @"-R",
                 @"24",
                 @"-B",
                 @"32", nil];
    return arguments;
}


# pragma Encode result

- (NSString *)formatEncodingResult:(NSString *)outputString{
    
    NSArray *temp = [outputString componentsSeparatedByString:@"("];
    
    NSString *item = [temp objectAtIndex:0];
    
    return [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
}


@end
