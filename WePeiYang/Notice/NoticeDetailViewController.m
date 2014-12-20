//
//  NoticeDetailViewController.m
//  WePeiYang
//
//  Created by Qin Yubo on 13-12-12.
//  Copyright (c) 2013年 Qin Yubo. All rights reserved.
//

#import "NoticeDetailViewController.h"
#import "data.h"
#import "AFNetworking.h"
#import "wpyStringProcessor.h"
#import "SVProgressHUD.h"
#import "WePeiYang-Swift.h"

@interface NoticeDetailViewController ()

@end

@implementation NoticeDetailViewController

{
    UIAlertView *waitingAlert;
}

@synthesize webView;
@synthesize noticeId;
@synthesize noticeTitle;

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
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.title = noticeTitle;
    
    UIBarButtonItem *share = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openActionSheet)];
    [self.navigationItem setRightBarButtonItem:share];
    
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *url = @"http://push-mobile.twtapps.net/content/detail";
    NSDictionary *parameters = @{@"ctype":@"news",@"index":noticeId};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        [self dealWithReceivedData:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"无法获取公告T^T"];
        [SVProgressHUD dismiss];
    }];
}

- (void)dealWithReceivedData:(NSDictionary *)contentDic
{
    NSString *content;
    if ([contentDic count]>0)
    {
        content = [contentDic objectForKey:@"content"];
    }
    
    NSURL *baseURL = [[NSURL alloc]initWithString:@"http://mynews.twtstudio.com/newspic/picture/"];
    
    [self.webView loadHTMLString:[wpyStringProcessor convertToBootstrapHTMLWithContent:content] baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openActionSheet
{
    wpyActionSheet *actionSheet = [[wpyActionSheet alloc]initWithTitle:@"更多"];
    
    [actionSheet addButtonWithTitle:@"分享" image:[UIImage imageNamed: @"shareInSheet.png"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share];
    }];
    
    [actionSheet addButtonWithTitle:@"收藏" image:[UIImage imageNamed: @"addToFav.png"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self addToFav];
    }];
    
    [actionSheet addButtonWithTitle:@"在 Safari 中打开" image:[UIImage imageNamed: @"openInSafari.png"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self openInSafari];
    }];
    
    [actionSheet show];
}

- (void)share
{
    NSArray *activityItems;
    NSString *urlStr = [NSString stringWithFormat:@"http://news.twt.edu.cn/?c=default&a=pernews&id=%@",noticeId];
    //NSString *title = noticeTitle;
    
    //NSString *shareString = [[NSString alloc]initWithFormat:@"%@",title];
    NSURL *shareURL = [NSURL URLWithString:urlStr];
    activityItems = @[shareURL];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}


- (void)openInSafari
{
    NSString *urlStr = [NSString stringWithFormat:@"http://news.twt.edu.cn/?c=default&a=pernews&id=%@",noticeId];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication]openURL:url];
}

- (void)addToFav
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"noticeFavData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:plistPath])
    {
        [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    NSMutableDictionary *noticeFavDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    if (noticeFavDic == nil)
    {
        noticeFavDic = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    [newDic setObject:noticeTitle forKey:@"title"];
    [newDic setObject:noticeId forKey:@"id"];
    
    [noticeFavDic setObject:newDic forKey:noticeTitle];
    [noticeFavDic writeToFile:plistPath atomically:YES];
    
    [SVProgressHUD showSuccessWithStatus:@"公告收藏成功！"];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor colorWithRed:232/255.0f green:159/255.0f blue:0/255.0f alpha:1.0f];
        }
    }];
}

@end
