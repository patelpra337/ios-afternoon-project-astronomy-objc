//
//  LSICamera.h
//  Astronomy
//
//  Created by patelpra on 8/5/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_SWIFT_NAME(Camera)
@interface LSICamera : NSObject

@property (nonatomic, readonly) int cameraId;
@property (nonatomic, readonly) int roverId;
@property (nonatomic, readonly, copy, nonnull) NSString *name;
@property (nonatomic, readonly, copy, nonnull) NSString *fullName;

- (nonnull instancetype)initWithCameraId:(int)cameraId
                                 roverId:(int)roverId
                                    name:(nonnull NSString *)name
                                fullName:(nonnull NSString *)fullName;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;

@end


