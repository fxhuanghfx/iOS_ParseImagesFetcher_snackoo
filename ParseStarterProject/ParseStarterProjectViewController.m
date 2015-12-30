/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *Feixiang Huang
 *
 *
 */

#import "ParseStarterProjectViewController.h"

#import <Parse/Parse.h>
#import "ImageTableViewCell.h"

#define nSectionCount 1
#define nPhotosInSection 100

#define nPickedPhotos 5

@interface ParseStarterProjectViewController ()


- (BOOL) imageFileGetFromHardDrive:(NSString *)imageFileName
                     image:(UIImage *)image;

- (NSString *)getImageFloderPath;

@end



@implementation ParseStarterProjectViewController

#pragma mark -
#pragma mark UIViewController







- (void) imageFileRetrieve: (int) iNum{
    
    //Query
    PFQuery *query;
    int iNumber = iNum;
    BOOL isGetImage = true;
    NSString *strImageFileName = @"";

    query = [PFQuery queryWithClassName:@"imagePickerClass"];
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:nPickedPhotos];

    int j=0;
    for (j=0; j<nPickedPhotos; j++) {
        
        if ((iNumber+j) >=0 && (iNumber+j) < 100) {
            //
            strImageFileName = [_imageFileNamesResultArray objectAtIndex:(iNumber+j)];
            
            //
            UIImage* image = [self.imageFetcher getImageFromRAM:strImageFileName];
            
            if (image == nil) {
                //search image file from hard drive
                BOOL isGetImageFromLocal = [self imageFileGetFromHardDrive:strImageFileName
                                  image:image];
                
                if (isGetImageFromLocal == false) {
                    //image file does not exist in hard drive
                    [names addObject:strImageFileName];
                    isGetImage = false;
                }
                
            }
            
            //
            
        }
        
    }
    self.iImageNum = (iNumber+j);
    
    //image file does not exist in hard drive
    if (isGetImage == false) {

        [query whereKey:@"fileName" containedIn:names];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
             if (!error) {
        
                PFFile *file;
                NSString *fileName;
                int iPathRow;

                for (PFObject *object in objects) {
                    
                    self.fileRetrieveApplication = object;
                    file = self.fileRetrieveApplication[@"File"];
                    fileName = self.fileRetrieveApplication[@"fileName"];
                    iPathRow = [[self.fileRetrieveApplication objectForKey:@"fileNo"] intValue];
                    
                    NSLog(@"fileNo is %d", iPathRow);
                    NSLog(@"fileName is %@", fileName);
                   
                    [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        if (!error) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            NSLog(@"%@", [NSValue valueWithCGSize:image.size]);
                            
                            [self.imageFetcher storeImageInRAM:image
                                               storeImageWithName: fileName ];
                            
                            [self imageFileSaveInLocal:imageData
                                              fileName:fileName];
                            //
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
    }//if image file does not exist in hard drive
    
    
}

- (BOOL) imageFileGetFromHardDrive:(NSString *)imageFileName
                     image:(UIImage *)image{
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [self getImageFloderPath];
    NSString *imageFileFullPath = [NSString stringWithFormat:@"%@/%@", dirPath, imageFileName];
    
    if(![fileManager fileExistsAtPath:imageFileFullPath]){
        //if the file does not exist
        return false;
    }
    else{
    
        NSData * imageData = [[NSData alloc] initWithContentsOfFile:imageFileFullPath];
        //
        image = [UIImage imageWithData:imageData];

        [self.imageFetcher storeImageInRAM:image
                            storeImageWithName:imageFileName ];
        
        return true;
    }
    
}



- (void) imageFileSaveInLocal:(NSData *)imageData
                     fileName:(NSString *)imageFileName{

    NSString *dirPath = [self getImageFloderPath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (existed != YES)
    {
        [fileManager createDirectoryAtPath:dirPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    NSString *imageFileFullPath = [NSString stringWithFormat:@"%@/%@", dirPath, imageFileName];
    if(![fileManager fileExistsAtPath:imageFileFullPath])
    {
        //if the file does not exist
        [fileManager createFileAtPath:imageFileFullPath
                             contents:imageData
                           attributes:nil];
    }
 
}

- (NSString *)getImageFloderPath{
    NSString * dirName = @"ImageFiles";
    //NSCachesDirectory
    NSString *dirPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), dirName];

    return dirPath;
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

- (NSString *) tableView:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section{
    return @"My favorite photos";

}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell"
                                                             forIndexPath:indexPath];
    NSString * imageFileName = self.imageFileNamesResultArray[indexPath.row];
    NSLog(@"indexPath.row is %li", (long)indexPath.row);
    
    int iIndex = 0;
    iIndex = (int)indexPath.row;
    self.iIndexPathRow = iIndex;

    UIImage *photoImage;
    photoImage = (UIImage*)[self.imageFetcher getImageFromRAM:imageFileName ];
    if (photoImage != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
        cell.imageViewParse.image = photoImage;
        });
    }
    
    return cell;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView * scrollView = (UIScrollView*)self.photoTableView;
    scrollView.delegate = self;
    
    _imageFetcher = [ImageFetcher getSharedInstance];
    
    [self nameFileRetrieve];
    [self imageFileRetrieve:0];
    
    NSLog(@"viewDidLoad succeed.");
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated{
   
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int iIndex = self.iImageNum;
    
    [self imageFileRetrieve: iIndex];

}


- (void) filesProcess{
    
    NSString *path;
    NSFileManager *fm;
    NSDirectoryEnumerator *dirEnum;
    
    _homePath=NSHomeDirectory();
    _imageFileFullPathArchivePath=[_homePath stringByAppendingPathComponent:@"/imageFileFullPath.archiver"];
    _imageFileNameArchivePath=[_homePath stringByAppendingPathComponent:@"/imageFileName.archiver"];
    
    
    fm = [NSFileManager defaultManager];
    path = @"/Users/fh15/Documents/100photoes/";
    NSString *fileFullPath = path;
    [fileFullPath stringByAppendingString:path];
    
    //get files in the directory and its sub directory
    dirEnum = [fm enumeratorAtPath:path];
    
    int i=0;
    NSString *fileName = @"";
    _imageFileNameArray = [[NSMutableArray alloc] init];
    _imageFileFullPathArray = [[NSMutableArray alloc] init];
    
    while ((fileName = [dirEnum nextObject]) != nil)
    {
        if(i!=0){
            [_imageFileNameArray addObject:fileName];
            NSLog(@"%@",fileName);
            fileFullPath = [fileFullPath stringByAppendingString:fileName];
            [_imageFileFullPathArray addObject:fileFullPath];
            NSLog(@"%@",fileFullPath);
            fileFullPath = @"/Users/fh15/Documents/100photoes/";
            
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
    
    _homePath=NSHomeDirectory();
    _imageFileNameArchivePath=[_homePath stringByAppendingPathComponent:@"/imageFileName.archiver"];
    
    //Archive file restore
    _imageFileNameArray= [NSKeyedUnarchiver unarchiveObjectWithFile:_imageFileNameArchivePath];
    
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
    
    [file save];//

    _imageUploadApplication[@"File"] = file;
    [_imageUploadApplication save];
    
    
}


- (void) imageFilesUpload{
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
        
        //
        if (i >=0 && i< 100) {
            fileNameString = [_imageFileNameArray objectAtIndex:i];
            fileFullPathString = [_imageFileFullPathArray objectAtIndex:i];
        }
        
        //load image files
        UIImage* image = [UIImage imageNamed:fileFullPathString];
        NSData* imageData = UIImageJPEGRepresentation(image, 0.2);
        PFFile *imageFile = [PFFile fileWithName:fileNameString data:imageData];
        
        [imageFile save];//

        _imageUploadApplication[@"fileNo"] = @(i);
        _imageUploadApplication[@"fileName"] = fileNameString;
        _imageUploadApplication[@"File"] = imageFile;
        
        [_imageUploadApplication save];
        //[_imageUploadApplication saveInBackground];
        
    }
    NSLog(@"imageFilesUpload succeed.");
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
