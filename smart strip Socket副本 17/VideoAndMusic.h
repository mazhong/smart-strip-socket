//
//  VideoAndMusic.h
//  MergeVideoAndMusic
//
//  Created by Summer on 16/3/16.
//  Copyright © 2016年 huchunyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
     ENUM_InfoTypeSuccess=0,       //成功
     ENUM_InfoTypeError1,          //视频长度不能为零
     ENUM_InfoTypeError2,          //开始时间大于视频长度
     ENUM_InfoTypeError3,          //截取视频内容大于视频长度
     ENUM_InfoTypeError4            //超过原视频长度
 
} ENUM_foType;







/**
 *  block返回信息
 *
 *  @param info     消息内容
 *  @param InfoType 消息类型 成功是0
 */
typedef void (^VideoAndMusicInfo ) (NSString *info,NSInteger InfoType );


@class VideoAndMusic,videoParameters;



@interface VideoAndMusic : NSObject


@property (nonatomic,assign) NSInteger InfoType;



@property(nonatomic,strong) VideoAndMusicInfo videoAndMusicInfo ;

//输入视频模型
-(void)inPutvideoParameters:(videoParameters *)videoParameters;
//删除视频文件
-(void)deloutPutFile :(NSString *)outPutFilePath;

@end

