//
//  HomeViewController.m
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "HomeViewController.h"
#import "FwString.h"
#import "FwFtpUpload.h"
#import "FwFtpList.h"
#import "FwFtpCreateDir.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

NSTask *task;
NSPipe *unixStandardOutputPipe;
NSPipe *unixStandardErrorPipe;
NSPipe *unixStandardInputPipe;
NSFileHandle *fhOutput;
NSFileHandle *fhError;
NSData *standardOutputData;
NSData *standardErrorData;

FwFtpUpload *ftpUpload;
FwFtpList *ftpList;
FwFtpCreateDir  *ftpCreateDir;

- (id)init{
    
    self = [super initWithNibName:@"HomeView" bundle:nil];
    
    if (self) {
        [self setTitle:@"Home"];
        [self setDefaultSettingValues];
    }
    return self;
}

- (void)setDefaultSettingValues{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"fw_encode.plist"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:appFile]) {
        NSArray *myData = [[[NSArray alloc] initWithContentsOfFile:appFile] autorelease];
        
        NSArray *temp = [myData objectAtIndex:0];
        
        self.defaultFolder = (NSString *)[temp objectAtIndex:0];
        self.defaultFTPUser = (NSString *)[temp objectAtIndex:1];
        self.defaultFTPDomain = (NSString *)[temp objectAtIndex:2];
        
        NSLog(@"default Foloder from file = %@", self.defaultFolder);
        NSLog(@"default FTPUser from file = %@", self.defaultFTPUser);
        NSLog(@"default FTPDomain from file = %@", self.defaultFTPDomain);
    }
}


# pragma btn Action for Encode

- (IBAction)cancelEncode:(id)sender{
    
    if (task) {
        NSLog(@"task terminate by manually");
        [task terminate];
        [encodeStatus setStringValue:@"encode terminated, not finish"];
    }
}

- (IBAction)clearEncode:(id)sender{
    
    NSTextStorage *TextStorage = [encodeAreaFiles textStorage];
    [TextStorage deleteCharactersInRange:NSMakeRange(0, [TextStorage length])];
}

- (IBAction)startEncode:(id)sender{
    
    [self setDefaultSettingValues];
    
    // 1. get file Format for encoding
    NSString *fileFormat = [encodeFormatList titleOfSelectedItem];
    
    NSLog(@"File format : %@", fileFormat);
    
    // 2. get file from area list
    NSString *inputFileList = [[encodeAreaFiles textStorage] string];
    
    NSLog(@"input File : %@", inputFileList);
    
    NSArray *fileItems = [inputFileList componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    long int fileCount = [fileItems count];
    
    NSLog(@"input line number %ld",fileCount);
    
    
    if (fileCount > 0) {       
        
        
        for (int i = 0; i < fileCount; i++) {
            
            NSString *inputFile = [fileItems objectAtIndex:i];
            
            NSString *fileExt = [[FwString sharedInstance] getExtensionFromPath:inputFile];
            
            if ([[fileExt lowercaseString] isEqualToString:[fileFormat lowercaseString]]) {
                
                [self encodeFileForFlo2Screen:inputFile with:fileFormat];
                                
            }else{
                [encodeStatus setStringValue:@"Please choose correct file with correct format"];
            }

        }        
        
    }
    
}

 // encode for Flo2Screen
- (void)encodeFileForFlo2Screen:(NSString *)inputFile with:(NSString *)fileFormat{   
 
    
    // run task to encode
    
    task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/usr/bin/HandBrakeCLI"];
    
    // get and set Arguments base on inputFile and fileFormat
    
    NSString *outputPath = self.defaultFolder;
    
    NSString *fileName = [[FwString sharedInstance] getFileNameFromPath:inputFile];
    
    NSString *outPutFile = [[FwString sharedInstance] generateMP4FileFullPath:outputPath withFileName:fileName];
    
    NSLog(@"OutputFile full path is : %@", outPutFile);
    
    NSArray *arguments = [[FwString sharedInstance] getEncodeArgumentsForFlo2Screen:inputFile with:outPutFile andFormat:fileFormat];
    
    [task setArguments:arguments];    
    
    // task notification
    
    unixStandardOutputPipe = [[NSPipe alloc] init];
    //unixStandardErrorPipe = [[NSPipe alloc] init];
    
    fhOutput = [unixStandardOutputPipe fileHandleForReading];
    //fhError = [unixStandardErrorPipe fileHandleForReading];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(notifiedForStdOutput:) name:NSFileHandleReadCompletionNotification object:fhOutput];
    //[nc addObserver:self selector:@selector(notifiedForStdError:) name:NSFileHandleReadCompletionNotification object:fhError];
    //[nc addObserver:self selector:@selector(notifiedForComplete:) name:NSTaskDidTerminateNotification object:task];
    
    [task setStandardOutput:unixStandardOutputPipe];
    //[task setStandardError:unixStandardErrorPipe];
    
    [task setTerminationHandler: ^(NSTask *task){
        
        int status = [task terminationStatus];
        
        if (status == 0){
            
            NSLog(@"Task [%@] - [%d] succeeded.", inputFile , [task processIdentifier]);
            
            NSString *txtOutPutFile = [outPutFile stringByAppendingString:@"\r\n"];
            
            [[[uploadAreaFile textStorage] mutableString] appendString: txtOutPutFile];
            
            NSString *lineResult =@"Success";
            
            [encodeStatus setStringValue:lineResult];
            
        }else {
            NSLog(@"Task [%@] - [%d] failed.", inputFile, [task processIdentifier]);
        }
        
    }];
    
//    NSLog(@"Task arguments is : %@", [task arguments]);
    
    [task launch];    
    
    [fhOutput readInBackgroundAndNotify];
    //[fhError readInBackgroundAndNotify];
    
    [task release];

    
}

// encode for Gloo
- (void)encodeFileForGloo:(NSString *)inputFile with:(NSString *)fileFormat{
    
    // run task to encode
    
    task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/usr/bin/HandBrakeCLI"];
    
    // get and set Arguments base on inputFile and fileFormat
    
    NSString *outputPath = self.defaultFolder;
    
    NSString *fileName = [[FwString sharedInstance] getFileNameFromPath:inputFile];
    
    
    for (int i = 1; i < 4; i++) {
        
        NSString *outPutFile = [[FwString sharedInstance] generateMP4FileFullPath:outputPath withFileName:fileName andNumber:i];
        
        NSLog(@"OutputFile full path is : %@", outPutFile);
        
        NSArray *arguments = [[FwString sharedInstance] getEncodeArgumentsForGloo:inputFile with:outPutFile andNumber:i];
        
        if (![arguments isEqualTo:nil]) {
            
            [task setArguments:arguments];
            
            // task notification
            
            unixStandardOutputPipe = [[NSPipe alloc] init];
            //unixStandardErrorPipe = [[NSPipe alloc] init];
            
            fhOutput = [unixStandardOutputPipe fileHandleForReading];
            //fhError = [unixStandardErrorPipe fileHandleForReading];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            [nc addObserver:self selector:@selector(notifiedForStdOutput:) name:NSFileHandleReadCompletionNotification object:fhOutput];
            //[nc addObserver:self selector:@selector(notifiedForStdError:) name:NSFileHandleReadCompletionNotification object:fhError];
            //[nc addObserver:self selector:@selector(notifiedForComplete:) name:NSTaskDidTerminateNotification object:task];
            
            [task setStandardOutput:unixStandardOutputPipe];
            //[task setStandardError:unixStandardErrorPipe];
            
            [task setTerminationHandler: ^(NSTask *task){
                
                int status = [task terminationStatus];
                
                if (status == 0){
                    
                    NSLog(@"Task [%@] - [%d] succeeded.", inputFile , [task processIdentifier]);
                    
                    NSString *txtOutPutFile = [outPutFile stringByAppendingString:@"\r\n"];
                    
                    [[[uploadAreaFile textStorage] mutableString] appendString: txtOutPutFile];
                    
                    NSString *lineResult =@"Success";
                    
                    [encodeStatus setStringValue:lineResult];
                    
                }else {
                    NSLog(@"Task [%@] - [%d] failed.", inputFile, [task processIdentifier]);
                }
                
            }];
            
            NSLog(@"Task arguments is : %@", [task arguments]);
            
            [task launch];
            
            [fhOutput readInBackgroundAndNotify];
            //[fhError readInBackgroundAndNotify];
            
            [task release];
        }
        
    }
    
}


# pragma notification for Encode

- (void)notifiedForStdOutput: (NSNotification *)notified{
    
    NSData * data = [[notified userInfo] valueForKey:NSFileHandleNotificationDataItem];
    //    NSLog(@"standard data ready %ld bytes",data.length);
    
    if ([data length]){
        
        NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![outputString isEqualToString:@""]) {
            NSString *formatOutputString = [[FwString sharedInstance] formatEncodingResult:outputString];
            [encodeStatus setStringValue:formatOutputString];
            NSLog(@"-- data : %@", outputString);
        }
        
    }
    
    if (task != nil) {
        
        [fhOutput readInBackgroundAndNotify];
    }
    
}


- (void)notifiedForStdError: (NSNotification *)notified{
    
    NSData * data = [[notified userInfo] valueForKey:NSFileHandleNotificationDataItem];
    NSLog(@"standard error ready %ld bytes",data.length);
    
    if ([data length]) {
        
        NSString * outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [encodeStatus setStringValue:outputString];
        NSLog(@"-- error : %@", outputString);
    }
    
    if (task != nil) {
        
        [fhError readInBackgroundAndNotify];
    }
    
}


- (void)notifiedForComplete: (NSNotification *)anotificatied{
    
    NSLog(@"task completed or was stopped with exit code %d",[task terminationStatus]);
    task = nil;
    
    //    [operationProgress stopAnimation:self];
    //    [operationProgress viewDidHide];
    
    if ([task terminationStatus] == 0) {
        [encodeStatus setStringValue:@"Success"];
    }
    else {
        [encodeStatus setStringValue:@"Terminated with non-zero exit code"];
    }
    
}


# pragma btn Action for Upload

- (IBAction)cancelUpload:(id)sender{
    
    [ftpUpload cancelUpload:@"Upload Cancelled"];
    
}

- (IBAction)clearUpload:(id)sender{
    
    NSTextStorage *TextStorage = [uploadAreaFile textStorage];
    [TextStorage deleteCharactersInRange:NSMakeRange(0, [TextStorage length])];
    
}

- (IBAction)startUpload:(id)sender{
    
    
    if ([self checkFtpSetting] && [self checkPassword]) {
        
        // base on outPut area add uplaoding request to ftp server
        
        NSString *localFileList = [[uploadAreaFile textStorage] string];
        
        NSArray *fileItems = [localFileList componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSLog(@"Local File List = %@", fileItems);
        
        long int count = [fileItems count];
        
                
        if (count > 0) {
            
            NSLog(@"input upload file count : %ld",count);
            
            NSString *channelFolder = [channelFolderList titleOfSelectedItem];
            
            NSLog(@"Channel folder = %@",channelFolder);
            
            NSString *preProgram =@"Program_";
            
            // get all folder in channelFolder
            
            ftpList = [[FwFtpList alloc]  initWithUserName:self.defaultFTPUser andPassWord:self.defaultFTPPwd andServerAddress:self.defaultFTPDomain];
            
            [ftpList listFolder:channelFolder];
            
            NSArray *programFolderList = [ftpList listFolderName];
            
            
            ftpCreateDir = [[FwFtpCreateDir alloc]  initWithUserName:self.defaultFTPUser andPassWord:self.defaultFTPPwd andServerAddress:self.defaultFTPDomain];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            
            ftpUpload = [[FwFtpUpload alloc] initWithUserName:self.defaultFTPUser andPassWord:self.defaultFTPPwd andServerAddress:self.defaultFTPDomain];
            
            
            for (int i = 0; i < count; i++) {
                
                NSString *localFilePath = [fileItems objectAtIndex:i];
                
                if (![localFilePath isEqualToString:@""]) {
                    
                    NSString *fileName = [[FwString sharedInstance] getFileNameFromPath:localFilePath];
                    
                    NSString *fileExt = [[FwString sharedInstance] getExtensionFromPath:localFilePath];
                    
                    if ([fileExt isEqualToString:@"mp4"]) {
                        
                        NSString *programName = [preProgram stringByAppendingString:fileName];
                        
                        NSString *remotePath;
                        
                        if ([channelFolder length] <= 0) {
                            remotePath = [NSString stringWithFormat:@"%@", programName];
                        }else{
                            remotePath = [NSString stringWithFormat:@"%@/%@", channelFolder, programName];
                        }                        
                        
                                                
                        NSLog(@"Local File[%d] = %@", i, localFilePath);
                        
                        NSLog(@"Remote Path[%d] = %@", i, remotePath);
                        
                        
                        // 1. create remotePath on ftp server                       
                        if (![programFolderList containsObject:programName]) {
                            [nc addObserver:self selector:@selector(notifiedFtpCreateDirStatusChange:) name:CreateDirStatusChangedNotification object:ftpCreateDir];
                            
                            [ftpCreateDir createFolder:remotePath];
                        }                 
                        
                        
                        // 2. upload remoteFile to ftp server                        
                        
                        
                        NSString *remoteFile = [NSString stringWithFormat:@"%@/%@.mp4",remotePath,fileName];                        
                                                
                        
                        [nc addObserver:self selector:@selector(notifiedFtpUploadStatusChange:) name:UploadStatusChangedNotification object:ftpUpload];
                        
                        
                        [ftpUpload uploadFile:localFilePath toRemote:remoteFile];
                    }
                    
                    
                }
                
                
            }
            
        }
    }

    
}


- (void)notifiedFtpUploadStatusChange: (NSNotification *)notified{
    
    FwFtpUpload * data = [notified object];
    NSLog(@"upload status %@",data.status);
    [uploadStatus setStringValue:data.status];
}


- (IBAction)listAction:(id)sender{
    
    
    if ([self checkFtpSetting] && [self checkPassword]) {
        
        ftpList = [[FwFtpList alloc] initWithUserName:self.defaultFTPUser andPassWord:self.defaultFTPPwd andServerAddress:self.defaultFTPDomain];
        
        NSString *remotePath =@"";
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(notifiedFtpListStatusChange:) name:ListStatusChangedNotification object:ftpList];
        
        [ftpList listFolder:remotePath];
                
    }
    
}

- (void)notifiedFtpListStatusChange: (NSNotification *)notified{
    
    FwFtpList * data = [notified object];
    NSLog(@"list status %@",data.status);
    [uploadStatus setStringValue: data.status];
    NSString *status = data.status;
    
    if ([status isEqualToString:@"List succeeded"]) {
        
        NSMutableArray  *list = [data listFolderName];
        
        for (int i= 0; i < [list count]; i++) {
            NSString *temp = [NSString stringWithFormat:@"%@",[list objectAtIndex:i]];
            [channelFolderList addItemWithTitle:temp];
        }
        
    }
}


- (IBAction)createAction:(id)sender{
    
    
    if ([self checkFtpSetting] && [self checkPassword]) {
        
        NSString  *folderName = [remoteFolderName stringValue];        
        
        ftpCreateDir= [[FwFtpCreateDir alloc] initWithUserName:self.defaultFTPUser andPassWord:self.defaultFTPPwd andServerAddress:self.defaultFTPDomain];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(notifiedFtpCreateDirStatusChange:) name:CreateDirStatusChangedNotification object:ftpCreateDir];
        
        [ftpCreateDir createFolder:folderName];
        
    }
    
}

- (void)notifiedFtpCreateDirStatusChange: (NSNotification *)notified{
    
    // CreateDir
    FwFtpCreateDir * data = [notified object];
    NSLog(@"create dir status %@",data.status);
    [uploadStatus setStringValue: data.status];
    
}


//password:@"nEurAl51"
- (BOOL)checkPassword{    
    
    
    NSString *inputFTPPwd = [ftpPwd stringValue];    
    
    if ([inputFTPPwd isEqualToString:@""]) {
        
        NSString *message =@"Please input password first";
        
        [uploadStatus setStringValue:message];
        
        return NO;
        
    }else{
                
        self.defaultFTPPwd = inputFTPPwd;
        return YES;
    }
    
}

- (BOOL)checkFtpSetting{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"fw_encode.plist"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:appFile]) {
        NSArray *myData = [[[NSArray alloc] initWithContentsOfFile:appFile] autorelease];
        
        NSLog(@"Load default value from file = %@", myData);
        
        NSArray *temp = [myData objectAtIndex:0];
        
        
        self.defaultFolder = (NSString *)[temp objectAtIndex:0];
        self.defaultFTPUser = (NSString *)[temp objectAtIndex:1];
        self.defaultFTPDomain = (NSString *)[temp objectAtIndex:2];
        
        NSLog(@"default Foloder from file = %@", self.defaultFolder);
        NSLog(@"default FTPUser from file = %@", self.defaultFTPUser);
        NSLog(@"default FTPDomain from file = %@", self.defaultFTPDomain);
        
        return YES;
        
    } else{
        [uploadStatus setStringValue:@"Please click 'setting' button to set your ftp user, domain"];
        return NO;
    }
    
    

    
}


@end
