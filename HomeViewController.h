//
//  HomeViewController.h
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwViewController.h"

@interface HomeViewController : FwViewController{
    
    IBOutlet NSPopUpButton *encodeFormatList;
    IBOutlet NSTextView  *encodeAreaFiles;
    IBOutlet NSTextField *encodeStatus;
    
    IBOutlet NSTextField *ftpPwd;
    IBOutlet NSTextField *remoteFolderName;
    IBOutlet NSPopUpButton *channelFolderList;
    IBOutlet NSTextView  *uploadAreaFile;
    IBOutlet NSTextField *uploadStatus;
    
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

@end
