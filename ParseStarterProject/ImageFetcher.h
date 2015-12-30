//
//  ImageDownloader.h
//  ParseStarterProject
//
//  Created by Feixiang Huang on 02/06/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
//#import "ParseStarterProjectAppDelegate.h"

@interface ImageFetcher : NSObject

+ (ImageFetcher*)getSharedInstance;
 

- (void) storeImageInRAM:(UIImage *) imageFile
          storeImageWithName:(NSString*)fileName;


- (UIImage*) getImageFromRAM:(NSString*)fileName;


@end
