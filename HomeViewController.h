//
//  HomeViewController.h
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwViewController.h"

@interface HomeViewController : FwViewController{
    
//    IBOutlet NSPopUpButton *encodeFormatList;
    IBOutlet NSTextView  *encodeAreaFiles;
    IBOutlet NSTextField *encodeStatus;
    
    IBOutlet NSButton *btnEncode;
    IBOutlet NSButton *btnCancelEncode;
    IBOutlet NSButton *btnUpload;
    IBOutlet NSButton *btnCancelUpload;
    
    IBOutlet NSTextField *ftpPwd;
    IBOutlet NSTextField *remoteFolderName;
    IBOutlet NSPopUpButton *channelFolderList;
    IBOutlet NSPopUpButton *ftpDiskList;
    IBOutlet NSTextView  *uploadAreaFile;
    IBOutlet NSTextField *uploadStatus;
    
    NSOperationQueue *processingQueue;
    
    // setting code
    IBOutlet    NSTextField *defaultPath;
    IBOutlet    NSTextField *userName;
    IBOutlet    NSTextField *domainOrIP;
    
}

// property for FTP
@property (nonatomic,strong) NSString *defaultFolder;
@property (nonatomic,strong) NSString *defaultFTPUser;
@property (nonatomic,strong) NSString *defaultFTPDomain;
@property (nonatomic,strong) NSString *defaultFTPPwd;

- (IBAction)cancelEncode:(id)sender;
- (IBAction)clearEncode:(id)sender;
- (IBAction)startEncode:(id)sender;

- (IBAction)cancelUpload:(id)sender;
- (IBAction)clearUpload:(id)sender;
- (IBAction)startUpload:(id)sender;

- (IBAction)createAction:(id)sender;
- (IBAction)listAction:(id)sender;

- (void)uploadFileToServer:(NSString *)localFileAndRemoteProgramNameAndRemotePathAndRemoteFile;

// setting action
- (IBAction)loadAction:(id)sender;
- (IBAction)settingAction:(id)sender;
- (IBAction)clearAction:(id)sender;

// help action
- (IBAction)helpAction:(id)sender;

@end
