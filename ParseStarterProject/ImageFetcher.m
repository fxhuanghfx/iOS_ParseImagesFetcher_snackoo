//
//  ImageDownloader.m
//  ParseStarterProject
//
//  Created by Feixiang Huang on 02/06/14.
//
//

#import "ImageFetcher.h"

@implementation ImageFetcher{
    NSMutableDictionary * cache;
}

+ (ImageFetcher*)getSharedInstance{
    static dispatch_once_t once;
    static ImageFetcher * sharedInstance = NULL;
    dispatch_once(&once, ^{
        sharedInstance = [[ImageFetcher alloc]init];
        sharedInstance->cache = [[NSMutableDictionary alloc]init];
    });
    return sharedInstance;
}


- (void) storeImageInRAM:(UIImage *) imageFile
          storeImageWithName:(NSString*)fileName{
    
    if([cache objectForKey:fileName] == nil){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [cache setObject:imageFile forKey:fileName];
            NSLog(@"cache size %lu", (unsigned long)[cache count]);
        
        });
                        
    }
}



- (UIImage*) getImageFromRAM:(NSString*)fileName
{
    
    if([cache objectForKey:fileName]!= nil){
        return cache[fileName];
    }else{
        return nil;
    }
}





















@end
