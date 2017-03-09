//
//  g711.h
//  pcKan
//
//  Created by admin on 2017/2/20.
//  Copyright © 2017年 ybz. All rights reserved.
//

#ifndef g711_h
#define g711_h

int ulaw2linear(unsigned char u_val);
int alaw2linear(unsigned char a_val);
unsigned char linear2alaw(int pcm_val);
unsigned char linear2ulaw(int pcm_val) ;
#endif /* g711_h */
