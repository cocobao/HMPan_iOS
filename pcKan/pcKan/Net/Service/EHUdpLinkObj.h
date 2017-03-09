//
//  EHUdpLinkObj.h
//  picSimpleSend
//
//  Created by admin on 2016/10/14.
//  Copyright © 2016年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BROUADCAST_IP @"255.255.255.255"
#define BROUADCAST_PORT 39892
#define BIND_UDP_PORT 39891

@protocol pssUdpLinkDelegate <NSObject>
@optional
-(void)recvBoatcastWithIp:(NSString *)ip port:(NSInteger)port;
@end

@protocol pssMvDelegate <NSObject>
@optional
-(void)recvVideoData:(NSData*)data;
-(void)recvAudioData:(NSData*)data;
@end

@interface EHUdpLinkObj : NSObject
@property (nonatomic, weak) id<pssUdpLinkDelegate> m_delegate;
@property (nonatomic, weak) id<pssMvDelegate> m_mvDelegate;
-(void)setupUdpSpcket;
-(void)closeUdpSocket;

-(void)sendData:(NSData *)data toHost:(NSString *)host toPort:(NSInteger)port;
@end
