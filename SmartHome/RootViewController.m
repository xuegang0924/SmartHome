//
//  RootViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "RootViewController.h"
#import "MyButton.h"
#import "SetViewController.h"
#import "CurtainViewController.h"
#import "WebCamViewController.h"
#import "LampViewController.h"
#import "ElecSocketViewController.h"
#import "RemoteViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    
//    UIButton *SetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(10, 50, 200, 50);
//    [btn setTitle:@"Push To svc2" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    [self setTitle:@"SmartHome"];
    CGRect r = [ UIScreen mainScreen ].applicationFrame;//app尺寸，去掉状态栏
    
//    CGRect r = [ UIScreen mainScreen ].applicationFrame;//app尺寸，去掉状态栏
    //     CGRect r = [ UIScreen mainScreen ].bounds;//app尺寸，去掉状态栏
//    NSLog(@"r.width:%f,r.height:%f",r.size.width,r.size.height);
    
    UIImage *backGroundImage = [UIImage imageNamed:@"BackGroundViewImage3.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backGroundImage];
    [imageView setFrame:r];
    imageView.backgroundColor = [UIColor purpleColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    
    
    
    
    //添加设备按钮
    MyButton *SetBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    SetBtn.frame = CGRectMake((r.size.width - 100*2)/3 ,(r.size.height - 100*3)/4 +10, 100, 100);
    SetBtn.tag = 1000;
//    SetBtn.backgroundColor = [UIColor blueColor];
    SetBtn.adjustsImageWhenHighlighted = YES;
    [SetBtn setBackgroundImage:[UIImage imageNamed:@"AddImage150x150.png"] forState:UIControlStateNormal];
    [SetBtn setImage:[UIImage imageNamed:@"AddImage150x150.png"] forState:UIControlStateNormal];
    [SetBtn setTitle:@"添加设备" forState:UIControlStateNormal];
    [SetBtn addTarget:self action:@selector(SetbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SetBtn];
    
    //窗帘控制按钮
    MyButton *CurtainBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    CurtainBtn.frame = CGRectMake((r.size.width - 100*2)/3*2 + 100  ,(r.size.height - 100*3)/4 + 10, 100, 100);
    CurtainBtn.tag = 1001;
//    CurtainBtn.backgroundColor = [UIColor blueColor];
    CurtainBtn.adjustsImageWhenHighlighted = YES;
    [CurtainBtn setBackgroundImage:[UIImage imageNamed:@"CurtainImage150x150.png"] forState:UIControlStateNormal];
    [CurtainBtn setImage:[UIImage imageNamed:@"CurtainImage150x150.png"] forState:UIControlStateNormal];
    [CurtainBtn setTitle:@"窗帘控制" forState:UIControlStateSelected];
    [CurtainBtn addTarget:self action:@selector(SetbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:CurtainBtn];
    
    
    //电灯控制按钮
    MyButton *LampBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    LampBtn.frame = CGRectMake((r.size.width - 100*2)/3 ,(r.size.height - 100*3)/4*2 + 110, 100, 100);
    LampBtn.tag = 1002;
//    LampBtn.backgroundColor = [UIColor blueColor];
    LampBtn.adjustsImageWhenHighlighted = YES;
    [LampBtn setBackgroundImage:[UIImage imageNamed:@"LampImage150x150.png"] forState:UIControlStateNormal];
    [LampBtn setImage:[UIImage imageNamed:@"LampImage150x150.png"] forState:UIControlStateNormal];
    [LampBtn setTitle:@"电灯控制" forState:UIControlStateNormal];
    [LampBtn addTarget:self action:@selector(SetbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:LampBtn];
    
    //插座控制按钮
    MyButton *ElecSocketBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    ElecSocketBtn.frame = CGRectMake((r.size.width - 100*2)/3*2 + 100  ,(r.size.height - 100*3)/4*2 + 110, 100, 100);
    ElecSocketBtn.tag = 1003;
//    ElecSocketBtn.backgroundColor = [UIColor blueColor];
    ElecSocketBtn.adjustsImageWhenHighlighted = YES;
    [ElecSocketBtn setBackgroundImage:[UIImage imageNamed:@"ElecSocketImage150x150.png"] forState:UIControlStateNormal];
    [ElecSocketBtn setImage:[UIImage imageNamed:@"ElecSocketImage150x150.png"] forState:UIControlStateNormal];
    [ElecSocketBtn setTitle:@"插座控制" forState:UIControlStateSelected];
    [ElecSocketBtn addTarget:self action:@selector(SetbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ElecSocketBtn];
    
    
    //监控查看按钮
    MyButton *WebCamBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    WebCamBtn.frame = CGRectMake((r.size.width - 100*2)/3 ,(r.size.height - 100*3)/4*3+210, 100, 100);
    WebCamBtn.tag = 1004;
//    WebCamBtn.backgroundColor = [UIColor blueColor];
    WebCamBtn.adjustsImageWhenHighlighted = YES;
    [WebCamBtn setBackgroundImage:[UIImage imageNamed:@"WebCamImage150x150.png"] forState:UIControlStateNormal];
    [WebCamBtn setImage:[UIImage imageNamed:@"WebCamImage150x150.png"] forState:UIControlStateNormal];
    [WebCamBtn setTitle:@"监控查看" forState:UIControlStateNormal];
    [WebCamBtn addTarget:self action:@selector(SetbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:WebCamBtn];
    
    //遥控控制按钮
    MyButton *RemoteBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    RemoteBtn.frame = CGRectMake((r.size.width - 100*2)/3*2 + 100  ,(r.size.height - 100*3)/4*3+210, 100, 100);
    RemoteBtn.tag = 1005;
//    RemoteBtn.backgroundColor = [UIColor blueColor];
    RemoteBtn.adjustsImageWhenHighlighted = YES;
    [RemoteBtn setBackgroundImage:[UIImage imageNamed:@"RemoteImage150x150.png"] forState:UIControlStateNormal];
    [RemoteBtn setImage:[UIImage imageNamed:@"RemoteImage150x150.png"] forState:UIControlStateNormal];
    [RemoteBtn setTitle:@"遥控控制" forState:UIControlStateSelected];
    [RemoteBtn addTarget:self action:@selector(SetbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RemoteBtn];

    
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
            if ([tmpString isEqualToString:@"data.ini"]) {
                makeFlag = 0;
                NSLog(@"发现配置文件");
            }
            else{//创建配置文件
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

- (void)makeDataFile
{
    Byte _type = 0x00;
    Byte _ID = 0x00;
    uint64_t _UUIDH = 0x00;
    uint64_t _UUIDL = 0x00;
    NSNumber *type = [[NSNumber alloc] initWithUnsignedChar:_type];
    NSNumber *ID = [[NSNumber alloc] initWithUnsignedChar:_ID];
    NSNumber *UUIDH = [[NSNumber alloc] initWithUnsignedLongLong:_UUIDH];
    NSNumber *UUIDL = [[NSNumber alloc] initWithUnsignedLongLong:_UUIDL];
    NSString *devName = [[NSString alloc] initWithCString:"name" encoding:NSUTF8StringEncoding];
    
    
    NSString *fileName = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    fileName = [documentsDirectory stringByAppendingPathComponent:@"data.ini"];
    
    NSMutableDictionary *dev = [[NSMutableDictionary alloc] init];
    [dev setObject:type forKey:@"type"];
    [dev setObject:ID forKey:@"ID"];
    [dev setObject:UUIDH forKey:@"UUIDH"];
    [dev setObject:UUIDL forKey:@"UUIDL"];
    [dev setObject:devName forKey:@"name"];
    
//    [dev writeToFile:fileName atomically:YES];

    
    NSMutableArray *mArry = [[NSMutableArray alloc] initWithObjects:dev, nil];
    [mArry writeToFile:fileName atomically:YES];
}
- (void)SetbtnClick:(UIButton*)sender
{
    UIButton *btn = sender;
   
    if (btn.tag == 1000){
        SetViewController *sVctr = [[SetViewController alloc] init];
        [self.navigationController pushViewController:sVctr animated:YES];
    }
    else if (btn.tag == 1001) {
        
        CurtainViewController *cVctr = [[CurtainViewController alloc] init];
        [self.navigationController pushViewController:cVctr animated:YES];
    }
    else if (btn.tag == 1002){
        LampViewController *cVctr = [[LampViewController alloc] init];
        [self.navigationController pushViewController:cVctr animated:YES];
        
    }
    else if (btn.tag == 1003){
        ElecSocketViewController *cVctr = [[ElecSocketViewController alloc] init];
        [self.navigationController pushViewController:cVctr animated:YES];
        
    }
    else if (btn.tag == 1004){
        WebCamViewController *cVctr = [[WebCamViewController alloc] init];
        [self.navigationController pushViewController:cVctr animated:YES];
        
    }
    else if (btn.tag == 1005){
        RemoteViewController *cVctr = [[RemoteViewController alloc] init];
        [self.navigationController pushViewController:cVctr animated:YES];
        
    }
    else{
        ;


    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
