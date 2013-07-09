//
//  FavoritesManager.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-4-3.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import "FavoritesManager.h"
#import "SharedStates.h"


#define DEFUALTS_KEY_FAVORITES      @"DEFAULTS_KEY_FAVORITES"
#define LOCATION_EQUAL_GRANULARITY   50 //meters
#define MAX_FAVORITES 10

static FavoritesManager* S_FavoritesManager = nil;


@implementation FavoritesManager
@synthesize mFavorites;

+ (FavoritesManager*) shared
{
    @synchronized([FavoritesManager class]){
        if(S_FavoritesManager == nil){
            S_FavoritesManager = [[self alloc]init];
        }
    }
    return S_FavoritesManager;
}


- (id) init
{
    self = [super init];
    if (self)
    {
        [self readStoredFavoritesIfNeeded];
    }
    return self;
}

- (void) dealloc
{
    self.mFavorites = nil;
    [super dealloc];
}

- (void) readStoredFavoritesIfNeeded
{
    if (!self.mFavorites)
    {
        self.mFavorites = [NSMutableArray array];
        
        NSUserDefaults* sDefaults = [NSUserDefaults standardUserDefaults];
        NSArray* sArchivedFavorites = [sDefaults arrayForKey:DEFUALTS_KEY_FAVORITES];
        if (sArchivedFavorites.count > 0)
        {
            NSLog(@"some favorites found!");
            [self.mFavorites addObjectsFromArray:[self unarchiveFavorites:sArchivedFavorites]];
            
            //sort
            [self.mFavorites sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
                    FavoritePOI *l1 = (FavoritePOI*)obj1;
                    FavoritePOI *l2 = (FavoritePOI*)obj2;
                    return [l2.mRecordDate compare:l1.mRecordDate];
                }
            ];
        }
        else
        {
            NSLog(@"0 favorites found!");
        }

    }
}

- (void) storeFavorites
{
    if (self.mFavorites)
    {
        NSLog(@"store %d favorites", self.mFavorites.count);

        NSUserDefaults* sDefaults = [NSUserDefaults standardUserDefaults];
        [sDefaults setObject:[self archivedFavorites] forKey:DEFUALTS_KEY_FAVORITES];
        [sDefaults synchronize];
    }
}

- (NSArray*) archivedFavorites
{
    NSMutableArray* sArchivedFavorites = [NSMutableArray array];
    for (FavoritePOI* sLocationRecord in self.mFavorites)
    {
        NSData* sLocationRecordData = [NSKeyedArchiver archivedDataWithRootObject:sLocationRecord];
        [sArchivedFavorites addObject:sLocationRecordData];
    }
    return sArchivedFavorites;
}

- (NSArray*) unarchiveFavorites:(NSArray*)aArchivedFavorites
{
    NSMutableArray* sUnarchivedFavorites = [NSMutableArray array];
    for (NSData* sLocationRecordData in aArchivedFavorites)
    {
        FavoritePOI* sLRD = [NSKeyedUnarchiver unarchiveObjectWithData:sLocationRecordData];
        [sUnarchivedFavorites addObject:sLRD];
    }
    return sUnarchivedFavorites;
}

- (NSArray*) getAllFavorites
{    
    return self.mFavorites;
}

- (BOOL) addFavorite:(FavoritePOI*)aRecord
{
    if ([self isFavorited:aRecord])
    {
        [[SharedStates getInstance] showNotice:NSLocalizedString(@"Record is in favorites already", nil)];
        return NO;
    }
    
    if (self.mFavorites.count >= MAX_FAVORITES)
    {
        [[SharedStates getInstance] showNotice:[NSString stringWithFormat:NSLocalizedString(@"You can collect locations not more than %d", nil), MAX_FAVORITES]];
        return NO;
    }
    
    [self.mFavorites insertObject:aRecord atIndex:0];
    [self storeFavorites];
    return YES;
}

- (BOOL) removeFavorite:(FavoritePOI*)aRecord
{
   
    for (FavoritePOI* sRecord in self.mFavorites)
    {
        if ([self equqlLocationA:sRecord.mLocation LocationB:aRecord.mLocation])
        {
            [self.mFavorites removeObject:sRecord];
            [self storeFavorites];
            return YES;
        }
    }
    return NO;
}

- (BOOL) isFavorited:(FavoritePOI*)aRecord
{
    return [self isLocationFavorited:aRecord.mLocation];
}

- (BOOL) isCoordinateFavorited:(CLLocationCoordinate2D)aCoordinate
{
    CLLocation* sLocation = [[CLLocation alloc] initWithLatitude:aCoordinate.latitude longitude:aCoordinate.longitude];
    
    BOOL sRet = [self isLocationFavorited:sLocation];
    
    [sLocation release];
    
    return sRet;
}

- (BOOL) isLocationFavorited:(CLLocation*)aLocation
{
    if (!aLocation)
    {
        return NO;
    }
    
    for (FavoritePOI* sRecord in self.mFavorites)
    {
        if ([self equqlLocationA:sRecord.mLocation LocationB:aLocation])
        {
            return YES;
        }
    }
    return NO;

}


- (BOOL) equqlLocationA:(CLLocation*)aLocationA LocationB:(CLLocation*)aLocationB
{
    if (!aLocationA
        && !aLocationB)
    {
        return YES;
    }
    
    if (aLocationA
        && aLocationB)
    {
        if ([aLocationA distanceFromLocation:aLocationB] < LOCATION_EQUAL_GRANULARITY)
        {
            return YES;
        }
    }
    
    return NO;
}

@end
