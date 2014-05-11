//
//  LampViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "LampViewController.h"
#import "MyButton.h"
#import "GCDAsyncSocket.h"

@interface LampViewController ()
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
    BOOL isStudyedFlagTURNON;
    BOOL isStudyedFlagTURNOFF;
    
    UIActivityIndicatorView *_actIdctV;
    
    
    NSMutableData *recMultData ;
    UInt32 recvDataCount;
//    NSMutableArray *mArry;
}
@end

@implementation LampViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        recMultData = [[NSMutableData alloc] init];
        
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
        char makeFlag = 0;
        if (fileList.count > 0) {
            for (int i = 0; i < fileList.count; i++) {
                tmpString = (NSString*)[fileList objectAtIndex:i];
                if ([tmpString isEqualToString:@"lampData.dat"]) {
                    makeFlag = 0;
                    
                    NSString *fileName = [[NSString alloc] init];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    fileName = [documentsDirectory stringByAppendingPathComponent:tmpString];
                    NSMutableArray *mutArry = [[NSMutableArray alloc] initWithContentsOfFile:fileName];
                    if (mutArry.count > 1) {
                        isStudyedFlagTURNON = YES;
                    }else {
                        isStudyedFlagTURNON = NO;
                    }
                    if (mutArry.count > 2) {
                        isStudyedFlagTURNOFF = YES;
                    } else {
                        isStudyedFlagTURNOFF = NO;
                    }
                    NSLog(@"发现数据文件");
                }
                else{//创建数据文件
                    makeFlag = 1;
                }
            }
            if (makeFlag) {
                makeFlag = 0;
                [self makeDataFile];
            }
        } else {
            [self makeDataFile];
        }
        
        
        
        
    }
    return self;
}

- (void)makeDataFile
{
    

    
    
    /////////
    
    
    Byte tmpDat[2] = {01,02};
    NSData *PressD = [[NSData alloc] initWithBytes:tmpDat length:2];
    
   
    
    
    NSString *fileName = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    fileName = [documentsDirectory stringByAppendingPathComponent:@"lampData.dat"];
    
    NSMutableDictionary *Dat = [[NSMutableDictionary alloc] init];
    [Dat setObject:PressD forKey:@"data"];
    
    NSMutableArray *mArry = [[NSMutableArray alloc] initWithObjects:Dat, nil];
    [mArry writeToFile:fileName atomically:YES];
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
    
    UIImage *image = [UIImage imageNamed:@"LampView320x568.png"];
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
    
    //打开按钮
    MyButton *UpBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    UpBtn.frame = CGRectMake((r.size.width - 65*3)/4, 300, 60, 60);
    UpBtn.tag = 10001;
    UpBtn.adjustsImageWhenHighlighted = YES;
    [UpBtn setImage:[UIImage imageNamed:@"TurnONImage.png.png"] forState:UIControlStateNormal];
    [UpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:UpBtn];
    
    
    //关闭按钮
    MyButton *DownBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    DownBtn.frame = CGRectMake((r.size.width - 65*3)/4*3 + 65*2, 300, 60, 60);
    DownBtn.tag = 10002;
    DownBtn.adjustsImageWhenHighlighted = YES;
    [DownBtn setImage:[UIImage imageNamed:@"TurnOFFImage.png"] forState:UIControlStateNormal];
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
    OKBtn.frame = CGRectMake(250,390,40,40);
    OKBtn.tag = 10010;
    OKBtn.backgroundColor = [UIColor redColor];
    [OKBtn setTintColor:[UIColor blueColor]];
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OKBtn];
    
    //取消按钮
    UIButton *recBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    recBtn.frame = CGRectMake(250,460,40,40);
    recBtn.tag = 10011;
    recBtn.backgroundColor = [UIColor blueColor];
    [recBtn setTintColor:[UIColor redColor]];
    [recBtn setTitle:@"取消" forState:UIControlStateNormal];
    [recBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recBtn];
    
    
    _actIdctV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //    [actIdctV setFrame:[CGRectMake(r.origin.x/2, r.origin.y/2, 100, 100)]];
    _actIdctV.frame = CGRectMake(r.size.width/2, r.size.height/2, 0, 0);
    [self.view addSubview:_actIdctV];
    
    
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
        
    }
    
    //开灯
    else if (btn.tag == 10001) {
        
        if (isStudyedFlagTURNON) {
            //connect to host
            if ([socket isDisconnected]) {
                NSError *error;
                if (![socket connectToHost:@"192.168.1.1" onPort:2001 withTimeout:5 error:&error]) {
                    NSLog(@"connect error");
                    return;
                }
            }
            //send msg
            
            NSString *fileName = [[NSString alloc] init];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            fileName = [documentsDirectory stringByAppendingPathComponent:@"lampData.dat"];
            NSMutableArray *mutArry = [[NSMutableArray alloc] initWithContentsOfFile:fileName];
            
            NSMutableDictionary * dic = [mutArry objectAtIndex:1];
            NSMutableData *tmpDat = [dic objectForKey:@"data"];
            
            [socket writeData:tmpDat withTimeout:5 tag:0];
            [socket readDataWithTimeout:-1.0 tag:0];
        } else {
            [_actIdctV startAnimating];
            [socket readDataWithTimeout:-1.0 tag:1];
        }
        
        
    }
    else if (btn.tag == 10002) {
        if (isStudyedFlagTURNOFF) {
            //connect to host
            if ([socket isDisconnected]) {
                NSError *error;
                if (![socket connectToHost:@"192.168.1.1" onPort:2001 withTimeout:5 error:&error]) {
                    NSLog(@"connect error");
                    return;
                }
            }
            //send msg
            NSMutableArray *mutArry = [[NSMutableArray alloc] init];
            mutArry = [self readDataFile];
            
            NSMutableDictionary * dic = [mutArry objectAtIndex:2];
            NSMutableData *tmpDat = [dic objectForKey:@"data"];
            
            [socket writeData:tmpDat withTimeout:5 tag:0];
//            [socket readDataWithTimeout:-1.0 tag:0];
        } else {
            [_actIdctV startAnimating];
            [socket readDataWithTimeout:-1.0 tag:1];
        }
        
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
    NSLog(@"write data:%d",1);
    
    
}

- (void)socket:(GCDAsyncSocket *)sock didNotWriteDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
    //    NSLog(@"--------write data:%ld  %@",tag,error);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    
    NSData *recData = [[NSData alloc] initWithData:data];
    short recDataLen;
    [recMultData appendData:recData];
    long int len = [recMultData length];
    recvDataCount = (int)len;
    Byte tmpData[recvDataCount];
    
    for (int i = 0; i<recvDataCount; i++) {
        [recMultData getBytes:&tmpData[i] range:NSMakeRange(i, 1)];
        NSLog(@"%hhu",tmpData[i]);
    }
    if (tmpData[0] == 0x00) {
        if (recvDataCount >= 3) {
            recDataLen = (tmpData[1] << 8) | (tmpData[2]&0xFF);
            
            if(recvDataCount == recDataLen && (tmpData[recvDataCount - 1] == 0xFF) ) {//如果数据接收完整
                
                //得到数据
                
                //////////////////////
                NSMutableData *DataMultData = [[NSMutableData alloc] initWithData:[recMultData subdataWithRange:NSMakeRange(0, recvDataCount)]];
                
                
                
                NSMutableDictionary *mutDic = [self makeWriteDataWithData:DataMultData];
                NSMutableArray *mutArry = [[NSMutableArray alloc] init];
                mutArry = [self readDataFile];
                [mutArry addObject:mutDic];
                [self writeFileUseMutableArry:mutArry];
                
                NSLog(@"写入文件数据成功！");
                
                isStudyedFlagTURNON = YES;
                isStudyedFlagTURNOFF = YES;
                [_actIdctV stopAnimating];
                [recMultData setLength:0];
                recvDataCount = 0;
              
            }
            else{//如果接收到的数据没有到达接收到数据的长度 并且帧尾不是0xFF继续接收
                [socket readDataWithTimeout:-1.0 tag:1];
            }
        } else { //如果接受的数据不够 继续接收
            [socket readDataWithTimeout:-1.0 tag:1];
        }
        
    } else { //如果枕头不是0x00 抛掉以前接收的数据重新接收
        //clean recMultData;重新接受
        [recMultData setLength:0];
        recvDataCount = 0;
        [socket readDataWithTimeout:-1.0 tag:1];
    }

	
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


- (NSMutableArray *) readDataFile
{
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
            if ([tmpString isEqualToString:@"lampData.dat"]) {
                
                NSString *fileName = [[NSString alloc] init];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                fileName = [documentsDirectory stringByAppendingPathComponent:tmpString];
                
                NSMutableArray* mutArry = [[NSMutableArray alloc] initWithContentsOfFile:fileName];
                
                return mutArry;
            }
            
        }
    }else{
        return nil;
    }
    return nil;
}

- (NSMutableDictionary *)makeWriteDataWithData:(NSMutableData*)mutData
{
    NSMutableDictionary *dev = [[NSMutableDictionary alloc] init];
    
    [dev setObject:mutData forKey:@"data"];
    
    return dev;
}

- (void) writeFileUseMutableArry:(NSMutableArray *)mutArry
{
    NSString *fileName = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    fileName = [documentsDirectory stringByAppendingPathComponent:@"lampData.dat"];
    
    
    [mutArry writeToFile:fileName atomically:YES];
}




@end