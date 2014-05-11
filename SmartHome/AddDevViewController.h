//
//  AddDevViewController.h
//  SmartHome
//
//  Created by Gene on 14-3-9.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface AddDevViewController : UIViewController < GCDAsyncSocketDelegate >
{
    UILabel *_DevNameLab;
    UIActivityIndicatorView *_actIdctV;
    GCDAsyncSocket*_asyncSocket;
}
@end

