//
//  WebCamViewController.m
//  SmartHome
//
//  Created by Gene on 14-3-2.
//  Copyright (c) 2014年 Gene. All rights reserved.
//

#import "WebCamViewController.h"

@interface WebCamViewController ()
{
    UIWebView *cameView;
    NSURLRequest *urlRequest;
}
@end

@implementation WebCamViewController

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
    
    cameView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, 320, 400)];
    
    cameView.backgroundColor = [UIColor grayColor];
    cameView.delegate = self;
    cameView.scrollView.delegate = self;

    
    [self.view addSubview:cameView];
    
    cameView.userInteractionEnabled = YES;
    cameView.allowsInlineMediaPlayback = YES;
    cameView.suppressesIncrementalRendering = YES;
    
    NSString *cameURL = @"http://192.168.1.1:8080/?action=stream";
    urlRequest =[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:cameURL]];
    
    [cameView loadRequest:urlRequest];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerFun:) userInfo:nil repeats:YES];
}

- (void)timerFun:(id)sender
{
    
    
    cameView.userInteractionEnabled = YES;
    cameView.allowsInlineMediaPlayback = YES;
    cameView.suppressesIncrementalRendering = YES;
    
    [cameView loadRequest:urlRequest];
    
//    [self scrollViewWillBeginDragging:cameView.scrollView];
//    
//    [self scrollViewWillEndDragging:cameView.scrollView withVelocity:CGPointMake(0, 0) targetContentOffset:nil];
//    
//    [self scrollViewDidEndDragging:cameView.scrollView willDecelerate:YES];
//    
//    [self scrollViewWillBeginDecelerating:cameView.scrollView];
//    [self scrollViewDidEndDecelerating:cameView.scrollView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView                                             // any offset changes
{
    NSLog(@"delegate");
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2) // any zoom scale changes
{
    NSLog(@"delegate");
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"delegate");
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    NSLog(@"delegate");
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"delegate");
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView  // called on finger up as we are moving
{
    NSLog(@"delegate");
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView      // called when scroll view grinds to a halt
{
    NSLog(@"delegate");
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    NSLog(@"delegate");
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView    // return a view that will be scaled. if delegate returns nil, nothing happens
{
    NSLog(@"delegate");
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2) // called before the scroll view begins zooming its content
{
    NSLog(@"delegate");
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale // scale between minimum and maximum. called after any 'bounce' animations
{
    NSLog(@"delegate");
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView   // return a yes if you want to scroll to the top. if not defined, assumes YES
{
    NSLog(@"delegate");
    return TRUE;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView      // called when scrolling animation finished. may be called immediately if already at top
{
    NSLog(@"delegate");
}
@end
