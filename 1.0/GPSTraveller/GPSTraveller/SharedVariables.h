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


#define WEIPHONE

#ifdef DEBUG
#define CHANNEL_ID     @"test"
#elif defined(APPSTORE)
#define CHANNEL_ID @"appstore"
#elif defined(WEIPHONE)
#define CHANNEL_ID @"weiphone"
#elif defined(_178)
#define CHANNEL_ID @"178"
#elif defined(ZHUSHOU91)
#define CHANNEL_ID @"91"
#elif defined(TONGBU)
#define CHANNEL_ID @"tongbu"
#elif defined(COCOACHINA)
#define CHANNEL_ID @"COCOACHINA"
#endif



#define RGB_DIV_255(x)      ((CGFloat)(x/255.0))

#define RGBA_COLOR(r, g, b, a)   ([UIColor colorWithRed:RGB_DIV_255(r) green:RGB_DIV_255(g) blue:RGB_DIV_255(b) alpha:a])



#define COLOR_FLOAT_BUTTON_ON_MAP        RGBA_COLOR(0, 0, 0, 0.6)

#define COLOR_GRADIENT_START_INFO_BOARD     RGBA_COLOR(0, 0, 0, 0.7)

#define COLOR_GRADIENT_END_INFO_BOARD       RGBA_COLOR(0, 0, 0, 0.0)




#define SIDEBAR_OFFSET   50


#define HOST_URL_STR                @"http://aboutsex.sinaapp.com/"
#define URL_GET_HOT_POIS            ([HOST_URL_STR stringByAppendingString: @"/gpst/pois/get_hot_pois.php"])



#define  SECRET_ID_YOUMI            @"c599b586826d1494" 
#define  SECRET_KEY_YOUMI           @"e7f9e8514913c31a" 


#endif
