//
//  ViewController.m
//  广播
//
//  Created by Summer on 16/5/4.
//  Copyright © 2016年 iSmartAlarm. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "TDO.h"
#import "smartStripSocket.h"

#import <SystemConfiguration/CaptiveNetwork.h>

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
    


////dsasad
    
} ENUM_foType;

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
/* 丢了一个文件  */
@interface ViewController ()<smartStripSocketDelegate>





@property(nonatomic,strong) smartStripSocket *smartSSocket;
@property(nonatomic,assign)NSInteger ENUM_foType;
@property(nonatomic,getter=isSwitchButtoON)BOOL  IsSwitchButtoStatus;

@property(nonatomic,strong)UITextField   *wifiName;

@property(nonatomic,strong)UITextField  *wifimima;


@property(nonatomic,strong)UITextField  *deviceMac;


@property(nonatomic,strong)UISwitch *switch111;

@property(nonatomic,strong) UILabel *statuesLabel;



///cvcvcv






@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    
         smartStripSocket *smartSSocket=[[smartStripSocket alloc]init];
                smartSSocket.delegate=self;
    
            self.smartSSocket=smartSSocket;
    
    
    
    
    
    UITextField *wifiName=[[UITextField alloc]initWithFrame:CGRectMake(30, 44+30, 200, 50)];
    self.wifiName=wifiName;
    wifiName.text=[self getCurrentWifiName];
    wifiName.backgroundColor=[UIColor clearColor];
    [self.view addSubview:wifiName];
    
    UITextField *wifimima=[[UITextField alloc]initWithFrame:CGRectMake(30, 44+30+50+20, 200, 50)];
    
     wifimima.placeholder=@"wifi 密码";
     wifimima.text=   @"22222222";
     self.wifimima=wifimima;
    wifimima.backgroundColor=[UIColor clearColor];
    [self.view addSubview:wifimima];
    
    
    
    UIButton *btn1=[[UIButton alloc]init];
    [btn1 setTitle:@"setNet" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn1.frame=CGRectMake(250, 100, 60, 60);
    [btn1 addTarget:self action:@selector(set_Name) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
 
    
         UILabel *statuesLabel=[[UILabel alloc]init];
        statuesLabel.backgroundColor=[UIColor clearColor];
         statuesLabel.text=@"离线";
        statuesLabel.frame=CGRectMake(240, 320, 100, 50);
        [self.view addSubview:statuesLabel];
        self.statuesLabel=statuesLabel;
    
    
    
    
    
    UITextField *deviceMac=[[UITextField alloc]initWithFrame:CGRectMake(30, 320, 200, 50)];
    
    deviceMac.placeholder=@"mac 地址";
    deviceMac.text=@"7c:dd:90:9c:05:1A";
    self.deviceMac=deviceMac;
    deviceMac.backgroundColor=[UIColor clearColor];
    [self.view addSubview:deviceMac];
    
    
   // [self addSwitch111];
  
 //   [self.smartSSocket  ConnectToHostWithMac:deviceMac.text];
    
    //远程连接
  //  [self.smartSSocket connectRemoteTCPSocket];
    


  //  [self.smartSSocket setTimeWithENUM_foType:self.ENUM_foType];
    
    
    
    [self.smartSSocket ConnectToHostWithMac:deviceMac.text ];
    
    
    self.smartSSocket.getStripStatusBlock=^(BOOL isSwitchButtoStatus, NSInteger ENUM_foType, NSDictionary *Time) {
        
        NSLog(@"获取---定时器列表-----%@",Time);
        NSLog(@"获取---isSwitchButtoStatus-----%d",isSwitchButtoStatus);
        NSLog(@"获取---ENUM_foType-------------%d",ENUM_foType);
        
        
    };

    
    
    
    
    
}
//设网
-(void)set_Name
{
    NSLog(@"%@---%@",_wifiName.text,_wifimima.text);
    [self.smartSSocket  setNetwithSSID:_wifiName.text andPassWord:_wifimima.text];

}








#pragma mark- 创建开关
-(void)addSwitch111
{
    
    
    _switch111.enabled=YES;

    if (!_switch111) {
        
        
        _switch111 = [[UISwitch alloc] initWithFrame:CGRectMake(150, 400, 0, 0)];
        
        [_switch111 addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_switch111];
    }
    
    
  
    if ( _IsSwitchButtoStatus) {
        
        [_switch111 setOn:YES];
    }else{
        [_switch111 setOn:NO];
        
    }
    

    
}




#pragma mark- 开关的点击事件

-(void)switchAction:( UISwitch *)switchButton
{

  BOOL isButtonOn = [switchButton isOn];
  
    [self.smartSSocket ONffWithIsButtonOn:isButtonOn];

}


//-(void)getStripStatusFormsock:(smartStripSocket *)sock didisSwitchButtoStatus:(BOOL)isSwitchButtoStatus AndENUM_foType:(NSInteger)ENUM_foType AndTime:(NSDictionary *)Time{
//
//    if (ENUM_foType==ENUM_InfoTyRemote) {
//        
//        
//        //1.开关
//        _statuesLabel.text=[NSString stringWithFormat:@"s:%d---远程",isSwitchButtoStatus];
//        
//        _IsSwitchButtoStatus=isSwitchButtoStatus;
//        
//        
//    
//        //3.创建开关
//        [self addSwitch111];
//        
//        
//        
//        
//
//           NSLog(@"我是远程代理方法---定时器列表-----%@",Time);
//        NSLog(@"我是远程代理方法---isSwitchButtoStatus-----%d",isSwitchButtoStatus);
//        NSLog(@"我是远程代理方法---ENUM_foType-------------%d",ENUM_foType);
//    }
//    else if(ENUM_foType==ENUM_InfoTyLocal){
//    
//    
//        //1.开关
//        _statuesLabel.text=[NSString stringWithFormat:@"s:%d---本地",isSwitchButtoStatus];
//        
//        _IsSwitchButtoStatus=isSwitchButtoStatus;
//        
//
//        //3.创建开关
//        [self addSwitch111];
//        
//
//        
//        
//         NSLog(@"我是本地代理方法---定时器列表-----%@",Time);
//        
//        NSLog(@"我是本地代理方法---isSwitchButtoStatus-----%d",isSwitchButtoStatus);
//        NSLog(@"我是本地代理方法---ENUM_foType-------------%d",ENUM_foType);
//    
//    
//    }
//    else{
//        NSLog(@"我是离线代理方法---定时器列表-----%@",Time);
//        NSLog(@"我是离线代理方法---isSwitchButtoStatus-----%d",isSwitchButtoStatus);
//        NSLog(@"我是离线代理方法---ENUM_foType-------------%d",ENUM_foType);
//    
//                  _statuesLabel.text=[NSString stringWithFormat:@"离线"];
//        
//                   _switch111.enabled=NO;
//        
//                self.ENUM_foType=ENUM_InfoTypWithoutNetwork;
//    
//        [self.smartSSocket ConnectToHostWithMac:_deviceMac.text];
//    
//    
//    }
//
//
//}





/**
 *  获取wifiName
 *
 *  @return 获取wifiName
 */
- (NSString *)getCurrentWifiName{
    NSString *wifiName = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    NSLog(@"wifiName:%@", wifiName);
    return wifiName;
}


//键盘退出
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (![_wifiName isExclusiveTouch]) {
        [_wifiName resignFirstResponder];
    }
    
    if (![_wifimima isExclusiveTouch]) {
        [_wifimima resignFirstResponder];
    }
    
    if (![_deviceMac isExclusiveTouch]) {
        [_deviceMac resignFirstResponder];
    }
    
    
    
}
@end
