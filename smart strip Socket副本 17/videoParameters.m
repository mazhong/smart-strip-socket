//
//  videoParameters.m
//  MergeVideoAndMusic
//
//  Created by Summer on 16/3/23.
//  Copyright © 2016年 iSmartAlarm. All rights reserved.
//

#import "videoParameters.h"


@implementation videoParameters


-(BOOL)isEqual:(id)object
{
    if([self class] == [object class])
        
        
    {
        
//                //1.视频输入地址
//                if(![self.videoInputUrl isEqual:[(videoParameters *)object videoInputUrl]])
//                {
//                    NSLog(@"1");
//                    
//            
//                    return NO;
//                }
       
        if ([self.audioInputUrl absoluteString ].length==0&&[[(videoParameters *)object audioInputUrl  ]absoluteString].length==0) {

            
            NSLog(@"空字符串");
        }else{
        
            //2.音频输入地址
            if(![self.audioInputUrl isEqual:[(videoParameters *)object audioInputUrl]])
            {
                
                NSLog(@"%@---",self.audioInputUrl);
                NSLog(@"%@---",[(videoParameters *)object audioInputUrl]);
                
                NSLog(@"2");
                return NO;
                
                
            }
        
        
        
        }

    
        //3.视频开始时间
        if(![self.beginTime isEqual:[(videoParameters *)object beginTime]])
        {
     
              NSLog(@"3");
            return NO;
        }
        //4.视频长度
        if(![self.lengthOfVideo isEqual:[(videoParameters *)object lengthOfVideo]])
        {
            
            NSLog(@"---------%@",self.lengthOfVideo);
             NSLog(@"---------%@",[(videoParameters *)object lengthOfVideo]);
            
               NSLog(@"4");
            return NO;
        }
        //5.声音的种类
        if (![[NSString stringWithFormat: @"%ld", (long)self.TypeOfVioce]isEqual:[NSString stringWithFormat: @"%ld",(long)[(videoParameters *)object TypeOfVioce] ]])
        {
            
                NSLog(@"5");
            return NO;
        }
        //6.视频的种类
        if (![[NSString stringWithFormat: @"%f", self.rateOfVideo]isEqual:[NSString stringWithFormat: @"%f",[(videoParameters *)object rateOfVideo] ]])
            
            
            
        {
            NSLog(@"%f",self.rateOfVideo);
            
            NSLog(@"%f",[(videoParameters *)object rateOfVideo]);
            
            
               NSLog(@"6");
            return NO;
        }
        
        //7.是否加水印
        if (![[NSString stringWithFormat: @"%d", self.isAddWaterMark]isEqual:[NSString stringWithFormat: @"%d",[(videoParameters *)object isAddWaterMark] ]])
        {
            
                NSLog(@"7");
            return NO;
        }
        
        
        
        return YES;
    }
    else
    {
        return [super isEqual:object];
    }
}

-(void)setTypeOfVioce:(NSInteger)TypeOfVioce{


    _TypeOfVioce=TypeOfVioce;
    
    if (TypeOfVioce==100) {
        _TypeOfVioce=0;
        
        
    }
    
    else  if (_TypeOfVioce==101) {
        _TypeOfVioce=1;
    }
    else  if (_TypeOfVioce==102){
        _TypeOfVioce=2;
    }
    else if(_TypeOfVioce==103){
          _TypeOfVioce=3;
    }
    
    else {
        _TypeOfVioce=4;
    }


}


-(void)setRateOfVideo:(double )rateOfVideo{
    
    _rateOfVideo=rateOfVideo;
    
    if (_rateOfVideo==100) {
        _rateOfVideo=0.25;
    }
    
    else  if (_rateOfVideo==101) {
        _rateOfVideo=0.5;
    }
    else  if (_rateOfVideo==102){
        _rateOfVideo=1;
    }
    else if(_rateOfVideo==103){
    _rateOfVideo=2;
    }
    
    else {
            _rateOfVideo=4;
    }
    
}


@end
