//
//  ImageDownloader.m
//  ParseStarterProject
//
//  Created by Feixiang Huang on 11/6/15.
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
        sharedInstance->cache = [NSMutableDictionary dictionaryWithCapacity:100];
        //sharedInstance->cache = [[NSMutableDictionary alloc]init];
    });
    return sharedInstance;
}


- (void) storeImageWithImage:(UIImage *) imageFile
          storeImageWithName:(NSString*)fileName{
    
    if([cache objectForKey:fileName] == nil){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [cache setObject:imageFile forKey:fileName];
            NSLog(@"cache size %lu", (unsigned long)[cache count]);
        
        });
                        
    }
}



- (UIImage*) getImageForName:(NSString*)fileName
{
    
    if([cache objectForKey:fileName]!= nil){
        return cache[fileName];
    }else{
        return nil;
    }
}





















@end
