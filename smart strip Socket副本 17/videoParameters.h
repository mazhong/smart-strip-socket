//
//  videoParameters.h
//  MergeVideoAndMusic
//
//  Created by Summer on 16/3/23.
//  Copyright © 2016年 iSmartAlarm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface videoParameters : NSObject



/**    视频输入地址  */
@property(nonatomic,copy)NSURL   *videoInputUrl;

/**    音频输入地址 */
@property(nonatomic,copy)NSURL   *audioInputUrl;

/**    合成后的视频地址 */
@property(nonatomic,copy)NSURL   *VideoOutPutUrl;


/**    视频水印文字    */
@property(nonatomic,copy)NSString     *Watermark;


/**    视频水印类型   */   //0是无水印 1是图片水印 3是文字水印
@property(nonatomic,assign)NSInteger  WatermarkType;
/**    是否有水印    */
@property(nonatomic,getter=isAddWaterMark)BOOL AddWaterMark;

/**    视频开始时间    */
@property(nonatomic,copy)NSString     *beginTime;
/**    截取的视频长度    */
@property(nonatomic,copy)NSString     *lengthOfVideo;

/**    视频速率    */
@property(nonatomic,assign)double rateOfVideo;
/**    视频加速类型   */
@property(nonatomic,assign)NSInteger  videoType;

/**    声音的类型    */
@property(nonatomic,assign)NSInteger TypeOfVioce;

/**    是否有声音    */
@property(nonatomic, getter=isAddVioce) BOOL AddVioce;
/**    对象是否有相等   */
-(BOOL)isEqual:(id)object;

@end
