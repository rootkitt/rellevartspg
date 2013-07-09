//
//  MarsCoordinator.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-7-3.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

/*
 火星坐标转换，还可以采用以下两种方法：
 
 1、可以用纯代码实现地球坐标到火星坐标的转换，见https://on4wp7.codeplex.com/SourceControl/changeset/view/21483#353936
 // Copyright (C) 1000 - 9999 Somebody Anonymous
 // NO WARRANTY OR GUARANTEE
 //
 
 using System;
 
 namespace Navi
 {
 class EvilTransform
 {
 const double pi = 3.14159265358979324;
 
 //
 // Krasovsky 1940
 //
 // a = 6378245.0, 1/f = 298.3
 // b = a * (1 - f)
 // ee = (a^2 - b^2) / a^2;
 const double a = 6378245.0;
 const double ee = 0.00669342162296594323;
 
 //
 // World Geodetic System ==> Mars Geodetic System
 public static void transform(double wgLat, double wgLon, out double mgLat, out double mgLon)
 {
 if (outOfChina(wgLat, wgLon))
 {
 mgLat = wgLat;
 mgLon = wgLon;
 return;
 }
 double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
 double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
 double radLat = wgLat / 180.0 * pi;
 double magic = Math.Sin(radLat);
 magic = 1 - ee * magic * magic;
 double sqrtMagic = Math.Sqrt(magic);
 dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
 dLon = (dLon * 180.0) / (a / sqrtMagic * Math.Cos(radLat) * pi);
 mgLat = wgLat + dLat;
 mgLon = wgLon + dLon;
 }
 
 static bool outOfChina(double lat, double lon)
 {
 if (lon < 72.004 || lon > 137.8347)
 return true;
 if (lat < 0.8293 || lat > 55.8271)
 return true;
 return false;
 }
 
 static double transformLat(double x, double y)
 {
 double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.Sqrt(Math.Abs(x));
 ret += (20.0 * Math.Sin(6.0 * x * pi) + 20.0 * Math.Sin(2.0 * x * pi)) * 2.0 / 3.0;
 ret += (20.0 * Math.Sin(y * pi) + 40.0 * Math.Sin(y / 3.0 * pi)) * 2.0 / 3.0;
 ret += (160.0 * Math.Sin(y / 12.0 * pi) + 320 * Math.Sin(y * pi / 30.0)) * 2.0 / 3.0;
 return ret;
 }
 
 static double transformLon(double x, double y)
 {
 double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.Sqrt(Math.Abs(x));
 ret += (20.0 * Math.Sin(6.0 * x * pi) + 20.0 * Math.Sin(2.0 * x * pi)) * 2.0 / 3.0;
 ret += (20.0 * Math.Sin(x * pi) + 40.0 * Math.Sin(x / 3.0 * pi)) * 2.0 / 3.0;
 ret += (150.0 * Math.Sin(x / 12.0 * pi) + 300.0 * Math.Sin(x / 30.0 * pi)) * 2.0 / 3.0;
 return ret;
 }
 }
 }

2、参见 http://www.cnblogs.com/Tangf/archive/2012/09/16/2687236.html
  可以调用百度的api实现：http://api.map.baidu.com/ag/coord/convert?x=121.583140&y=31.341174&from=0&to=2&mode=1
 说明：x和y就是经纬度了，替换成你真实的经纬度即可，from和to表示坐标系，0表示地球坐标，2表示火星坐标，4表示百度坐标，所以这里是从地球坐标转换成火星坐标，mode参数未知。
 
 结果：[{"error":0,"x":"MTIxLjU4NzM2NDA5NTA1","y":"MzEuMzM5MDI3NTA2NTE="}]
 
 说明：error为0表示没有错误，返回的x和y是base64算法后的结果(可以自行Google加解密base64)，解密后就是：121.58736409505和31.33902750651，这个就是火星坐标。
 
 
*/

#import "MarsCoordinator.h"

@interface MarsCoordinator()
{
    CSqlite *m_sqlite;
}

@end

@implementation MarsCoordinator

+ (MarsCoordinator*) shared
{
    static MarsCoordinator* S_MarsCoordinator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        S_MarsCoordinator = [[self alloc] init];
    });
 
    return S_MarsCoordinator;
}

+ (BOOL) isOutOfChina:(CLLocationCoordinate2D)aRealCoordinate
{
    if (aRealCoordinate.longitude < 72.004 || aRealCoordinate.longitude > 137.8347)
        return YES;
    if (aRealCoordinate.latitude < 0.8293 || aRealCoordinate.latitude > 55.8271)
        return YES;
    return NO;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        m_sqlite = [[CSqlite alloc]init];
        [m_sqlite openSqlite];
    }
    return self;
}

- (void) dealloc
{
    [m_sqlite closeSqlite];
    [m_sqlite release];
    m_sqlite = nil;
    
    [super dealloc];
}

-(CLLocationCoordinate2D) getMarsCoordinateFromRealCoordinate:(CLLocationCoordinate2D)aRealCoordinate2D
{
    //
    if ([MarsCoordinator isOutOfChina:aRealCoordinate2D])
    {
        return aRealCoordinate2D;
    }
    
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(aRealCoordinate2D.latitude*10);
    TenLog = (int)(aRealCoordinate2D.longitude*10);
    NSString *sql = [NSString stringWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
//    NSLog(sql);
    sqlite3_stmt* stmtL = [m_sqlite NSRunSql:sql];
    int offLat=0;
    int offLog=0;
    while (sqlite3_step(stmtL)==SQLITE_ROW)
    {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
    }
    
    CLLocationCoordinate2D sMarsCoordinate2D;
    sMarsCoordinate2D.latitude = aRealCoordinate2D.latitude+offLat*0.0001;
    sMarsCoordinate2D.longitude = aRealCoordinate2D.longitude + offLog*0.0001;
    return sMarsCoordinate2D;
}

- (CLLocation*) getMarsLocationFromRealLocation:(CLLocation*)aLocation
{
    CLLocationCoordinate2D sCoordindate2D = [self getMarsCoordinateFromRealCoordinate:aLocation.coordinate];
    
    CLLocation* sLocation = [[[CLLocation alloc] initWithCoordinate:sCoordindate2D altitude:aLocation.altitude horizontalAccuracy:aLocation.horizontalAccuracy verticalAccuracy:aLocation.verticalAccuracy timestamp:aLocation.timestamp] autorelease];
    
    return sLocation;
}


//因为没有反向转换(火星坐标->地球坐标)的偏移数据库，直接使用正向偏移反推回来就够了，毕竟在小范围内该算法偏移差距都不大。
- (CLLocationCoordinate2D) getRealCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)aMarsCoordinate
{
    CLLocationCoordinate2D sMarsOfMarsCoordinate = [self getMarsCoordinateFromRealCoordinate:aMarsCoordinate];
    CLLocationCoordinate2D sCoordinateDelta;
    sCoordinateDelta.latitude = sMarsOfMarsCoordinate.latitude-aMarsCoordinate.latitude;
    sCoordinateDelta.longitude = sMarsOfMarsCoordinate.longitude-aMarsCoordinate.longitude;
    
    CLLocationCoordinate2D sRealCoordinate2D;
    sRealCoordinate2D.latitude = aMarsCoordinate.latitude-sCoordinateDelta.latitude;
    sRealCoordinate2D.longitude = aMarsCoordinate.longitude-sCoordinateDelta.longitude;
    
    return sRealCoordinate2D;
}

- (CLLocation*) getRealLocationFromMarsLocation:(CLLocation*)aMarsLocation
{
    CLLocationCoordinate2D sCoordindate2D = [self getRealCoordinateFromMarsCoordinate:aMarsLocation.coordinate];
    
    CLLocation* sLocation = [[[CLLocation alloc] initWithCoordinate:sCoordindate2D altitude:aMarsLocation.altitude horizontalAccuracy:aMarsLocation.horizontalAccuracy verticalAccuracy:aMarsLocation.verticalAccuracy timestamp:aMarsLocation.timestamp] autorelease];
    
    return sLocation;
}

@end
