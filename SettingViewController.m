//
//  SettingViewController.m
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)init{
    
    self = [super initWithNibName:@"SettingView" bundle:nil];
    
    if (self) {
        [self setTitle:@"Setting"];
    }
    return self;
}



- (IBAction)loadAction:(id)sender{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"fw_encode.plist"];
    NSArray *myData = [[[NSArray alloc] initWithContentsOfFile:appFile] autorelease];

    NSLog(@"Load default value from file = %@", myData);

    NSArray *temp = [myData objectAtIndex:0];

    [defaultPath setStringValue:[temp objectAtIndex:0]];
    [userName setStringValue:[temp objectAtIndex:1]];
    [domainOrIP setStringValue:[temp objectAtIndex:2]];

}

- (IBAction)settingAction:(id)sender{
    
    NSString *userDefaultPath = [NSString stringWithFormat:@"%@", [defaultPath stringValue]];
    NSString *userDefaultFTPUser = [NSString stringWithFormat:@"%@", [userName stringValue]];
    NSString *userDefaultFTPDomain = [NSString stringWithFormat:@"%@", [domainOrIP stringValue]];
    
    NSArray *settings = [NSArray arrayWithObjects:userDefaultPath, userDefaultFTPUser, userDefaultFTPDomain, nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    // confirm if paths exist
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir;
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if ([manager fileExistsAtPath:documentsDirectory isDirectory: &isDir]) {
        NSString *appSettingFile = [documentsDirectory stringByAppendingPathComponent:@"fw_encode.plist"];
        
        NSLog(@"App setting file = %@", appSettingFile);
        
        [[NSArray arrayWithObjects:settings, nil] writeToFile:appSettingFile atomically:NO];
        
        
    }else{
        NSLog(@"Documents directory not found!");
    }
}

- (IBAction)clearAction:(id)sender{
    
    NSLog(@"Clear Action");
    
    [defaultPath setStringValue:@""];
    [userName setStringValue:@""];
    [domainOrIP setStringValue:@""];
    
}


@end
