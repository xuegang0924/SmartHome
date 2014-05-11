//
//  SetViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "SetViewController.h"
#import "MyButton.h"
#import "AddDevViewController.h"

@interface SetViewController ()


@end

@implementation SetViewController

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
    [self setTitle:@"设置"];
    
    

    
    
    CGRect r = [ UIScreen mainScreen ].applicationFrame;//app尺寸，去掉状态栏
    
    UIImage *image = [UIImage imageNamed:@"Default-586h.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    //    imageView.frame = CGRectMake(5, 25, image.size.width, image.size.height);
    [imageView setFrame:r];
    imageView.backgroundColor = [UIColor purpleColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];

    //IP:
    UILabel *labIPAddress = [[UILabel alloc] initWithFrame:CGRectZero];
    labIPAddress.text = @"IP:";
    labIPAddress.numberOfLines = 0;
    labIPAddress.frame = CGRectMake(10, 140, 50,30);
    [labIPAddress setTextColor:[UIColor yellowColor]];
    [self.view addSubview:labIPAddress];
    
    //PORT:
    UILabel *labPort = [[UILabel alloc] initWithFrame:CGRectZero];
    labPort.text = @"PORT:";
    labPort.numberOfLines = 0;
    labPort.frame = CGRectMake(10, 180, 50,30);
    [labPort setTextColor:[UIColor yellowColor]];
    [self.view addSubview:labPort];
    
    //IP:
    UITextField *tfIP = [[UITextField alloc] init];
    tfIP.frame = CGRectMake(40, 140, 200, 30);
    //设置边框
    [tfIP setBorderStyle:UITextBorderStyleRoundedRect];
    //设置提示文字
    [tfIP setPlaceholder:@"192.168.1.1"];
    tfIP.text = @"192.168.1.1";
    //设置键盘样式
    [tfIP setKeyboardType:UIKeyboardTypeNumberPad];
//    [tfIP setKeyboardType:UIKeyboardAppearanceAlert];
    //设置清除按钮
    [tfIP setClearButtonMode:UITextFieldViewModeAlways];
//    [tfIP setClearsOnBeginEditing:YES];
    [self.view addSubview:tfIP];

    //PORT:
    UITextField *tfPORT = [[UITextField alloc] init];
    tfPORT.frame = CGRectMake(80, 180, 100, 30);
    //设置边框
    [tfPORT setBorderStyle:UITextBorderStyleRoundedRect];
    //设置提示文字
    [tfPORT setPlaceholder:@"2001"];
    tfPORT.text = @"2001";
    //设置键盘样式
    [tfPORT setKeyboardType:UIKeyboardTypeNumberPad];
    //    [tfIP setKeyboardType:UIKeyboardAppearanceAlert];
    //设置清除按钮
    [tfPORT setClearButtonMode:UITextFieldViewModeAlways];
    //    [tfIP setClearsOnBeginEditing:YES];
    [self.view addSubview:tfPORT];
    
    //确认按钮
    UIButton *OkBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    OkBtn.frame = CGRectMake(270,140,40,40);
    OkBtn.tag = 10003;
    OkBtn.backgroundColor = [UIColor redColor];
    OkBtn.adjustsImageWhenHighlighted = YES;
//    [OkBtn setBackgroundImage:[UIImage imageNamed:@"DownImage65x40.png"] forState:UIControlStateNormal];
//    [OkBtn setImage:[UIImage imageNamed:@"DownImage65x40.png"] forState:UIControlStateNormal];
    [OkBtn setTitle:@"确认" forState:UIControlStateSelected];
    [OkBtn setTintColor:[UIColor blueColor]];
    [OkBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:OkBtn];
    
    
    //添加设备按钮
    MyButton *AddDevBtn = [MyButton buttonWithType:UIButtonTypeCustom];
    AddDevBtn.frame = CGRectMake(100,300,120,120);
    AddDevBtn.tag = 10010;
    AddDevBtn.backgroundColor = [UIColor redColor];
    AddDevBtn.adjustsImageWhenHighlighted = YES;
    [AddDevBtn setBackgroundImage:[UIImage imageNamed:@"addDevImage240x240.png"] forState:UIControlStateNormal];
    [AddDevBtn setImage:[UIImage imageNamed:@"addDevImage240x240.png"] forState:UIControlStateNormal];
    [AddDevBtn setTitle:@"添加设备" forState:UIControlStateSelected];
    [AddDevBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:AddDevBtn];
    
}
- (void)btnClick:(UIButton*)sender
{
    UIButton *btn = sender;
    if (btn.tag == 10010) {
        AddDevViewController *cVctr = [[AddDevViewController alloc] init];
        [self.navigationController pushViewController:cVctr animated:YES];
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
