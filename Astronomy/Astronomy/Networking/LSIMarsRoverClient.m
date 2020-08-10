//
//  LSIMarsRoverClient.m
//  Astronomy
//
//  Created by patelpra on 8/10/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

#import "LSIMarsRoverClient.h"
#import "Astronomy-Swift.h"
#import "LSIMarsRover.h"
#import "LSIErrors.h"

//https://api.nasa.gov/mars-photos/api/v1/manifests/curiosity?api_key=xzmUahFwDGPpByWDNsKViE2p0cMIPU47PTee9xJd
static NSString *const MarsRoverAPIBaseURLString = @"https://api.nasa.gov/mars-photos/api/v1";
static NSString *const APIKey = @"xzmUahFwDGPpByWDNsKViE2p0cMIPU47PTee9xJd";

@implementation LSIMarsRoverClient

- (void)fetchMarsRoverWithName:(NSString *)name
             completionHandler:(MarsRoverFetcherCompletionHandler)completionHandler
{
    NSURL *url = [self urlForInfoForRoverWithName:name];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching rover info: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSError *jsonError;
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSDictionary *roverInfoDictionary = [JSONDictionary objectForKey:@"photo_manifest"];
        if (!roverInfoDictionary) {
            NSLog(@"Error decoding JSON: %@", jsonError);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, jsonError);
            });
            return;
        }
        
        LSIMarsRover *roverInfo = [[LSIMarsRover alloc] initWithDictionary:roverInfoDictionary];
        if (!roverInfo) {
            NSError *error = [NSError errorWithDomain:@"RoverInfoFetcherDomain" code:-1 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(roverInfo, nil);
        });
        
    }] resume];
}

- (void)fetchPhotosFromMarsRover:(LSIMarsRover *)marsRover
                           onSol:(int)sol
               completionHandler:(PhotosFetcherCompletionHandler)completionHandler
{
    NSURL *url = [self urlForPhotosFromRoverWithName:marsRover.name onSol:sol];
    
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching photos: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSError *jsonError;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (!dictionary) {
            NSLog(@"Error decoding JSON: %@", jsonError);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, jsonError);
            });
            return;
        }
        
        NSArray *photoReferenceDictionaries = [[NSArray alloc] initWithArray:[dictionary valueForKey:@"photos"]];
        if (!photoReferenceDictionaries) {
            NSError *error = [NSError errorWithDomain:@"PhotoFetcherDomain" code:-1 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        NSMutableArray *photoReferences = [[NSMutableArray alloc] initWithCapacity:photoReferenceDictionaries.count];
        
        for (NSDictionary *photoReferenceDictionary in photoReferenceDictionaries) {
            if (![photoReferenceDictionary isKindOfClass:[NSDictionary class]]) continue;
            
            LSIMarsPhotoReference *photoReference = [[LSIMarsPhotoReference alloc] initWithDictionary:photoReferenceDictionary];
            
            if (photoReference) {
                [photoReferences addObject:photoReference];
            } else {
                NSLog(@"Unable to parse photoReference dictionary: %@", photoReferenceDictionary);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(photoReferences, nil);
        });
        
    }] resume];
}

- (void)fetchPhotoWithURLString:(NSString *)URLString
                   usingSession:(NSURLSession *)session
              completionHandler:(PhotoFetcherCompletionHandler)completionHandler
{
    if (!session) {
        session = NSURLSession.sharedSession;
    }
    
    NSURL *URL = [NSURL URLWithString:URLString].usingHTTPS;
    if (!URL) {
        NSError *error = errorWithMessage(@"Error: URL does not conform to secure HTTPS protocol: %@", 1003);
        completionHandler(nil, error);
        return;
    }
        
    [[session dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching photo: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        if (!data) {
            NSError *error = errorWithMessage(@"Error receiving photo data: %@", LSIDataNilError);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        UIImage *photo = [UIImage imageWithData:data];
        if (!photo) {
            NSError *error = [NSError errorWithDomain:@"PhotoFetcherDomain" code:-1 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(photo, nil);
        });
        
    }] resume];
}

- (NSURL *)urlForInfoForRoverWithName:(NSString *)roverName
{
    NSURL *baseURL = [NSURL URLWithString:MarsRoverAPIBaseURLString];
    NSURL *queryURL = [[baseURL
                         URLByAppendingPathComponent:@"manifests"]
                        URLByAppendingPathComponent:roverName];
    NSURLComponents *queryURLComponents = [NSURLComponents componentsWithURL:queryURL resolvingAgainstBaseURL:YES];
    [queryURLComponents setQueryItems:@[[NSURLQueryItem queryItemWithName:@"api_key" value:APIKey]]];
    return [queryURLComponents URL];
}

- (NSURL *)urlForPhotosFromRoverWithName:(NSString *)roverName onSol:(int)sol
{
    NSURL *baseURL = [NSURL URLWithString:MarsRoverAPIBaseURLString];
    NSURL *queryURL = [[[baseURL
                         URLByAppendingPathComponent:@"rovers"]
                        URLByAppendingPathComponent:roverName]
                       URLByAppendingPathComponent:@"photos"];
    NSURLComponents *queryURLComponents = [NSURLComponents componentsWithURL:queryURL resolvingAgainstBaseURL:YES];
    [queryURLComponents setQueryItems:@[[NSURLQueryItem queryItemWithName:@"sol" value:[@(sol) stringValue]],
                                        [NSURLQueryItem queryItemWithName:@"api_key" value:APIKey]]];
    return [queryURLComponents URL];
}

@end

