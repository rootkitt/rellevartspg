//
//  JSONWrapper.m
//  AboutSex
//
//  Created by Wen Shane on 12-12-12.
//
//

#import "JSONWrapper.h"
#import "SBJson.h"


@implementation JSONWrapper

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    id jsonObject = nil;
    if ([self isNSJSONSerializationClassExistent]) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:opt   error:error];
    }
    else
    {
        SBJsonParser *parser = [SBJsonParser new];
        jsonObject = [parser objectWithData:data];
        [parser release];
    }
    
    return jsonObject;
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error
{
    NSData* sData = nil;
    if ([self isNSJSONSerializationClassExistent])
    {
        sData = [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
    }
    else
    {
        SBJsonWriter* write = [[SBJsonWriter alloc] init];
        sData = [write dataWithObject:obj];
        [write release];
    }
    return sData;
}

+ (BOOL) isNSJSONSerializationClassExistent
{
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (jsonSerializationClass)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
