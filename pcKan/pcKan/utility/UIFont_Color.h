//
//  UIFont_Color.h
//  iosBasis
//
//  Created by admin on 2016/9/23.
//  Copyright © 2016年 ybz. All rights reserved.
//

#ifndef UIFont_Color_h
#define UIFont_Color_h
#define ColorFromHex(x) [UIColor colorWithRed:(((x>>16)&0xFF) / 255.0f) green:(((x>>8)&0xFF) / 255.0f) blue:(((x)&0xFF) / 255.0f) alpha:1.0]
#define ColorFromHexRGBA(x) [UIColor colorWithRed:(((x>>24)&0xFF) / 255.0f) green:(((x>>16)&0xFF) / 255.0f) blue:(((x>>8)&0xFF) / 255.0f) alpha:(((x)&0xFF) / 255.0f)]

#define DEFAULT_NAV_TINTCOLOR [UIColor whiteColor]//[UIColor colorWithRed:0.42f green:0.33f blue:0.27f alpha:1.00f]

#define Color_black(x)   [UIColor colorWithRed:0 green:0 blue:0  alpha:0.01f*x]
#define Color_white(x)   [UIColor colorWithRed:0xff green:0xff blue:0xff  alpha:0.01f*x]

/***  粗体 */
#define kBoldFont(size) [UIFont boldSystemFontOfSize:size]
/***  普通字体 */
#define kFont(size) [UIFont systemFontOfSize:size]


#define kComenTextColor ColorFromHex(0xf828282)

#define Color_Line      ColorFromHex(0xE3E3E3)

#define Color_5a5a5a    ColorFromHex(0x5a5a5a)
#define Color_bfbfbf    ColorFromHex(0xbfbfbf)
#define Color_828282    ColorFromHex(0xf828282)

#define Color_Main                          ColorFromHex(0x00a0e9)
#define Color_Main_80                       ColorFromHexRGBA(0xEC6500CD)
#define Color_Main_50                       ColorFromHexRGBA(0xEC65007f)
#define Color_Main_40                       ColorFromHexRGBA(0xEC650066)
#define Color_Main_30                       ColorFromHexRGBA(0xEC65004d)
#define Color_Main_20                       ColorFromHexRGBA(0xEC650033)
#define Color_Main_10                       ColorFromHexRGBA(0xEC650019)

#define Color_BackGround ColorFromHex(0xf5f5f5)

#endif /* UIFont_Color_h */
