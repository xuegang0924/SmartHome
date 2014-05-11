//
//  CurtainViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "CurtainViewController.h"
#import "MyButton.h"


@interface CurtainViewController ()
{
    UIButton *selecDevBtn;
    UIPickerView  *devPickerView;
    UIPickerView  *datePickerView;
    long tag;
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

@implementation CurtainViewController





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
    [self setTitle:@"窗帘控制"];
    
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
    
    UIImage *image = [UIImage imageNamed:@"CurtainView320x568.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:r];
    imageView.backgroundColor = [UIColor purpleColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    
    
    
    //选择设备按钮
    selecDevBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selecDevBtn.frame = CGRectMake(20,80,220,50);
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
    OKselecDevBtn.frame = CGRectMake(250,80,50,50);
    OKselecDevBtn.tag = 11001;
    OKselecDevBtn.backgroundColor = [UIColor greenColor];
    [OKselecDevBtn setTintColor:[UIColor redColor]];
    [OKselecDevBtn setTitle:@"确认" forState:UIControlStateNormal];
    [OKselecDevBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [OKselecDevBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OKselecDevBtn];
    
    //上升按钮
    MyButton *UpBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    UpBtn.frame = CGRectMake((r.size.width - 65*3)/4, 300, 65, 40);
    UpBtn.tag = 10001;
    UpBtn.backgroundColor = [UIColor blackColor];
    UpBtn.adjustsImageWhenHighlighted = YES;
    [UpBtn setBackgroundImage:[UIImage imageNamed:@"UpImage65x40.png"] forState:UIControlStateNormal];
    [UpBtn setImage:[UIImage imageNamed:@"UpImage65x40.png"] forState:UIControlStateNormal];
    [UpBtn setTitle:@"上升" forState:UIControlStateSelected];
    [UpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:UpBtn];
    
    //停止按钮
    MyButton *StopBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    StopBtn.frame = CGRectMake((r.size.width - 65*3)/4*2 +65, 300, 65, 40);
    StopBtn.tag = 10002;
    StopBtn.backgroundColor = [UIColor blackColor];
    StopBtn.adjustsImageWhenHighlighted = YES;
    [StopBtn setBackgroundImage:[UIImage imageNamed:@"StopImage65x40.png"] forState:UIControlStateNormal];
    [StopBtn setImage:[UIImage imageNamed:@"StopImage65x40.png"] forState:UIControlStateNormal];
    [StopBtn setTitle:@"停止" forState:UIControlStateSelected];
    [StopBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:StopBtn];
    
    //下降按钮
    MyButton *DownBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    DownBtn.frame = CGRectMake((r.size.width - 65*3)/4*3 + 65*2, 300, 65, 40);
    DownBtn.tag = 10003;
    DownBtn.backgroundColor = [UIColor blackColor];
    DownBtn.adjustsImageWhenHighlighted = YES;
    [DownBtn setBackgroundImage:[UIImage imageNamed:@"DownImage65x40.png"] forState:UIControlStateNormal];
    [DownBtn setImage:[UIImage imageNamed:@"DownImage65x40.png"] forState:UIControlStateNormal];
    [DownBtn setTitle:@"下降" forState:UIControlStateSelected];
    [DownBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:DownBtn];
    
    
    //开启时间
    UILabel *labSetOpenTime = [[UILabel alloc] initWithFrame:CGRectZero];
    labSetOpenTime.text = @"开启时间";
    labSetOpenTime.numberOfLines = 0;
    labSetOpenTime.frame = CGRectMake(10, 380, 50,60);
    [labSetOpenTime setTextColor:[UIColor yellowColor]];
    [self.view addSubview:labSetOpenTime];
    
    //开启时间按钮
    UIButton *setOpenTimeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    setOpenTimeBtn.frame = CGRectMake(60,390,160,40);
    setOpenTimeBtn.tag = 10004;
    setOpenTimeBtn.backgroundColor = [UIColor whiteColor];
    [setOpenTimeBtn setTintColor:[UIColor blackColor]];
    [setOpenTimeBtn setTitle:@"选择开启时间" forState:UIControlStateNormal];
    [setOpenTimeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setOpenTimeBtn];
    
    //关闭时间
    UILabel *labSetCloseTime = [[UILabel alloc] initWithFrame:CGRectZero];
    labSetCloseTime.text = @"关闭时间";
    labSetCloseTime.numberOfLines = 0;
    labSetCloseTime.frame = CGRectMake(10, 450, 50,60);
    [labSetCloseTime setTextColor:[UIColor yellowColor]];
    [self.view addSubview:labSetCloseTime];
    
    //关闭时间按钮
    UIButton *setTurnOFFTimeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    setTurnOFFTimeBtn.frame = CGRectMake(60,460,160,40);
    setTurnOFFTimeBtn.tag = 10005;
    setTurnOFFTimeBtn.backgroundColor = [UIColor whiteColor];
    [setTurnOFFTimeBtn setTintColor:[UIColor blackColor]];
    [setTurnOFFTimeBtn setTitle:@"选择关闭时间" forState:UIControlStateNormal];
    [setTurnOFFTimeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setTurnOFFTimeBtn];
    
    //确定按钮
    UIButton *OKBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    OKBtn.frame = CGRectMake(250,380,40,40);
    OKBtn.tag = 10010;
    OKBtn.backgroundColor = [UIColor redColor];
    [OKBtn setTintColor:[UIColor blueColor]];
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OKBtn];
    
    //取消按钮
    UIButton *recBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    recBtn.frame = CGRectMake(250,450,40,40);
    recBtn.tag = 10011;
    recBtn.backgroundColor = [UIColor blueColor];
    [recBtn setTintColor:[UIColor redColor]];
    [recBtn setTitle:@"取消" forState:UIControlStateNormal];
    [recBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recBtn];
    

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
        if (datePickerView == nil) {
            datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 460, 320, 460)];
            datePickerView.delegate = self;
            datePickerView.dataSource = self;
            datePickerView.showsSelectionIndicator = YES;
            datePickerView.backgroundColor = [UIColor whiteColor];
            datePickerView.alpha = 1.0f;
            [self.view addSubview:datePickerView];
        }
        [UIView beginAnimations: @"Animation" context:nil];
        [UIView setAnimationDuration:0.3];
        datePickerView.frame = CGRectMake(0, 380, 320, 552);
        [UIView commitAnimations];
    } else if (btn.tag == 10005) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 320, 300)];
//        [self.view addSubview:view];
//        
//        
//        
//        if (datePickerView == nil) {
//            datePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 320, 320, 200)];
//            datePickerView.delegate = self;
//            datePickerView.dataSource = self;
//            datePickerView.showsSelectionIndicator = YES;
//            datePickerView.backgroundColor = [UIColor whiteColor];
//            datePickerView.alpha = 1.0f;
//            [view addSubview:datePickerView];
//            
//
//            //按钮
//            UIButton *OKBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            OKBtn.frame = CGRectMake(5,5,40,40);
//            OKBtn.tag = 110000;
//            OKBtn.backgroundColor = [UIColor redColor];
//            [OKBtn setTintColor:[UIColor blueColor]];
//            [OKBtn setTitle:@"ok" forState:UIControlStateNormal];
//            [OKBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//            [OKBtn setUserInteractionEnabled:YES];
//            [view addSubview:OKBtn];
//        }
//        [UIView beginAnimations: @"Animation" context:nil];
//        [UIView setAnimationDuration:0.3];
//        view.frame = CGRectMake(0, 320, 320, 400);
//        [UIView commitAnimations];
    }
    
    else if (btn.tag == 110000) {
        
        NSLog(@"OK....");
        
    }
    
    else if (btn.tag == 11001) {
        
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
        [socket writeData:sendData withTimeout:5 tag:tag];
        [socket readDataWithTimeout:-1.0 tag:tag];
        NSLog(@"write data:%@",sendData);
        tag++;
    }
    else if (btn.tag == 10002) {
        NSLog(@"STOP....");
        Byte openTimeData[5] = {0x01,0x02,0x00,0x0F,0x33};
        
        [self sendDataWithID:selectDevID withCMD:0x03 withData:openTimeData withDataLen:5 withTag:btn.tag];

    }
    else if (btn.tag == 10003) {
        NSLog(@"DOWN....");
        [self sendDataWithID:selectDevID withCMD:0x01 withData:NULL withDataLen:0 withTag:btn.tag];

    }
    else if (btn.tag == 10010) {
        
        
    }
    else if(btn.tag == 10011)
    {
        [socket readDataWithTimeout:10.0 tag:tag];
    }
    else
    {
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

//自定义pickerview使内容显示在每行的中间，默认显示在每行的左边（(NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component）
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)] ;
//	if (row == 0) {
//		label.text = @"男";
//	}else {
//		label.text = @"女";
//	}
//	
//	[label setTextAlignment:UITextAlignmentCenter];
//    return label;
//}

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
