//
//  FwAppDelegate.h
//  fw_encoder
//
//  Created by Lee Denny on 7/12/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FwAppDelegate : NSObject <NSApplicationDelegate>{
    
    IBOutlet    NSWindow    *myWindow;
    
    IBOutlet    NSBox       *box;
    IBOutlet    NSButton    *btnHome;
    IBOutlet    NSButton    *btnSetting;
    IBOutlet    NSButton    *btnHelp;
    NSMutableArray          *viewContollers;
    
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (IBAction)saveAction:(id)sender;

- (IBAction)menuBtnClick:(id)sender;

@end
