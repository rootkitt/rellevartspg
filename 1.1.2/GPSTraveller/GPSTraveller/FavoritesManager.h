//
//  FavoritesManager.h
//  GPSTraveller
//
//  Created by Wen Shane on 13-4-3.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface FavoritesManager : NSObject
{
    NSMutableArray* mFavorites;
}
@property (nonatomic, retain) NSMutableArray* mFavorites;

+ (FavoritesManager*) shared;

- (NSArray*) getAllFavorites;

- (BOOL) addFavorite:(FavoritePOI*)aRecord;//return NO if it already exists.
- (BOOL) removeFavorite:(FavoritePOI*)aRecord;//return NO if it does not exist.
- (BOOL) isFavorited:(FavoritePOI*)aRecord;
- (BOOL) isCoordinateFavorited:(CLLocationCoordinate2D)aCoordinate;
@end
