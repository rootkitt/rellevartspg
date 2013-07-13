//
//  Utility.h
//  BTT
//
//  Created by Wen Shane on 12-12-10.
//  Copyright (c) 2012年 Wen Shane. All rights reserved.
//

#ifndef SHARED_VARIABLES_H
#define SHARED_VARIABLES_H


#define APP_KEY_UMENG   @"50e6decf527015180c000011"


//#define NO_DISTANCE_LIMIT
//#define WEI_PHONE_RELEASE
#define TEST

#if defined(APP_STORE_RELEASE)
#define CHANNEL_ID  @"REAL_APP_STORE"
#define CHANNEL_ID_INT  1
#elif defined(WEI_PHONE_RELEASE)
#define CHANNEL_ID  @"Weiphone"
#define CHANNEL_ID_INT  2
#elif defined(_91STORE_RELEASE)
#define CHANNEL_ID  @"91store"
#define CHANNEL_ID_INT  3
#elif defined(TONGBU_RELEASE)
#define CHANNEL_ID  @"Tongbu"
#define CHANNEL_ID_INT  4
#elif defined(_178_RELEASE)
#define CHANNEL_ID @"178"
#define CHANNEL_ID_INT  5
#elif (defined(DEBUG) || defined(TEST))
#define CHANNEL_ID  @"test"
#define CHANNEL_ID_INT  1000
#else
#define CHANNEL_ID  @"Other"
#define CHANNEL_ID_INT  -1
#endif


#define RGB_DIV_255(x)      ((CGFloat)(x/255.0))

#define RGBA_COLOR(r, g, b, a)   ([UIColor colorWithRed:RGB_DIV_255(r) green:RGB_DIV_255(g) blue:RGB_DIV_255(b) alpha:a])



#define COLOR_FLOAT_BUTTON_ON_MAP        RGBA_COLOR(0, 0, 0, 0.3)

#define COLOR_GRADIENT_START_INFO_BOARD     RGBA_COLOR(0, 0, 0, 0.7)

#define COLOR_GRADIENT_END_INFO_BOARD       RGBA_COLOR(0, 0, 0, 0.0)




#define SIDEBAR_OFFSET   50


#define HOST_URL_STR                @"http://aboutsex.sinaapp.com/"
#define URL_GET_HOT_POIS            ([HOST_URL_STR stringByAppendingString: @"/gpst/pois/get_hot_pois.php"])



#define  SECRET_ID_YOUMI            @"c599b586826d1494" 
#define  SECRET_KEY_YOUMI           @"e7f9e8514913c31a" 


#endif
