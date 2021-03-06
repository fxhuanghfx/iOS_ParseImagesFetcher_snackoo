/**
 * Copyright (c) 2014-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

//
@class ParseStarterProjectViewController;

@interface ParseStarterProjectAppDelegate : NSObject <UIApplicationDelegate>

//coreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *manageObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *manageObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//
@property (nonatomic, strong) UIWindow *window;



- (void) saveContext;

@end
