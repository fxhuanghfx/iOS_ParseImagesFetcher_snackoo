//
//  ImageDownloader.h
//  ParseStarterProject
//
//  Created by Feixiang Huang on 11/6/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
//#import "ParseStarterProjectAppDelegate.h"

@interface ImageFetcher : NSObject

+ (ImageFetcher*)getSharedInstance;
 

- (void) storeImageWithImage:(UIImage *) imageFile
          storeImageWithName:(NSString*)fileName;


- (UIImage*) getImageForName:(NSString*)fileName;


@end
