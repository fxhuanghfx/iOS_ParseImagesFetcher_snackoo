/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ParseStarterProjectViewController.h"

#import <Parse/Parse.h>
#import "PhotoCell.h"

#define nSectionCount 1
#define nPhotosInSection 100

#define nPickedPhotos 5





@implementation ParseStarterProjectViewController

#pragma mark -
#pragma mark UIViewController

- (void) filesProcess{

    NSString *path;
    NSFileManager *fm;
    NSDirectoryEnumerator *dirEnum;
    
    fm = [NSFileManager defaultManager];
    
    
    path = @"/Users/fh15/Documents/100photoes/";
    NSString *fileFullPath = path;
    [fileFullPath stringByAppendingString:path];
    //get files in the directory and its sub directory
    dirEnum = [fm enumeratorAtPath:path];
    
    int i=0;
    NSString *fileName = @"";
    //NSLog(@"1.Contents of %@:",path);
    _imageFileNameArray = [[NSMutableArray alloc] init];
    _imageFileFullPathArray = [[NSMutableArray alloc] init];
    
    while ((fileName = [dirEnum nextObject]) != nil)
    {
        if(i!=0){
            [_imageFileNameArray addObject:fileName];
            //[_imageFileNameArray addObject:@"hfx"];
            NSLog(@"%@",fileName);
            fileFullPath = [fileFullPath stringByAppendingString:fileName];
            [_imageFileFullPathArray addObject:fileFullPath];
            NSLog(@"%@",fileFullPath);
            fileFullPath = @"/Users/fh15/Documents/100photoes/";
            //NSLog(@"%@",fileFullName);
        }
        i++;
        NSLog(@"i = %i",i);
    }
 
    
    BOOL success1=[NSKeyedArchiver archiveRootObject:_imageFileNameArray toFile:_imageFileFullPathArchivePath];
    if (success1) {
        NSLog(@"_imageFileNameArray archive succeeded.");
    }
    BOOL success2=[NSKeyedArchiver archiveRootObject:_imageFileFullPathArray toFile:_imageFileNameArchivePath];
    if (success2) {
        NSLog(@"_imageFileFullPathArray archive succeeded.");
    }
    
    
}

- (void) archiveFilesUpload{
    
    //load image the filename file
    _homePath=NSHomeDirectory();
    
    _imageFileNameArchivePath=[_homePath stringByAppendingPathComponent:@"/imageFileName.archiver"];

    //Archive file restore
    _imageFileNameArray= [NSKeyedUnarchiver unarchiveObjectWithFile:_imageFileNameArchivePath];
    
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_imageFileNameArray];
    NSString *fimeNameString = @"";
    NSString *myString = @"";
    for (myString in _imageFileNameArray ) {
        if([myString isKindOfClass:[NSString class]]){
            
            fimeNameString = [fimeNameString stringByAppendingPathComponent:myString];
        }
    }
    
    //=====================
    _imageUploadApplication = [PFObject objectWithClassName:@"archiverPickerClass"];
    _imageUploadApplication[@"fileName"] = @"imageFileName.archiver";
    
    NSData *data = [fimeNameString dataUsingEncoding:NSUTF8StringEncoding];
    PFFile *file = [PFFile fileWithName:@"imageFileName.archiver" data:data];
    
    //////////////////////////////// 太重要了！！！！！！！
    [file save];//
    
    _imageUploadApplication[@"File"] = file;
    
    // 下面2个函数功能一样，只不过save是阻塞式的，saveInBackground开了另外一个线程，所以调试时应该放开断点让它继续运行，过一段时间才会有结果。
    [_imageUploadApplication save];
    
    
}


- (void) imageFilesUpload{
    //load image the filename file
    _homePath=NSHomeDirectory();
    _imageFileFullPathArchivePath=[_homePath stringByAppendingPathComponent:@"/imageFileFullPath.archiver"];
    _imageFileNameArchivePath=[_homePath stringByAppendingPathComponent:@"/imageFileName.archiver"];
    
    //Archive file restore
    _imageFileFullPathArray= [NSKeyedUnarchiver unarchiveObjectWithFile:_imageFileFullPathArchivePath];
    _imageFileNameArray= [NSKeyedUnarchiver unarchiveObjectWithFile:_imageFileNameArchivePath];
    
    NSString *fileNameString = @"";
    NSString *fileFullPathString = @"";
    
    for ( int i=0; i<[_imageFileNameArray count]; i++ ) {
        
        _imageUploadApplication = [PFObject objectWithClassName:@"imagePickerClass"];
        
        //=====================
        if (i >=0 && i< 100) {
            fileNameString = [_imageFileNameArray objectAtIndex:i];
            fileFullPathString = [_imageFileFullPathArray objectAtIndex:i];
        }
        
        //load image files
        UIImage* image = [UIImage imageNamed:fileFullPathString];
        
        NSData* imageData = UIImageJPEGRepresentation(image, 0.2);
        PFFile *imageFile = [PFFile fileWithName:fileNameString data:imageData];
        
        //////////////////////////////// 太重要了！！！！！！！
        [imageFile save];//
        //[imageFile saveInBackground];//
        
        //PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
        
        _imageUploadApplication[@"fileNo"] = @(i);
        _imageUploadApplication[@"fileName"] = fileNameString;
        _imageUploadApplication[@"File"] = imageFile;
        
        // 下面2个函数功能一样，只不过save是阻塞式的，saveInBackground开了另外一个线程，所以调试时应该放开断点让它继续运行，过一段时间才会有结果。
        [_imageUploadApplication save];
        //[_imageUploadApplication saveInBackground];
        
    }
    NSLog(@"imageFilesUpload succeed.");
}


- (void) imageFileRetrieve: (int) iNum{

    if(iNum > 75){
        NSLog(@"ok");
    }
    //Query
    PFQuery *query;
    
    int iNumber = iNum;

    
    query = [PFQuery queryWithClassName:@"imagePickerClass"];


   
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:nPickedPhotos];

    for (int j=0; j<nPickedPhotos; j++) {
        iNumber += j;
        if (iNumber >=0 && iNumber < 100) {
            [names addObject:[_imageFileNamesResultArray objectAtIndex:iNumber]];
        }
        
    }
    [query whereKey:@"fileName" containedIn:names];

    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
    //block 做函数参数的时候，调试时也应该放开断点让它继续运行，过一段时间才会有结果。只在block里设一个断点，其他断点全部取消
    if (!error) {
        
        
        PFFile *file;
        NSString *fileName;
        int iPathRow;

        for (PFObject *object in objects) {
            
            self.fileRetrieveApplication = object;
            file = self.fileRetrieveApplication[@"File"];
            fileName = self.fileRetrieveApplication[@"fileName"];
            
            iPathRow = [[self.fileRetrieveApplication objectForKey:@"highScore"] intValue];
            
            NSLog(@"fileNo is %d", iPathRow);
            NSLog(@"fileName is %@", fileName);
           
            [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    [self.imageFetcher storeImageWithImage:image
                                       storeImageWithName: fileName ];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.photoTableView reloadData];

                    });
                    
                    
                }
            }];
        }
    } else {
        // Log details of the failure
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
}];
    
    
    
    
}

//////////////////////
- (void) nameFileRetrieve{

    //Query
    PFQuery *query = [PFQuery queryWithClassName:@"archiverPickerClass"];
    
    [query whereKey:@"fileName" equalTo:@"imageFileName.archiver"];
    
    NSArray* fileObjects = [query findObjects];
    for (PFObject *myObject in fileObjects) {
        
        NSString *fileName = (NSString *)[myObject objectForKey:@"fileName"];
        if ([fileName isEqualToString:@"imageFileName.archiver"] ) {
            _fileRetrieveApplication = myObject;
            //file retrieve
            PFFile *applicantResume = _fileRetrieveApplication[@"File"];
            NSData *content = [applicantResume getData];
            
            NSString *fileNamesString = [[NSString alloc]initWithData:content encoding:NSUTF8StringEncoding];
            _imageFileNamesResultArray = [fileNamesString componentsSeparatedByString:@"/"];
            NSLog(@"%@",_imageFileNamesResultArray);
        }
        //NSLog(@"%@", myObject.objectId);
    }

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return nSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return nPhotosInSection;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"My favorite photos";

}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell" forIndexPath:indexPath];

    NSString * imageFileName = self.imageFileNamesResultArray[indexPath.row];
    NSLog(@"indexPath.row is %li", (long)indexPath.row);
    self.iIndexPathRow = indexPath.row;
    
    UIImage *photoImage;
    
    photoImage = (UIImage*)[self.imageFetcher getImageForName:imageFileName ];
    
    if (photoImage != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = photoImage;
            
        });
    }
    
    return cell;
}






// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated{
    
    _imageFetcher = [ImageFetcher getSharedInstance];

    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    self.iStart = 0;
    self.iEnd = 0;
    self.iClickCount++;
    
    int iIndex = self.iIndexPathRow; //(int)scrollView.contentOffset.y / iWidthImage;
    NSLog(@"iIndex is %i", iIndex);
    if(iIndex > 75){
        NSLog(@"ok");
    }
    
    
    if ( iIndex>0 && (iIndex-self.iStart)>0 && iIndex < nPhotosInSection) {
        
        
        [self imageFileRetrieve: iIndex];
        
        self.iStart = iIndex;
    }
    
    NSLog(@"------- %f, %i",scrollView.contentOffset.y, iIndex);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIScrollView * scrollView = (UIScrollView*)self.photoTableView;
    scrollView.delegate = self;
    
    [self nameFileRetrieve];
    [self imageFileRetrieve:0];
    
    NSLog(@"viewDidLoad succeed.");
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}















@end
