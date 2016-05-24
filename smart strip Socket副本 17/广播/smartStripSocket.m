//
//  smartStripSocket.m
//  广播
//
//  Created by Summer on 16/5/19.
//  Copyright © 2016年 iSmartAlarm. All rights reserved.
//

#import "smartStripSocket.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "TDO.h"


#define   LocalONTag       151
#define   LocalOffTag      152
#define   LocalFinfTag     153
#define   LocalWirteTag    154

#define   RemoteONTag       201
#define   RemoteOffTag      202
#define   RemoteFindTag     203
#define   RemoteWirteTag    204


#define   LocalPort   9957
#define   RemotePort   9955


//#define   deviceMac    @"7c:dd:90:9c:05:1A"
typedef enum {
    
    /**
     *  没网
     */
    ENUM_InfoTypWithoutNetwork=0,
    /**
     *  远程
     */
    ENUM_InfoTyRemote,
    
    /**
     *  本地
     */
    ENUM_InfoTyLocal,
    
    
    
    
    
} ENUM_foType;



@interface smartStripSocket ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
@property(nonatomic,strong)GCDAsyncUdpSocket *asyncUdpSocket;


@property(nonatomic,strong)GCDAsyncSocket    *asyncRemoteSocket;

@property(nonatomic,strong)GCDAsyncSocket    *asyncLocalSocket;


@property(nonatomic,strong)NSTimer *RemoteWriteQuerytimer;

@property(nonatomic,strong)NSTimer *LocalWriteQuerytimer;



@property (nonatomic, copy  ) NSString       *socketMacHost;   // socket的Host


@property (nonatomic, assign) UInt16         socketPort;    // socket的prot

@property (nonatomic, copy  ) NSString       *deviceMac;   // 设备的Host


@property(nonatomic,getter=isSwitchButtoON)BOOL IsSwitchButtoStatus;

//@property (nonatomic, copy  ) NSString       *socketMacHost;   // socket的Host


@end



@implementation smartStripSocket



#pragma mark- 建立与开关的连接
-(void)ConnectToHostWithMac:(NSString *)deviceMac{
    
    
    _deviceMac=deviceMac;
    
    //1.先发送本地find请求
    
    for (NSUInteger i = 0; i < 3; i++)
    {
        
        
        
        [self LocalFind];
        
    }
    NSLog(@"第一次----%ld",(long)self.ENUM_foType);
    
    //2。延时3秒去判断
    [self performSelector:@selector(judge) withObject:nil afterDelay:3.0f];
    

    
    
}



#pragma mark- 判断内外网
-(void)judge{
    
    NSLog(@"第二次-----%ld",(long)self.ENUM_foType);
    
    
    
    if (self.ENUM_foType==ENUM_InfoTypWithoutNetwork) {
        
        //远程连接
        [self connectRemoteTCPSocket];
    }
    
}


#pragma mark- 设置定时

-(void)setTimeWithENUM_foType:(NSInteger)ENUM_foType
{
    


    
    if (ENUM_foType==ENUM_InfoTyLocal) {
        if (!_asyncLocalSocket) {
            
            NSLog(@"创建_本地定时任务");
            [self connectLocalTCPSocket];
            
        }
    }
    
 else if (ENUM_foType==ENUM_InfoTyRemote) {
        if (!_asyncRemoteSocket) {
            
            NSLog(@"创建_远程定时任务");
            [self connectRemoteTCPSocket];
            
        }
    }
    
    
    NSLog(@"定时任务");
    
    TDO *tdo = [[TDO alloc] init];
    
    // NSData *data2= [tdo SetGPIOData:0 andStatus:0 andRemoteMac: _deviceMac andLocalMac:@"06:26:d5:5a:0a:76" andSerial:2];
    
    
    NSData *data2= [tdo SetTimingControlData:-1 andWeek:255 andEnableOpenTime:YES andOpenHour:9 andOpenMinute:44 andEnableCloseTime:YES andCloseHour:9 andCloseMinute:45 andLabel:@"Time" andUse:1 andStatus:ENUM_foType andRemoteMac:_deviceMac andLocalMac:@"dc:dd:90:2d:57:s0" andSerial:5];
    
    [_asyncLocalSocket writeData:data2 withTimeout:-1 tag:LocalOffTag];
    
    
    
    [_asyncLocalSocket readDataWithTimeout:-1 tag:LocalOffTag];
    
    
    
    
    
}

#pragma mark- 开关
-(void)ONffWithIsButtonOn:(BOOL)isButtonOn{
    
    
    NSLog(@"%ld",(long)self.ENUM_foType);
    
    if (isButtonOn) {
        NSLog(@" 开");
        
        if (  self.ENUM_foType==ENUM_InfoTyLocal) {
            
            
            
            // [本地 开]；
            
            [self LocalSocketON];
           [self getLocalStatus];
            
            
            
        }
        else if(self.ENUM_foType==ENUM_InfoTyRemote){
            
            // [远程 开]；
            
            [self RemoteON];
           [self getRemoteStatus];
        }
        
        
        
    }
    
    else {
        
        
        NSLog(@"关");
        
        if (  self.ENUM_foType==ENUM_InfoTyLocal) {
            
            
            // [本地 关]；
            
            [self LocalSocketOFF];
            [self getLocalStatus];
            
        }
        else if(self.ENUM_foType==ENUM_InfoTyRemote){
            
            // [远程 关]；
            
            [self RemoteOFF];
          [self getRemoteStatus];
            
            
        }
    }
    
    
    
}

#pragma mark- 设网

    
-(void)setNetwithSSID:(NSString *)SSID andPassWord:(NSString *)PassWord{
    

    NSLog(@"设网");

    [self connectUDPSocket];

    NSTimeInterval timeout=2;


    TDO *tdo = [[TDO alloc] init];



    // iOScisco  IOS87611660
    //输入 wifi 和 密码
   NSArray *SmartConfigArray = [[NSArray alloc] initWithArray:[tdo SmartConfigSetSSID:SSID andSetPassWord:PassWord]];
    
     NSLog(@"%@---%@",SSID,PassWord);


   //  发10次
    for (int count=0; count<10; count++) {

       // NSLog(@"%d",count);

        for (int i=0; i<SmartConfigArray.count; i++) {


       //     NSLog(@"%d",i);
            NSData *data=[[SmartConfigArray objectAtIndex:i]   dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@",[SmartConfigArray objectAtIndex:i]);
            [_asyncUdpSocket sendData:data

                               toHost:[SmartConfigArray objectAtIndex:i]
                                 port:9957
                          withTimeout:timeout

                                  tag:0];


            NSError *err = nil;

            [_asyncUdpSocket enableBroadcast:YES error:&err];

            [_asyncUdpSocket beginReceiving:&err];


        }

    }


}





#pragma mark- 获取远程状态   远程读写指令
-(void)getRemoteStatus{
    
  
    
    NSLog(@"远程读写指令");
    
    if (!_asyncRemoteSocket) {
        
        NSLog(@"asyncRemoteSocket，远程");
        
        
        [self connectRemoteTCPSocket];
        
        
    }
    
    TDO *tdo = [[TDO alloc] init];
   //   NSLog(@"_deviceMac===%----@",_deviceMac);
    
    NSData *RWQueryData= [tdo WriteQuerySwitchData:1 andRemoteMac: _deviceMac andLocalMac:@"06:26:d5:5a:0a:76" andSerial:2];
    
    
    
    [_asyncRemoteSocket writeData:RWQueryData withTimeout:-1 tag:RemoteWirteTag];
    
    [_asyncRemoteSocket readDataWithTimeout:-1  tag:RemoteWirteTag];
}


#pragma mark- 获取本地状态  本地读写指令
-(void)getLocalStatus{
    
  //  _deviceMac =@"7c:dd:90:9c:05:1A";
    
    NSLog(@"本地读写指令");
    if (!_asyncLocalSocket) {
        
        NSLog(@"创建_asyncLocalSocket，本地读写");
        
        
        [self connectLocalTCPSocket];
        
        
    }
    
    
    
    TDO *tdo = [[TDO alloc] init];
    
    
    NSData *WriteQuerydData= [tdo WriteQuerySwitchData:0 andRemoteMac: _deviceMac  andLocalMac:@"06:26:d5:5a:0a:76" andSerial:2];
    
    [_asyncLocalSocket writeData:WriteQuerydData withTimeout:-1 tag:LocalWirteTag];
    
    [_asyncLocalSocket readDataWithTimeout:-1 tag:LocalWirteTag];
    
    
}



#pragma mark- 本地---开
-(void)LocalSocketON{
    
  //  _deviceMac =@"7c:dd:90:9c:05:1A";

if (!_asyncLocalSocket) {
    
    NSLog(@"创建_RemotePServer，内网 开");
    [self connectRemoteTCPSocket];
    
}

TDO *tdo = [[TDO alloc] init];


NSData *data1= [tdo SetGPIOData:1 andStatus:0 andRemoteMac: _deviceMac andLocalMac:@"06:26:d5:5a:0a:76" andSerial:1];


[_asyncLocalSocket writeData:data1 withTimeout:-1 tag:LocalONTag];



[_asyncLocalSocket readDataWithTimeout:-1 tag:LocalONTag];


}



#pragma mark- 本地---关
-(void)LocalSocketOFF{
    

//    _deviceMac =@"7c:dd:90:9c:05:1A";
    if (!_asyncLocalSocket) {
        
        NSLog(@"创建_RemotePServer,内网关");
        [self connectLocalTCPSocket];
        
    }
    
    
    NSLog(@"内网 ：关");
    
    TDO *tdo = [[TDO alloc] init];
    
    NSData *data2= [tdo SetGPIOData:0 andStatus:0 andRemoteMac: _deviceMac andLocalMac:@"06:26:d5:5a:0a:76" andSerial:2];
    
    
    [_asyncLocalSocket writeData:data2 withTimeout:-1 tag:LocalOffTag];
    
    
    
    [_asyncLocalSocket readDataWithTimeout:-1 tag:LocalOffTag];
    
}



#pragma mark- 远程---开
-(void)RemoteON{
    
   // _deviceMac =@"7c:dd:90:9c:05:1A";

    if (!_asyncRemoteSocket) {
        
        NSLog(@"创建_RemotePServer,外网开");
        
        [self connectRemoteTCPSocket];
        
    }
    
    
    
    
    TDO *tdo = [[TDO alloc] init];
    
    
    NSData *data1= [tdo SetGPIOData:1 andStatus:1 andRemoteMac: _deviceMac andLocalMac:@"06:26:d5:5a:0a:76" andSerial:1];
    
    
    [_asyncRemoteSocket writeData:data1 withTimeout:10 tag:RemoteONTag];
    
    
    
    [_asyncRemoteSocket readDataWithTimeout:10 tag:RemoteONTag];
    
    


}


#pragma mark- 远程---关
-(void)RemoteOFF{
   // _deviceMac =@"7c:dd:90:9c:05:1A";
 
    if (!_asyncRemoteSocket) {
        
        NSLog(@"创建_RemotePServer,外网关");
        
     [self connectRemoteTCPSocket];        
    }
    
    
    
    
    TDO *tdo = [[TDO alloc] init];
    
    
    NSData *data1= [tdo SetGPIOData:0 andStatus:1 andRemoteMac: _deviceMac andLocalMac:@"06:26:d5:5a:0a:76" andSerial:1];
    
    
    [_asyncRemoteSocket writeData:data1 withTimeout:-1 tag:RemoteONTag];
    
    
    
    [_asyncRemoteSocket readDataWithTimeout:-1 tag:RemoteONTag];
    
    
    
    
}







#pragma mark- 远程连接
-(void)connectRemoteTCPSocket{
    
    if (!_asyncRemoteSocket) {
        
        
        _asyncRemoteSocket =       [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    
    
    //绑定端口
    
    
    NSString *host = @"52.28.78.96";
    int port = 9955;
    
    NSError *error = nil;
    [_asyncRemoteSocket connectToHost:host onPort:port error:&error];
    if (error) {
        NSLog(@"有错误吗----%@",error);
    }
    
    
}






#pragma mark- 建立基于TCP的Socket连接 本地连接
-(void)connectLocalTCPSocket{

    if (!_asyncLocalSocket)
    {

        NSLog(@"创建本地连接");
        _asyncLocalSocket =       [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }


    //绑定端口

    NSString *host =  _socketMacHost;

    int port = 9957;

    NSError *error = nil;

   // [_asyncLocalSocket disconnect];

    [_asyncLocalSocket connectToHost:host onPort:port error:&error];
    if (error) {
        NSLog(@"  有错误吗----%@",error);
    }



}


#pragma mark- 建立基于UDP的Socket连接
-(void)connectUDPSocket{
    //初始化udp

    if (!_asyncUdpSocket) {
        NSLog(@"执行建立基于UDP的Socket连接");
         _asyncUdpSocket =       [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }

    //绑定端口
    NSError *error = nil;


    [_asyncUdpSocket enableBroadcast:YES error:&error];

    //开始接收数据
    [_asyncUdpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"UDP开始接收数据失败..%@",error);
    }
    else{

        NSLog(@"UDP开始接收数据成功..%@",error);
    }

}


#pragma mark- 本地find请求
-(void)LocalFind{
    
    NSLog(@"发现设备");
    
    [self connectUDPSocket];
    
    
    
    TDO *tdo = [[TDO alloc] init];
    
    
    NSData * data=  [tdo FindSwitch:@"06:26:d5:5a:0a:76" andRemoteMac:@"7c:dd:90:9c:04:8d" andStatus:0 andSerial:1];
    //nsdata
    //发送
    
    // ip 地址  TCP 的端口号
    [_asyncUdpSocket sendData:data
     
                       toHost:@"255.255.255.255"
                         port:9957
                  withTimeout:1.0
     
                          tag:0];
    
    NSError *err = nil;
    
    [_asyncUdpSocket enableBroadcast:YES error:&err];
    
    [_asyncUdpSocket beginReceiving:&err];
    
    
    
    
}

#pragma mark - GCDAsyncUdpsocket Delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext

{

    

    if (self.ENUM_foType==ENUM_InfoTypWithoutNetwork) {
        

        
        //2.设置标志位为本地
        self.ENUM_foType=ENUM_InfoTyLocal;
        
        

        //4.回调
        if (data.length==96) {
            
            
         //   NSLog(@"内网UDP回调指令的长度-----%lu",(unsigned long)data.length);
            
            //3.取得发送发的ip和端口
            NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
          //  uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
            
           // NSLog(@"%@",ip);
            
            
            _socketMacHost=ip;
            
            
            
            TDO *tdo = [[TDO alloc] init];
            NSDictionary *findDic = [[NSDictionary alloc] initWithDictionary:[tdo SimpleEquipmentData:data]];
            
            
            
        //    _IsSwitchButtoStatus=[[findDic objectForKey:@"Open"] intValue];
            
            _deviceMac=[findDic objectForKey:@"Mac"];
       
            //4.创建本地TCP连接
             [self connectLocalTCPSocket];
            
         

    }
    

    

        //快关 状态 mac地址

    }

    NSError *err = nil;
    
    [_asyncUdpSocket enableBroadcast:YES error:&err];
    
    [_asyncUdpSocket beginReceiving:&err];
  
    
    
}




#pragma mark - GCDAsyncSocket Delegate
//
////Socket开始
- (void)socket:(GCDAsyncSocket*)sock didReadData:(NSData*)data withTag:(long)tag {
// 1.发送find 指令 获取快关状态
// 2.这里是回调，判断指令 ，回调长度
// 3.把状态修改 开1     关0

    

 //   NSLog(@"回调指令的tag-----%ld",tag);
  //  NSLog(@"回调指令的长度-----%lu",(unsigned long)data.length);


    if(data.length==956){
    //本地 读写

        TDO *tdo = [[TDO alloc] init];
        NSDictionary *QueryDic = [[NSDictionary alloc] initWithDictionary:[tdo AllEquipmentData:data]];


        _IsSwitchButtoStatus=[[QueryDic objectForKey:@"Open"] intValue];
        NSDictionary *timeDict=[QueryDic objectForKey:@"Time"];
        
            if (_getStripStatusBlock) {
                
                   NSLog(@"执行本地Block");
              _getStripStatusBlock(_IsSwitchButtoStatus,ENUM_InfoTyLocal , timeDict);
            }

    }
else  if(data.length==996){


        TDO *tdo = [[TDO alloc] init];
        NSDictionary *QueryDic = [[NSDictionary alloc] initWithDictionary:[tdo AllEquipmentData:data]];


        self.ENUM_foType=ENUM_InfoTyRemote;

        _IsSwitchButtoStatus=[[QueryDic objectForKey:@"Open"] intValue];

        NSDictionary *timeDict=[QueryDic objectForKey:@"Time"];
        
        
    //block
    if (_getStripStatusBlock) {
        
           NSLog(@"执行远程Block");
        
        _getStripStatusBlock(_IsSwitchButtoStatus,ENUM_InfoTyRemote , timeDict);
        
    }
    
    


    }
        [sock readDataWithTimeout:-1 tag:tag];//持续接收服务端放回的数据


}




/**
 *  连接TCP成功时调用
 */
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
  //  NSLog(@"连接成功");
    NSLog(@"--------成功连接到----%@:-----%d",host,port);
       //1.开关设为可交互的
     // _switch111.enabled=YES;

    if (port==RemotePort) {

         //1.登录
            [self denglu];
        
           self.ENUM_foType=ENUM_InfoTyRemote;
        
        //2.远程读写请求
           [self getRemoteStatus];

  _RemoteWriteQuerytimer =  [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(getRemoteStatus) userInfo:nil repeats:YES];
        
   
    }
    else{


        
        
     self.ENUM_foType=ENUM_InfoTyLocal;
        
        
        //2.远程读写请求
        [self getLocalStatus];

    _LocalWriteQuerytimer =  [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getLocalStatus) userInfo:nil repeats:YES];

    }


}


// 如果连接对象关闭了 这里会调用
- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err {
    

    
      NSLog(@"断开连接----%ld",(long)self.ENUM_foType);
    
    
        if (self.ENUM_foType==ENUM_InfoTyLocal) {
                [_LocalWriteQuerytimer invalidate];
                _LocalWriteQuerytimer = nil;
        }
        else if(self.ENUM_foType==ENUM_InfoTyRemote){
    
                [_RemoteWriteQuerytimer invalidate];
                _RemoteWriteQuerytimer = nil;
    
        }
        self.ENUM_foType=ENUM_InfoTypWithoutNetwork;
    
    
    
    //block
    if (_getStripStatusBlock) {
           NSLog(@"执行离线Block");
        _getStripStatusBlock(_IsSwitchButtoStatus,ENUM_InfoTypWithoutNetwork , nil);
        
    }
    

    
              
}

//当数据发送成功的话也会回调GCDAsyncSocketDelegate里面的方法：这个的话就可以选择性重发数据

- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag {
    
    NSLog(@"---我是发送数据的 tag---%ld",tag);
    
}


#pragma mark- 发送登录指令
-(void)denglu{
    
    
    NSLog(@"登录");
    
    
    
    NSData *findData = [self hexToBytes:@"00000000760a5ad52606010000000000000000006c5c5c6c5c6c5c6c000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"];
    
    NSLog(@"---登录%@",findData);
    [_asyncRemoteSocket writeData:findData withTimeout:-1 tag:100];
    
    [_asyncRemoteSocket readDataWithTimeout:-1 tag:100];
    
    
    
    
}


//NSString ->NSData
-(NSData*) hexToBytes:(NSString *)str{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}


@end
