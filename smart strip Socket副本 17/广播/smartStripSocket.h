//
//  smartStripSocket.h
//  广播
//
//  Created by Summer on 16/5/19.
//  Copyright © 2016年 iSmartAlarm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@class smartStripSocket;
@protocol smartStripSocketDelegate <NSObject>



/**
 *  获取插座的信息
 *
 *  @param isSwitchButtoStatus 插座开关
 *  @param ENUM_foType         插座网络状态
 *  @param Time                定时器的信息
 */
typedef void(^getStripStatus)(BOOL isSwitchButtoStatus,NSInteger ENUM_foType, NSDictionary *Time );

@end


@interface smartStripSocket : NSObject


@property(nonatomic,weak) id<smartStripSocketDelegate> delegate;

@property(nonatomic,assign)NSInteger ENUM_foType;



@property(nonatomic,strong) getStripStatus getStripStatusBlock;

#pragma mark- 建立与插座的连接


-(void)ConnectToHostWithMac:(NSString *)deviceMac ;
#pragma mark- 设网

-(void)setNetwithSSID:(NSString *)SSID andPassWord:(NSString *)PassWord;



#pragma mark- 开关

-(void)ONffWithIsButtonOn:(BOOL)isButtonOn;

#pragma mark- 定时
-(void)setTimeWithENUM_foType:(NSInteger)ENUM_foType
;

@end
