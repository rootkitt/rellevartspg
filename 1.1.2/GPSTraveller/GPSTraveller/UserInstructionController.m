//
//  WebViewController.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-7-5.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import "UserInstructionController.h"

#define PATH_USER_INSTRUCTION_FILE     @"Instructions.html"

@interface UserInstructionController ()
{
    UIWebView* mWebView;
}

@property(nonatomic, retain) UIWebView* mWebView;
@end

@implementation UserInstructionController
@synthesize mWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    self.mWebView.delegate = nil;
    self.mWebView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect sFrame = self.view.bounds;
    sFrame.size.height -= self.navigationController.navigationBar.bounds.size.height;
    UIWebView* sWebView = [[UIWebView alloc]initWithFrame:sFrame];
    [sWebView setOpaque:YES];
    [sWebView setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:sWebView];

    self.mWebView = sWebView;
    
    [sWebView release];


    //
    NSString* sBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* sLoc = [sBundlePath stringByAppendingPathComponent:PATH_USER_INSTRUCTION_FILE];
    NSString* sHtmlString = [[NSString alloc]initWithContentsOfFile:sLoc usedEncoding:nil error:nil];
    
    if (nil == sHtmlString)
    {
        NSString* sErrPageHtml = @"<!DOCTYPE HTML><html><meta charset=\"utf-8\">      <head><title>出错页面</title><style type=\"text/css\">body{text-align:center;}</style> </head><body><p>页面加载失败，请稍后尝试！</p></body></html>";
        sHtmlString = sErrPageHtml;
    }
    
    [self.mWebView loadHTMLString:sHtmlString baseURL:[NSURL fileURLWithPath:sLoc]];
    [sHtmlString release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
