//
//  SettingViewController.h
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "FwViewController.h"

@interface SettingViewController : FwViewController{
    IBOutlet    NSTextField *defaultPath;
    IBOutlet    NSTextField *userName;
    IBOutlet    NSTextField *domainOrIP;
}

- (IBAction)loadAction:(id)sender;

- (IBAction)settingAction:(id)sender;

- (IBAction)clearAction:(id)sender;

@end
