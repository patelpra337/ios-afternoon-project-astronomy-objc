//
//  LSIMarsRoverClient.h
//  Astronomy
//
//  Created by patelpra on 8/10/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSIMarsRover;
@class LSIMarsPhotoReference;

typedef void(^MarsRoverFetcherCompletionHandler)(LSIMarsRover *_Nullable marsRover, NSError *_Nullable error);
typedef void(^PhotosFetcherCompletionHandler)(NSArray<LSIMarsPhotoReference *> *_Nullable photos, NSError *_Nullable error);
typedef void(^PhotoFetcherCompletionHandler)(UIImage *_Nullable photo, NSError *_Nullable error);

NS_SWIFT_NAME(MarsRoverClient)
@interface LSIMarsRoverClient: NSObject

- (void)fetchMarsRoverWithName:(nonnull NSString *)name
             completionHandler:(nonnull MarsRoverFetcherCompletionHandler)completionHandler;

- (void)fetchPhotosFromMarsRover:(nonnull LSIMarsRover *)marsRover
                           onSol:(int)sol
               completionHandler:(nonnull PhotosFetcherCompletionHandler)completionHandler;

- (void)fetchPhotoWithURLString:(nonnull NSString *)URLString
                   usingSession:(nullable NSURLSession *)session
              completionHandler:(nonnull PhotoFetcherCompletionHandler)completionHandler;

@end

