//
//  MarsRover.m
//  Astronomy
//
//  Created by patelpra on 8/5/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

#import "LSIMarsRover.h"
#import "LSISolDescription.h"

@implementation LSIMarsRover

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                      numberOfPhotos:(int)numberOfPhotos
                              maxSol:(int)maxSol
                     solDescriptions:(nonnull NSArray<LSISolDescription *> *)solDescriptions
{
    if (self = [super init]) {
        _name = name.copy;
        _numberOfPhotos = numberOfPhotos;
        _maxSol = maxSol;
        _solDescriptions = solDescriptions.copy;
    }
    return self;
}

- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary
{
   NSString *name = [dictionary objectForKey:@"name"];
   if (![name isKindOfClass:[NSString class]]) return nil;
   
   NSNumber *numberOfPhotos = [dictionary objectForKey:@"total_photos"];
   if (![numberOfPhotos isKindOfClass:[NSNumber class]]) return nil;
   
   NSNumber *maxSol = [dictionary objectForKey:@"max_sol"];
   if (![maxSol isKindOfClass:[NSNumber class]]) return nil;
   
   NSArray *solDescriptionDictionaries = [dictionary objectForKey:@"photos"];
   if (![solDescriptionDictionaries isKindOfClass:[NSArray class]]) return nil;
   
   //NSMutableArray<LSISolDescription *> *solDescriptions = [[NSMutableArray alloc] initWithCapacity:solDescriptionDictionaries.count];
   NSMutableArray *solDescriptions = [[NSMutableArray alloc] initWithCapacity:solDescriptionDictionaries.count];
   
   for (NSDictionary *solDescriptionDictionary in solDescriptionDictionaries) {
       if (![solDescriptionDictionary isKindOfClass:[NSDictionary class]]) continue;
       
       LSISolDescription *solDescription = [[LSISolDescription alloc] initWithDictionary:solDescriptionDictionary];
       
       if (solDescription) {
           [solDescriptions addObject:solDescription];
       } else {
           NSLog(@"Unable to parse solDescription dictionary: %@", solDescriptionDictionary);
       }
   }
   
   return [self initWithName:name
              numberOfPhotos:numberOfPhotos.intValue
                      maxSol:maxSol.intValue
             solDescriptions:solDescriptions];
}

@end
