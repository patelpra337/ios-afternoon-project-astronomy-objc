//
//  LSIMarsRover.h
//  Astronomy
//
//  Created by patelpra on 8/5/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSISolDescription;

NS_SWIFT_NAME(MarsRover)

@interface LSIMarsRover : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *name;
@property (nonatomic, readonly) int numberOfPhotos;
@property (nonatomic, readonly) int maxSol;
@property (nonatomic, copy, readonly, nonnull) NSArray<LSISolDescription *> *solDescriptions;

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                      numberOfPhotos:(int)numberOfPhotos
                              maxSol:(int)maxSol
                     solDescriptions:(nonnull NSArray<LSISolDescription *> *)solDescriptions;

- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;

@end


