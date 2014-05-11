//
//  RemoteViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "RemoteViewController.h"
#import "MyButton.h"
#import "GCDAsyncSocket.h"

@interface RemoteViewController ()
{
    UIButton *selecDevBtn;
    UIPickerView  *devPickerView;
    GCDAsyncSocket *socket;
    NSMutableArray *allDevArry;
    NSMutableArray *devArry;
    Byte devNum;
    NSMutableDictionary *devDic;
    NSString *selectDevName;
    Byte selectDevID;
    NSInteger selecRow;
}

@end

@implementation RemoteViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //TODO:load data.ini file
        //检查是否有配置文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //在这里获取应用程序Documents文件夹里的文件及文件夹列表
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSError *error = nil;
        NSArray *fileList = [[NSArray alloc] init];
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
        NSString *tmpString = [[NSString alloc] init];
        if (fileList.count > 0) {
            for (int i = 0; i < fileList.count; i++) {
                tmpString = (NSString*)[fileList objectAtIndex:i];
                if ([tmpString isEqualToString:@"data.ini"]) {
                    
                    NSString *fileName = [[NSString alloc] init];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    fileName = [documentsDirectory stringByAppendingPathComponent:tmpString];
                    
                    allDevArry = [[NSMutableArray alloc] initWithContentsOfFile:fileName];
                  
                }
                
            }
        }
        
        //将同一type的dev加载到devArry中
        devNum = 0;
        devArry = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i<allDevArry.count; i++) {
            NSMutableDictionary * tmpMutDic = [allDevArry objectAtIndex:i];
            Byte tmpType = [[tmpMutDic objectForKey:@"type"] unsignedCharValue];
            if (tmpType == 0x01) {
                [devArry addObject:tmpMutDic];
                devNum++;
            }
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTitle:@"电视机控制"];
    
    //连接socket
    //create socket
    if (!socket) {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self  delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    //connect to host
    if ([socket isDisconnected]) {
        NSError *error;
        if (![socket connectToHost:@"192.168.1.1" onPort:2001 withTimeout:5 error:&error]) {
            NSLog(@"connect error");
        }
    }
    
    
    
    CGRect r = [ UIScreen mainScreen ].applicationFrame;//app尺寸，去掉状态栏
    //     CGRect r = [ UIScreen mainScreen ].bounds;//app尺寸，去掉状态栏
    NSLog(@"r.width:%f,r.height:%f",r.size.width,r.size.height);
    
    UIImage *image = [UIImage imageNamed:@"RemoteBackgroundImage.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:r];
    imageView.backgroundColor = [UIColor purpleColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    
    //选择设备按钮
    selecDevBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selecDevBtn.frame = CGRectMake(20,80,220,40);
    selecDevBtn.tag = 11000;
    selecDevBtn.backgroundColor = [UIColor purpleColor];
    [selecDevBtn setTintColor:[UIColor redColor]];
    [selecDevBtn setTitle:@"请选择设备号" forState:UIControlStateNormal];
    [selecDevBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];    
    [selecDevBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [selecDevBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selecDevBtn];
    
    //确认选择设备按钮
    UIButton *OKselecDevBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    OKselecDevBtn.frame = CGRectMake(250,80,50,40);
    OKselecDevBtn.tag = 11001;
    OKselecDevBtn.backgroundColor = [UIColor greenColor];
    [OKselecDevBtn setTintColor:[UIColor redColor]];
    [OKselecDevBtn setTitle:@"确认" forState:UIControlStateNormal];
    [OKselecDevBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [OKselecDevBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OKselecDevBtn];
    
    
    NSArray *arry = [[NSArray alloc] initWithObjects:@"TVAVBtnImage.png",@"MODEBtnImage.png",@"MUTEBtnImage.png",@"ONOFFBtnImage.png",nil];
    for (int i = 0; i<4; i++) {
        MyButton *UpBtn = [MyButton buttonWithType:UIButtonTypeCustom];
        UpBtn.frame = CGRectMake(10 + i*80, 140, 60, 40);
        UpBtn.tag = 10001 + i;
        UpBtn.adjustsImageWhenHighlighted = YES;
//        [UpBtn setBackgroundImage:[UIImage imageNamed:@"TurnONImage1.png"] forState:UIControlStateNormal];
        [UpBtn setImage:[UIImage imageNamed:[arry objectAtIndex:i]] forState:UIControlStateNormal];
//        [UpBtn setTitle:@"上升" forState:UIControlStateSelected];
        [UpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:UpBtn];
    }
    
    NSArray *arryNum = [[NSArray alloc] initWithObjects:@"1BtnImage.png",@"2BtnImage.png",@"3BtnImage.png",@"4BtnImage.png",@"5BtnImage.png",@"6BtnImage.png",@"7BtnImage.png",@"8BtnImage.png",@"9BtnImage.png",@"USER1BtnImage.png",@"0BtnImage.png",@"USER2BtnImage.png",nil];
    for (int i = 0; i<4; i++) {//行
        for (int j = 0; j<3; j++) {//列
            MyButton *UpBtn = [MyButton buttonWithType:UIButtonTypeCustom];
            UpBtn.frame = CGRectMake(20 + j*90, 190 + i*40, 90, 40);
            UpBtn.tag = 10005 + i*3+j;
            UpBtn.adjustsImageWhenHighlighted = YES;
            //        [UpBtn setBackgroundImage:[UIImage imageNamed:@"TurnONImage1.png"] forState:UIControlStateNormal];
            [UpBtn setImage:[UIImage imageNamed:[arryNum objectAtIndex:i*3+j]] forState:UIControlStateNormal];
            //        [UpBtn setTitle:@"上升" forState:UIControlStateSelected];
            [UpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:UpBtn];

        }
    }
    
    NSArray *arryCha = [[NSArray alloc] initWithObjects:@"PLUSBtnImage.png",@"UPBtnImage.png",@"SUBBtnImage.png",@"DOWNBtn.png",nil];
    for (int i = 0; i<2; i++) {
        for (int j = 0; j<2; j++) {
            MyButton *TempBtn = [MyButton buttonWithType:UIButtonTypeCustom];
            TempBtn.frame = CGRectMake(45 + j*165, 358 + i*88, 65, 65);
            TempBtn.tag = 10020 + i*2+j;
            TempBtn.adjustsImageWhenHighlighted = YES;
            //        [UpBtn setBackgroundImage:[UIImage imageNamed:@"TurnONImage1.png"] forState:UIControlStateNormal];
            [TempBtn setImage:[UIImage imageNamed:[arryCha objectAtIndex:i*2+j]] forState:UIControlStateNormal];
            //        [UpBtn setTitle:@"上升" forState:UIControlStateSelected];
            [TempBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:TempBtn];
        }
    }
    
    MyButton *TempBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    TempBtn.frame = CGRectMake(135 , 415, 50, 45);
    TempBtn.tag = 10030;
    TempBtn.adjustsImageWhenHighlighted = YES;
    //        [UpBtn setBackgroundImage:[UIImage imageNamed:@"TurnONImage1.png"] forState:UIControlStateNormal];
    [TempBtn setImage:[UIImage imageNamed:@"BACKBtnImage.png"] forState:UIControlStateNormal];
    //        [UpBtn setTitle:@"上升" forState:UIControlStateSelected];
    [TempBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:TempBtn];
    
}


- (void)btnClick:(UIButton*)sender
{
    UIButton *btn = sender;
    if (btn.tag == 11000) {
        NSLog(@"ssss");
        
        if (devPickerView == nil) {
            devPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 460, 320, 460)];
            devPickerView.delegate = self;
            devPickerView.dataSource = self;
            devPickerView.showsSelectionIndicator = YES;
            devPickerView.backgroundColor = [UIColor whiteColor];
            devPickerView.alpha = 1.0f;
            [self.view addSubview:devPickerView];
            //            [pickerView release];
        }
        [UIView beginAnimations: @"Animation" context:nil];
        [UIView setAnimationDuration:0.3];
        devPickerView.frame = CGRectMake(0, 380, 320, 552);
        [UIView commitAnimations];
        
    } else if (btn.tag == 10004) {
       
    } else if (btn.tag == 10005) {
        
    } else if (btn.tag == 110000) {
        
        NSLog(@"OK....");
        
    } else if (btn.tag == 11001) {
        
        [UIView beginAnimations: @"Animation" context:nil];
        [UIView setAnimationDuration:0.3];
        devPickerView.frame = CGRectMake(0, 566, 320, 548);
        [UIView commitAnimations];
        
        [self pickerView:devPickerView didSelectRow:selecRow inComponent:0];
        
    } else if (btn.tag == 10001) {
        NSLog(@"UP....");
        //connect to host
        if ([socket isDisconnected]) {
            NSLog(@"socket disconnectted");
            NSError *error;
            if (![socket connectToHost:@"192.168.1.1" onPort:2001 withTimeout:5 error:&error]) {
                NSLog(@"connect error");
                return;
            }
        }
        
        //send msg
        Byte dat[8] = {0xab,0xcd,0xef,0x12,0x34,0x56,0x78,0x90};
        NSData *sendData = [[NSData alloc] initWithBytes:dat length:8];
        [socket writeData:sendData withTimeout:5 tag:0];
        [socket readDataWithTimeout:-1.0 tag:0];
        NSLog(@"write data:%@",sendData);
    } else if (btn.tag == 10002) {
        NSLog(@"STOP....");
        Byte openTimeData[5] = {0x01,0x02,0x00,0x0F,0x33};
        
        [self sendDataWithID:selectDevID withCMD:0x03 withData:openTimeData withDataLen:5 withTag:btn.tag];
        
    } else if (btn.tag == 10003) {
        NSLog(@"DOWN....");
        [self sendDataWithID:selectDevID withCMD:0x01 withData:NULL withDataLen:0 withTag:btn.tag];
        
    } else if (btn.tag == 10010) {
        
        
    } else if(btn.tag == 10011) {
        [socket readDataWithTimeout:10.0 tag:0];
    } else {
        NSLog(@"NOthing....");
    }
}

- (void)sendDataWithID:(Byte)devID withCMD:(Byte)cmdData withData:(Byte*)otherData withDataLen:(short)dataLen withTag:(long)otag{
    //connect to host
    if ([socket isDisconnected]) {
        NSLog(@"socket disconnectted");
        NSError *error;
        if (![socket connectToHost:@"192.168.1.1" onPort:2001 withTimeout:10 error:&error]) {
            NSLog(@"connect error");
            return;
        }
    }
    //send msg
    dataLen += 7;
    
    Byte tmpDataH = (dataLen >> 8) & 0xFF;
    Byte tmpDataL = dataLen & 0xFF;
    Byte *data;
    Byte dat[6] = {0x00,tmpDataH,tmpDataL,0x01,devID,cmdData};
    
    data = (Byte *)malloc(dataLen);
    if (!data) {
        return;
    }
    memset(data, 0, dataLen);
    memcpy(data, dat,6);
    if (dataLen -7) {
        memcpy(data+6, otherData, dataLen - 7);
    }
    data[dataLen-1] = 0xFF;
    
    NSData *sendData = [[NSData alloc] initWithBytes:data length:dataLen];
    
    
    [socket writeData:sendData withTimeout:10 tag:otag];
    [socket readDataWithTimeout:-1.0 tag:otag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [socket disconnect];
}


#pragma mark socket delegate
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	// You could add checks here
    NSLog(@"write data:%ld",tag);
    
    
}

- (void)socket:(GCDAsyncSocket *)sock didNotWriteDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
    //    NSLog(@"--------write data:%ld  %@",tag,error);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
	
	NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSLog(@"HTTP Response:\n%@", httpResponse);
	
}


- (void)socket:(GCDAsyncSocket *)sock didNotReceiveData:(NSData *)data withTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"%@",error);
}



#pragma mark pickerView delegate

//返回pickerview的组件数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

//返回每个组件上的行数
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
    return devNum;
    
}

//设置每行显示的内容
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[devArry objectAtIndex:row] objectForKey:@"name"];
}



//当你选中pickerview的某行时会调用该函数。

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSLog(@"You select row %ld",(long)row);
	selectDevName = [[NSString alloc] init];
    selectDevName = [[devArry objectAtIndex:row] objectForKey:@"name"];
    selectDevID = [[[devArry objectAtIndex:row] objectForKey:@"ID"] unsignedCharValue];
    selecDevBtn.titleLabel.text = selectDevName;
    selecRow = row;
}



@end
