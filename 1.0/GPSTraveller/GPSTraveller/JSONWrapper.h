//
//  JSONWrapper.h
//  AboutSex
//
//  Created by Wen Shane on 12-12-12.
//
//

#import <Foundation/Foundation.h>

@interface JSONWrapper : NSObject

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

@end
