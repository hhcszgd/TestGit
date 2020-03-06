//
//  HStoreRecommentVC.m
//  b2c
//
//  Created by 0 on 16/3/31.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "HStoreRecommentVC.h"
#import "HNaviCompose.h"
#import "HCellComposeModel.h"
#import "XMPPJID.h"
@interface HStoreRecommentVC ()
/***/
@property (nonatomic, strong)HNaviCompose  *messageButton;
/**卖家user*/
@property (nonatomic, copy) NSString *sellerUser;
@end

@implementation HStoreRecommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originURL = self.keyParamete[@"paramete"];
    self.sellerUser = self.keyParamete[@"sellerUser"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(messageCountChanged) name:MESSAGECOUNTCHANGED object:nil];
    [self configmentNavigation];
//    CGRect frame = CGRectMake(0,64, self.view.bounds.size.width, self.view.bounds.size.height-self.startY);
//    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc]init];
//    [config.userContentController addScriptMessageHandler:self name:@"zjlao"];
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,config.userContentController);
//    
//    WKWebView * webview = [[WKWebView alloc]initWithFrame:frame configuration:config];
//    
//    webview.navigationDelegate = self;
//    webview.UIDelegate = self;
//    webview.allowsBackForwardNavigationGestures = YES;
//    //    webview.allowsLinkPreview = YES;
//    self.view.backgroundColor=randomColor;
//    self.webView=webview;
//    [self.view addSubview:webview];
//    
//    NSURL *url = [NSURL URLWithString:self.url];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
//    
    
    // Do any additional setup after loading the view.
}


#pragma maek -- 设置导航栏
- (void)configmentNavigation{
    
    //右边消息按钮
    HNaviCompose * messageButton = [[HNaviCompose alloc]init];
    self.messageButton = messageButton;
    HCellComposeModel * messageModel = [[HCellComposeModel alloc]init ];
    messageModel.imgForLocal = [UIImage imageNamed:@"icon_news_gray"];
    //    messageModel.messageCountInCompose=[[[NSUserDefaults standardUserDefaults] objectForKey:MESSAGECOUNTCHANGED] integerValue];
    messageButton.composeModel  = messageModel;
    [messageButton addTarget:self action:@selector(message:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationBarRightActionViews = @[messageButton];
    
    
    
}


-(void)messageCountChanged{
    
    
    if ([[NSThread currentThread] isMainThread]) {
        NSLog(@"main");
    } else {
        NSLog(@"not main");
    }
    [self.messageButton changeMessageCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        //do your UI
        HCellComposeModel * messageModel = [[HCellComposeModel alloc]init ];
        messageModel.imgForLocal = [UIImage imageNamed:@"icon_news_gray"];
        NSInteger messageCount =  [[[NSUserDefaults standardUserDefaults] objectForKey:MESSAGECOUNTCHANGED] integerValue];
        //            messageModel.title  = @"消息";
        messageModel.messageCountInCompose=messageCount;
        self.messageButton.composeModel  = messageModel;
        
    });
    
    
}

-(void)messageHasChanged{ [self.messageButton changeMessageCount];}
-(void)message:(ActionBaseView*)sender
{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"跳转消息控制器")
    
        BaseModel *baseModel = [[BaseModel alloc] init];
        baseModel.actionKey = ChatVCName;
        XMPPJID *xm = [XMPPJID jidWithUser:self.sellerUser domain:chatDomain resource:nil];
        
        baseModel.keyParamete = @{@"paramete":xm};
        
        baseModel.judge = YES;
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:baseModel];
        
        
    
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end