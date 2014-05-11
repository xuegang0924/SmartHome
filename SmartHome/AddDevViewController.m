//
//  AddDevViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-9.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "AddDevViewController.h"

@interface AddDevViewController ()
{
    NSMutableData *recMultData ;
    UInt32 recvDataCount;
    NSMutableArray *mArry;
    Byte gType;
    Byte gID;
    uint64_t gUUIDH;
    uint64_t gUUIDL;
    NSString *gDevname;
    UITextField *gDevNameTextf;
    
}
@end

@implementation AddDevViewController

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

    
    
    [self setTitle:@"添加设备"];
    
    //创建socket连接
    if (!_asyncSocket) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self  delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
    }
    //connect to host
    if ([_asyncSocket isDisconnected]) {
        NSError *error;
        if (![_asyncSocket connectToHost:@"192.168.1.1" onPort:2001 withTimeout:5 error:&error]) {
            NSLog(@"connect error");
            return;
        }
    }
    
    [_asyncSocket readDataWithTimeout:-1.0 tag:1];
    
    
    recMultData = [[NSMutableData alloc] init];
    
    CGRect r = [ UIScreen mainScreen ].applicationFrame;//app尺寸，去掉状态栏
    
    UIImage *image = [UIImage imageNamed:@"BackGroundImage320x568.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    //    imageView.frame = CGRectMake(5, 25, image.size.width, image.size.height);
    [imageView setFrame:r];
    imageView.backgroundColor = [UIColor purpleColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    

    
    //发现设备
    UILabel *FindDevLab = [[UILabel alloc] initWithFrame:CGRectZero];
    FindDevLab.text = @"发现设备：";
    FindDevLab.numberOfLines = 0;
    FindDevLab.frame = CGRectMake(20, 80, 100,60);
    [FindDevLab setTextColor:[UIColor yellowColor]];
    [self.view addSubview:FindDevLab];

    //请设定设备名称
    UILabel *DevNameLab = [[UILabel alloc] initWithFrame:CGRectZero];
    DevNameLab.text = @"请设定设备名称:";
    DevNameLab.numberOfLines = 0;
    DevNameLab.frame = CGRectMake(20, 150, 200,50);
    [DevNameLab setTextColor:[UIColor yellowColor]];
    [self.view addSubview:DevNameLab];
    
    //设备名称:
    gDevNameTextf = [[UITextField alloc] init];
    gDevNameTextf.frame = CGRectMake(40, 200, 200, 30);
    //设置边框
    [gDevNameTextf setBorderStyle:UITextBorderStyleRoundedRect];
    //设置提示文字
    [gDevNameTextf setPlaceholder:@"请输入设备名称"];
    //设置键盘样式
    [gDevNameTextf setKeyboardType:UIKeyboardTypeDefault];
    //    [tfIP setKeyboardType:UIKeyboardAppearanceAlert];
    //设置清除按钮
    [gDevNameTextf setClearButtonMode:UITextFieldViewModeAlways];
    //    [tfIP setClearsOnBeginEditing:YES];
    [self.view addSubview:gDevNameTextf];
       
    
    
    UIBarButtonItem *OKBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(itemClick:)];
    OKBtnItem.tag = 10011;
    self.navigationItem.rightBarButtonItem = OKBtnItem;
    
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(10, 20, 30, 40);
//    
//    UIBarButtonItem *btnItem3 = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    //创建一个数组 存放item实例
//    NSArray *arrayItems = [NSArray arrayWithObjects:btnItem2, btnItem3, nil];
//    self.navigationItem.rightBarButtonItems = arrayItems;

    _DevNameLab = [[UILabel alloc] init];
    _DevNameLab.frame = CGRectMake(120, 80, 100, 60);
    [_DevNameLab setTextColor:[UIColor redColor]];
    [_DevNameLab setText:@""];
    [self.view addSubview:_DevNameLab];
    
    
    
}
- (void) itemClick:(UIBarButtonItem *)sender
{
    UIBarButtonItem *btn = sender;
    if (btn.tag == 10011 && !_actIdctV.isAnimating) {

        
        
        gDevname  = [[NSString alloc] initWithString:gDevNameTextf.text];
        
        NSMutableDictionary *mutDic = [self makeWriteDataWithType:gType withID:gID withUUIDH:gUUIDH withUUIDL:gUUIDL withDevName:gDevname];
        NSMutableArray *mutArry = [self readDataFile];
        [mutArry addObject:mutDic];
        [self writeFileUseMutableArry:mutArry];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [_asyncSocket disconnect];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{

    NSData *recData = [[NSData alloc] initWithData:data];
    short recDataLen;
    [recMultData appendData:recData];
    int len = [recMultData length];
    recvDataCount = len;
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
                gType = tmpData[3];
                
                //TODO:find the max id
                NSMutableArray *tmpMutArry = [self readDataFile];
                Byte tmpLastID = 0, tmpPreID  = 0, tmpMaxID = 0;
                for (NSInteger i = 0; i<tmpMutArry.count; i++) {
                    NSMutableDictionary * tmpMutDic = [tmpMutArry objectAtIndex:i];
                    
                    Byte tmpType = [[tmpMutDic objectForKey:@"type"] unsignedCharValue];
                    if (tmpType == gType) {
                        
                        tmpPreID = [[tmpMutDic objectForKey:@"ID"] unsignedCharValue];
                        tmpMaxID = tmpPreID >= tmpLastID ? tmpPreID :tmpLastID;
                        tmpLastID = tmpPreID;
                        
                    }
                }
                
                gID = tmpMaxID + 1;
                
                uint64_t tmpUUID = 0;
                for (int i = 0; i<8; i++) {
                    tmpUUID = tmpUUID << 8;
                    tmpUUID |= tmpData[i+6];
                }
                
                gUUIDH = tmpUUID;

                tmpUUID = 0;
                for (int i = 0; i<8; i++) {
                    tmpUUID = tmpUUID << 8;
                    tmpUUID |= tmpData[i+14];
                }
                
                gUUIDL = tmpUUID;
                
                
                
                switch (tmpData[3]) {
                    case 0x00:
                        NSLog(@"主控");
                        [_DevNameLab setText:@"主控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"主控%d",gID];
                        
                        break;
                    case 0x01:
                        NSLog(@"窗帘开关型");
                        [_DevNameLab setText:@"窗帘开关型"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"窗帘开关型%d",gID];
                        break;
                    case 0x02:
                        NSLog(@"窗帘线型");
                        [_DevNameLab setText:@"窗帘线型"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"窗帘线型%d",gID];
                        break;
                    case 0x03:
                        NSLog(@"插座开关型");
                        [_DevNameLab setText:@"插座开关型"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"插座开关型%d",gID];
                        break;
                    case 0x04:
                        NSLog(@"插座计量型");
                        [_DevNameLab setText:@"插座计量型"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"插座计量型%d",gID];
                        break;
                    case 0x05:
                        NSLog(@"电灯开关型");
                        [_DevNameLab setText:@"电灯开关型"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"电灯开关型%d",gID];
                        break;
                    case 0x06:
                        NSLog(@"电灯线型");
                        [_DevNameLab setText:@"电灯线型"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"电灯线型%d",gID];
                        break;
                    case 0x10:
                        NSLog(@"子红外遥控");
                        [_DevNameLab setText:@"子红外遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"子红外遥控%d",gID];
                        break;
                    case 0x11:
                        NSLog(@"空调遥控");
                        [_DevNameLab setText:@"空调遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"空调遥控%d",gID];
                        break;
                    case 0x12:
                        NSLog(@"电视遥控");
                        [_DevNameLab setText:@"电视遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"电视遥控%d",gID];
                        break;
                    case 0x13:
                        NSLog(@"机顶盒遥控");
                        [_DevNameLab setText:@"机顶盒遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"机顶盒遥控%d",gID];
                        break;
                    case 0x14:
                        NSLog(@"音响功放遥控");
                        [_DevNameLab setText:@"音响功放遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"音响功放遥控%d",gID];
                        break;
                    case 0x15:
                        NSLog(@"蓝光机遥控");
                        [_DevNameLab setText:@"蓝光机遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"蓝光机遥控%d",gID];
                        break;
                    case 0x16:
                        NSLog(@"VCD/DVD遥控");
                        gDevNameTextf.text = [NSString stringWithFormat: @"VCD/DVD遥控%d",gID];
                        [_DevNameLab setText:@"VCD/DVD遥控"];
                        break;
                    case 0x17:
                        NSLog(@"小米盒子奇艺盒子等遥控");
                        [_DevNameLab setText:@"小米盒子奇艺盒子等遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"小米盒子奇艺盒子等遥控%d",gID];
                        break;
                    case 0x18:
                        NSLog(@"自定义遥控");
                        [_DevNameLab setText:@"自定义遥控"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"自定义遥控%d",gID];
                        break;
                        
                    default:
                        NSLog(@"未知设备");
                        [_DevNameLab setText:@"未知设备"];
                        gDevNameTextf.text = [NSString stringWithFormat: @"未知设备%d",gID];
                        break;
                }

                
                [_actIdctV stopAnimating];
                [recMultData setLength:0];
                recvDataCount = 0;
//                [_asyncSocket readDataWithTimeout:-1.0 tag:1];
            }
            else{//如果接收到的数据没有到达接收到数据的长度 并且帧尾不是0xFF继续接收
                [_asyncSocket readDataWithTimeout:-1.0 tag:1];
            }
        } else { //如果接受的数据不够 继续接收
            [_asyncSocket readDataWithTimeout:-1.0 tag:1];
        }
        
    } else { //如果枕头不是0x00 抛掉以前接收的数据重新接收
        //clean recMultData;重新接受
        [recMultData setLength:0];
        recvDataCount = 0;
        [_asyncSocket readDataWithTimeout:-1.0 tag:1];
    }

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
            if ([tmpString isEqualToString:@"data.ini"]) {
                
                NSString *fileName = [[NSString alloc] init];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                fileName = [documentsDirectory stringByAppendingPathComponent:tmpString];
                
                NSMutableArray* mutArry = [[NSMutableArray alloc] initWithContentsOfFile:fileName];

                return mutArry;
            }else{
                return nil;
            }
            
        }
    }else{
        return nil;
    }
    return nil;
}

- (NSMutableDictionary *)makeWriteDataWithType:(Byte)__type withID:(Byte)__ID withUUIDH:(uint64_t)__UUIDH withUUIDL:(uint64_t)__UUIDL withDevName:(NSString *)devName
{
    NSMutableDictionary *dev = [[NSMutableDictionary alloc] init];
   
    Byte _type = __type;
    Byte _ID = __ID;
    uint64_t _UUIDH = __UUIDH;
    uint64_t _UUIDL = __UUIDL;
    NSNumber *type = [[NSNumber alloc] initWithUnsignedChar:_type];
    NSNumber *ID = [[NSNumber alloc] initWithUnsignedChar:_ID];
    NSNumber *UUIDH = [[NSNumber alloc] initWithUnsignedLongLong:_UUIDH];
    NSNumber *UUIDL = [[NSNumber alloc] initWithUnsignedLongLong:_UUIDL];
//    NSString *devName = [[NSString alloc] initWithCString:"name" encoding:NSUTF8StringEncoding];
    
    [dev setObject:type forKey:@"type"];
    [dev setObject:ID forKey:@"ID"];
    [dev setObject:UUIDH forKey:@"UUIDH"];
    [dev setObject:UUIDL forKey:@"UUIDL"];
    [dev setObject:devName forKey:@"name"];

    
    return dev;
}

- (void) writeFileUseMutableArry:(NSMutableArray *)mutArry
{
    NSString *fileName = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    fileName = [documentsDirectory stringByAppendingPathComponent:@"data.ini"];
    
    
    [mutArry writeToFile:fileName atomically:YES];
}

@end