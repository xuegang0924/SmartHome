//
//  RemoteViewController.h
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface RemoteViewController : UIViewController< GCDAsyncSocketDelegate,UIPickerViewDelegate,UIPickerViewDataSource >

@end
