//
//  VideoAndMusic.m
//  MergeVideoAndMusic
//
//  Created by Summer on 16/3/16.
//  Copyright © 2016年 huchunyuan. All rights reserved.



#import "VideoAndMusic.h"
#import <AVFoundation/AVFoundation.h>
#import "videoParameters.h"


@implementation VideoAndMusic


-(void)inPutvideoParameters:(videoParameters *)videoParameters{
    //1.视频采集
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoParameters.videoInputUrl options:nil];

    //视频长度
    float second = 0;
    second = videoAsset.duration.value/videoAsset.duration.timescale;
   // NSLog(@"movie duration : %f", second);

    //判断
    NSString *lengOfVideo=[NSString stringWithFormat:@"%@",videoParameters.lengthOfVideo];
    if ([lengOfVideo isEqualToString:@"0"]) {
 
        // 回到主线程
       dispatch_async(dispatch_get_main_queue(), ^{
            
       
            //block
            if (_videoAndMusicInfo) {
             
                _videoAndMusicInfo(@"视频长度不能为零",ENUM_InfoTypeError1);
            }
    });

        return;
    }

    if (videoParameters.beginTime.intValue>=second) {
             self.InfoType= ENUM_InfoTypeError2;
        
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            //block
            if (_videoAndMusicInfo) {
                
                _videoAndMusicInfo(@"开始时间大于视频长度",ENUM_InfoTypeError2);
            }
        });
         return;
 
    }
    if (videoParameters.lengthOfVideo.intValue>second) {
        
           self.InfoType= ENUM_InfoTypeError3;
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            //block
            if (_videoAndMusicInfo) {
              
                _videoAndMusicInfo(@"截取视频内容大于视频长度"  ,ENUM_InfoTypeError3);
            }
        });

        return;
    }
    
    if((videoParameters.lengthOfVideo.intValue+videoParameters.beginTime.intValue)>second){
           self.InfoType= ENUM_InfoTypeError4;
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            //block
            if (_videoAndMusicInfo) {
                
                _videoAndMusicInfo(@"超过原视频长度"  ,ENUM_InfoTypeError4);
            }
        });

       return;
    }

    


    
    // 2.创建可变的 音视频组合
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    //3 .创建可变视频通道
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    
       //3.1截取
  
       NSError *videoInsertError = nil;
   // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长
    if([videoParameters.beginTime isEqualToString:@"" ]&&[videoParameters.lengthOfVideo isEqualToString:@"" ]){
    
       [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                                                    ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                                     atTime:kCMTimeZero
                                                                      error:&videoInsertError];
    }else if(![videoParameters.beginTime isEqualToString:@"" ]&&[videoParameters.lengthOfVideo isEqualToString:@"" ]){
  
        // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长
       [compositionVideoTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds([videoParameters.beginTime intValue], 30),
            CMTimeMakeWithSeconds(second-[videoParameters.beginTime intValue], 30))
                                                                ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                                 atTime:kCMTimeZero
                                                                  error:&videoInsertError];
        
    }
    else if([videoParameters.beginTime isEqualToString:@"" ]&&![videoParameters.lengthOfVideo isEqualToString:@"" ]){
     
        // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长
      [compositionVideoTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 30),
            CMTimeMakeWithSeconds([videoParameters.lengthOfVideo intValue], 30))
                                                                ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                                 atTime:kCMTimeZero
                                                                  error:&videoInsertError];
    }
    else{

        // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长
      [compositionVideoTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds([videoParameters.beginTime intValue], 30),
                                                                                        CMTimeMakeWithSeconds([videoParameters.lengthOfVideo intValue], 30))
                                                                ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                                 atTime:kCMTimeZero
                                                                  error:&videoInsertError];
    
    }
 //   NSLog(@"videoParameters.videoType=======%ld",(long)videoParameters.videoType);
    
   // if(!videoParameters.rateOfVideo==1){
        
                //4. 视频加速
        double videoScaleFactor = videoParameters.rateOfVideo;
        NSLog(@"%f", videoScaleFactor);
        CMTime videoDuration = videoAsset.duration;
        
        [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
                                   toDuration:CMTimeMake(videoDuration.value/videoScaleFactor, videoDuration.timescale)];
    
  //  }

    //5.视频采集通道
    AVAssetTrack *avAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
   
    
    
    // 6.创建可变视频组合
    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition] ;
    


            // 视频采集通道 的frame
            
            CGSize naturalSize;
            
            naturalSize = avAssetTrack.naturalSize;
            
            
            float renderWidth, renderHeight;
            renderWidth = naturalSize.width;
            renderHeight = naturalSize.height;
           // 可变视频组合  的大小
            avMutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
            //  固定的属性
            avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
      // 7.添加视频水印
     //    NSString *WatermarkSting=[NSString stringWithFormat:@"%@",videoParameters.Watermark];
    
    if (videoParameters.AddWaterMark) {

        
        CALayer  *animatedTitleLayer = [self buildAnimatedTitleLayerForSize:CGSizeMake(renderWidth, renderHeight) videoParameters:videoParameters];
                    CALayer *parentLayer = [CALayer layer];
                    CALayer *videoLayer = [CALayer layer];
                    parentLayer.frame = CGRectMake(0, 0, renderWidth, renderHeight);
                    videoLayer.frame = CGRectMake(0, 0, renderWidth, renderHeight);
                    [parentLayer addSublayer:videoLayer];
                    [parentLayer addSublayer:animatedTitleLayer];
                    //重点
                    avMutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        
    }

    
            // 8 创建视频组合指令AVMutableVideoCompositionInstruction，并设置指令在视频的作用时间范围和旋转矩阵变换
            AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            // 8.1  并设置指令在视频的作用时间范围
            
            [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [mixComposition duration])];
            
            
            // 9 创建视频组合图层指令AVMutableVideoCompositionLayerInstruction，并设置图层指令在视频的作用时间范围和旋转矩阵变换
            AVMutableVideoCompositionLayerInstruction *avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
            // 9 .1 并设置图层指令在视频的作用时间范围和旋转矩阵变换
            
            [avMutableVideoCompositionLayerInstruction setTransform:avAssetTrack.preferredTransform atTime:kCMTimeZero];
            
            //10    把视频图层指令放到视频指令中，再放入视频组合对象中
            avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObject:avMutableVideoCompositionLayerInstruction];
            
            // 10 .1  创建可变视频组合 的 指令 = 可变视频组合的指令
            avMutableVideoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];

    //路径
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    
    //时间戳
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSString *dateStr=[NSString stringWithFormat:@"merge%@.mp4",locationString];
    
    // 最终合成输出路径
    
    NSString *outPutFilePath = [documents stringByAppendingPathComponent:dateStr];
    
    
    // 合成  输出路径
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    
    
    
    //11 创建一个输出
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    //重要
    [assetExport setVideoComposition:avMutableVideoComposition];
    // 输出类型
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    // 输出地址
    assetExport.outputURL = outputFileUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
       
            
    
          
            [self inputUpVideo:outPutFilePath AndVideoParameters:videoParameters ];
       
        });
    }];
    



}


/**
 *  合成视频和音频文件
 *
 *  @param VideoInputUrl   视频文件的地址
 *  @param videoParameters 视频文件模型
 */
-(void)inputUpVideo:( NSString *)outPutFilePath AndVideoParameters:(videoParameters *)videoParameters;

{
    // 合成  输出路径
    NSURL *VideoInputUrl = [NSURL fileURLWithPath:outPutFilePath];
 

    // 时间起点
    CMTime nextClistartTime = kCMTimeZero;
    
    // 创建可变的音视频组合
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    
    // 视频采集
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:VideoInputUrl options:nil];
    
    
    // 视频时间范围
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // 视频采集通道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //  把采集轨道数据加入到可变轨道之中
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    
   // NSLog(@"%@",videoParameters.AddVioce);
    //声音轨道
    NSURL *audioInputUrl =nil;
    if (videoParameters.TypeOfVioce>0) {
        
        
     //   NSURL  videoParameters.audioInputUrl=nil;
      
        if (videoParameters.TypeOfVioce==1) {
        
                  // 声音来源
           audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Time will come" ofType:@"mp3"]];
    

        }else if(videoParameters.TypeOfVioce==2){
        
            // 声音来源
       audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"309769" ofType:@"mp3"]];
           
        
        
        
        }else if (videoParameters.TypeOfVioce==3){
            // 声音来源
          audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"秘密" ofType:@"mp3"]];
      
        
        
        }else{
        
            
            NSLog(@"我在videoParameters--------%@",  videoParameters.audioInputUrl);
        
         audioInputUrl =videoParameters.audioInputUrl;
        
        
        
        }
        
        
        
        
        // 声音采集
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:nil];
        // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
        CMTimeRange audioTimeRange = videoTimeRange;
        // 音频通道
        AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 音频采集通道
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        // 加入合成轨道之中
        [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
   }

    
    
    
    
    // 创建一个输出
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPresetMediumQuality];
    // 输出类型
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    // 输出地址
    assetExport.outputURL = videoParameters.VideoOutPutUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
  
            //删除上次生成的文件
           [self deloutPutFile:outPutFilePath];
         self.InfoType= ENUM_InfoTypeSuccess;
            
        
             
            //block
            if (_videoAndMusicInfo) {
     
                _videoAndMusicInfo( [videoParameters.VideoOutPutUrl absoluteString],ENUM_InfoTypeSuccess);
            }
        });
    }];



}

/**

    视频水印
 *
 *  @param videoSize 视频大小
 *
 *  @param waterMarkNssting 水印文字内容
 *
 *  @return 返回图层
 */
- (CALayer *)buildAnimatedTitleLayerForSize:(CGSize)videoSize videoParameters:(videoParameters *)videoParameters;
{
    
    
    // 视频的显示大小
    CGSize dataLayerSize = CGSizeMake(videoSize.width, videoSize.height);
    // Create a layer for the overall title animation.
    CALayer *animatedTitleLayer = [CALayer layer];
    
    animatedTitleLayer.frame = CGRectMake(0, 0, dataLayerSize.width, dataLayerSize.height);

    animatedTitleLayer.backgroundColor = [UIColor clearColor].CGColor;
// //   if (videoParameters.WatermarkType==2) {

    
     //   return animatedTitleLayer;

        // 图片水印
            UIImage *waterMarkImage = [UIImage imageNamed:@"hualai1"];
            CALayer *watertupianMarkLayer = [CALayer layer];
            watertupianMarkLayer.contents = (id)waterMarkImage.CGImage ;
        
           // watertupianMarkLayer.frame = CGRectMake(0,dataLayerSize.height-waterMarkImage.size.height, waterMarkImage.size.width, waterMarkImage.size.height);
    
           watertupianMarkLayer.frame = CGRectMake(dataLayerSize.width-waterMarkImage.size.width-50,waterMarkImage.size.height+45, waterMarkImage.size.width, waterMarkImage.size.height);

    
    NSLog(@"%f  %f",waterMarkImage.size.width,waterMarkImage.size.height);
    
         //   NSLog(@"%f-----%f",dataLayerSize.height,waterMarkImage.size.height);
        //透明度   1.是不透明
        watertupianMarkLayer.opacity = 1.0f;
        
    
        [animatedTitleLayer addSublayer:watertupianMarkLayer];
    
    
    // 文字水印
    // 1 - Set up the text layer
    CATextLayer *waterMarkLayer = [[CATextLayer alloc] init];
    
 
    //字体名字

    
    waterMarkLayer.font = (__bridge CFTypeRef _Nullable)(@"HelveticaNeue-Light");
    
   //waterMarkLayer.font = (__bridge CFTypeRef _Nullable)(@"HelveticaNeue-Bold");
    
    
    waterMarkLayer.fontSize = 42;
  
    videoParameters.Watermark=@"ismartalarm.com";
   
    
    //水印文字内容
    [waterMarkLayer setString:videoParameters.Watermark];
    //水印文字对齐方式
    [waterMarkLayer setAlignmentMode:kCAAlignmentLeft];
    //水印文字颜色
    [waterMarkLayer setForegroundColor:[[UIColor greenColor] CGColor]];
    //水印的frame
  //  CGSize titleSize= [videoParameters.Watermark sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:40]}];
    
    CGFloat  waterMarkLayerX=dataLayerSize.width-waterMarkImage.size.width-50;
    CGFloat  waterMarkLayerY=25;
    CGFloat  waterMarkLayerW=320;
    CGFloat  waterMarkLayerH=60;
    
    
    waterMarkLayer.frame = CGRectMake(waterMarkLayerX,waterMarkLayerY, waterMarkLayerW, waterMarkLayerH);
    
    //  waterMarkLayer.frame = CGRectMake(waterMarkLayerX,waterMarkLayerY, waterMarkLayerW, waterMarkLayerH);
    
    //透明度   1.是不透明
    waterMarkLayer.opacity = 1.0f;
    waterMarkLayer.contentsScale = 4.0f;
    
    waterMarkLayer.wrapped = YES;
    [animatedTitleLayer addSublayer:waterMarkLayer];

    return animatedTitleLayer;


}

-(void)deloutPutFile :(NSString *)outPutFilePath

{
    NSLog(@"dsad");

    
    NSFileManager *defaultManager;
    
    defaultManager = [NSFileManager defaultManager];
    
    
    
    BOOL boolValue=[defaultManager removeItemAtPath: outPutFilePath error: nil];
    
    
    
    if (boolValue)
        
    {
        
        NSLog(@"删除文件成功 ok");
        
    } else{
    
        NSLog(@"失败");
    }
    
}








@end
