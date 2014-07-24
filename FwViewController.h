//
//  FwViewController.h
//  fw_encoder
//
//  Created by Lee Denny on 7/21/14.
//  Copyright (c) 2014 fw-labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FwViewController : NSViewController{
    NSManagedObjectContext *managedObjectContext;
}

@property (strong)NSManagedObjectContext *managedObjectContext;

@end
