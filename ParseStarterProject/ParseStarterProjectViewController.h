/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ImageFetcher.h"




@interface ParseStarterProjectViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageFileFullPathArray;
@property (nonatomic, strong) NSMutableArray *imageFileNameArray;
@property (weak, nonatomic) IBOutlet UITableView *photoTableView;


@property (nonatomic, strong) NSArray *imageFileNamesResultArray;

@property (nonatomic, strong) NSString *homePath;


@property (nonatomic, strong) NSString *imageFileFullPathArchivePath;
@property (nonatomic, strong) NSString *imageFileNameArchivePath;

//for upload
@property (nonatomic, weak) PFObject *imageUploadApplication;
//for download
@property (nonatomic, weak) PFObject *fileRetrieveApplication;

@property (nonatomic, strong) ImageFetcher *imageFetcher;



@property int iStart;
@property int iEnd;
@property int iClickCount;

@property int iStoredIndex;

@property int iIndexPathRow;


- (void) filesProcess;
- (void) archiveFilesUpload;
- (void) imageFilesUpload;

- (void) nameFileRetrieve;
- (void) imageFileRetrieve:(int) iNum;



































@end
