//
//  HelpFeedBackVC.m
//  b2c
//
//  Created by wangyuanfei on 3/30/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "HelpFeedBackVC.h"
#import "ChatMsgBackView.h"
#import "XMPPJID.h"
@interface HelpFeedBackVC ()
@property(nonatomic,weak)ActionBaseView * IMView ;
@property(nonatomic,weak)ActionBaseView * feedBackView ;
@end

@implementation HelpFeedBackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setuiUI];
    // Do any additional setup after loading the view.
}
-(void)setuiUI
{
//    UIImageView * IMIconView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 88, 88)];
//    IMIconView.image = [UIImage imageNamed:@"zhekouqu"];
//    [self.view addSubview:IMIconView];
//    
//    
//    UILabel * IMTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(IMIconView.frame)+10, CGRectGetMinY(IMIconView.frame), self.view.bounds.size.width - (CGRectGetMaxX(IMIconView.frame)+10), 32)];
//    IMTitleLabel.text = @"IM在线客服";
//    [self.view addSubview:IMTitleLabel];
//    
    NSString * IMContentStr=  @"我是最贴心的在线人工客服，您在一路捞的任何问题都可以向我咨询哦，我们是7×24小时的服务为您解答疑惑";
    
//    CGSize IMContentStrSize = [IMContentStr sizeWithFont:[UIFont systemFontOfSize:17] MaxSize:CGSizeMake(CGRectGetWidth(IMTitleLabel.frame), CGFLOAT_MAX)];
//    UILabel * IMContentLabel  =  [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(IMTitleLabel.frame), CGRectGetMaxY(IMTitleLabel.frame), self.view.bounds.size.width-10-CGRectGetMinX(IMTitleLabel.frame), IMContentStrSize.height)];
//    IMContentLabel.text = IMContentStr;
//    IMContentLabel.numberOfLines = 0 ;
//    [self.view addSubview:IMContentLabel];
    
    
self.IMView =    [self careatTargetViewWithImgName:@"bg_icon_im" title:@"IM在线客服" contentStr:IMContentStr frameY:150*SCALE];
    [self.IMView addTarget:self action:@selector(gotoIMChat) forControlEvents:UIControlEventTouchUpInside];
    self.IMView.backgroundColor = [UIColor whiteColor];
      NSString * feedBackContentStr=  @"欢迎您提出您的宝贵意见以便于我们更好的服务";
 self.feedBackView =   [self careatTargetViewWithImgName:@"bg_icon_yi" title:@"意见与反馈" contentStr:feedBackContentStr frameY:CGRectGetMaxY(self.IMView.frame)+10];
    self.feedBackView.backgroundColor = [UIColor whiteColor];
    [self.feedBackView addTarget:self action:@selector(feedback) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)gotoIMChat
{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"去跟在线客服小妹聊聊");
    BaseModel * model = [[BaseModel alloc]init];
//    model.actionKey = @"ChatVC";
    model.actionKey = ChatVCName;
    model.keyParamete = @{@"paramete":[XMPPJID jidWithUser:@"kefu" domain:JabberDomain resource:@"iOS"] };
//    model.keyParamete = @{@"paramete":[XMPPJID jidWithUser:@"JohnLock" domain:@"jabber.zjlao.com" resource:@"iOS"] };

    [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
}
-(void)feedback
{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"去跟在线客服小妹聊聊");
    BaseModel * model = [[BaseModel alloc]init];
    model.actionKey = @"AskAndFeedbackVC";
    [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"这货要投诉了");
}
-(ActionBaseView*)careatTargetViewWithImgName:(NSString*)imgName title:(NSString*)title contentStr:(NSString*)contentstr frameY:(CGFloat)frameY
{
    ActionBaseView * view = [[ActionBaseView alloc]init];
    view.layer.cornerRadius = 8 ;
    view.layer.masksToBounds = YES;
    CGFloat margin = 10 ;
    CGFloat viewW = self.view.bounds.size.width - margin * 2;
    
    [self.view addSubview:view];
    UIImageView * IMIconView = [[UIImageView alloc]initWithFrame:CGRectMake(margin*2, margin, 48, 48)];
    IMIconView.image = [UIImage imageNamed:imgName];
    [view addSubview:IMIconView];
    
    UILabel * titleBelowImg = [[UILabel alloc]init];
    titleBelowImg.font = [UIFont systemFontOfSize:14];
    titleBelowImg.bounds =CGRectMake(0, 0, IMIconView.bounds.size.width+margin*3, 20);
    [view addSubview:titleBelowImg];
    titleBelowImg.center = CGPointMake(IMIconView.center.x, CGRectGetMaxY(IMIconView.frame) +20 );
    titleBelowImg.textAlignment = NSTextAlignmentCenter;
    titleBelowImg.text = title;
    
    
    
    UILabel * IMTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(IMIconView.frame)+margin*2, CGRectGetMinY(IMIconView.frame), viewW - (CGRectGetMaxX(IMIconView.frame)+margin*3), [UIFont systemFontOfSize:13].lineHeight+2)];
    IMTitleLabel.text =@"点击进入";
    IMTitleLabel.font = [UIFont systemFontOfSize:13];
    IMTitleLabel.textColor = MainTextColor;
    [view addSubview:IMTitleLabel];
    NSString * IMContentStr=  contentstr;
    CGSize IMContentStrSize = [IMContentStr sizeWithFont:[UIFont systemFontOfSize:13] MaxSize:CGSizeMake(CGRectGetWidth(IMTitleLabel.frame), CGFLOAT_MAX)];
    UILabel * IMContentLabel  =  [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(IMTitleLabel.frame), CGRectGetMaxY(IMTitleLabel.frame)+10,IMContentStrSize.width, IMContentStrSize.height)];
    IMContentLabel.font = [UIFont systemFontOfSize:13];
    IMContentLabel.textColor = SubTextColor;
    IMContentLabel.text = IMContentStr;
    IMContentLabel.numberOfLines = 0 ;
    [view addSubview:IMContentLabel];
    
    
    
    
    if (CGRectGetMaxY(titleBelowImg.frame)>CGRectGetMaxY(IMContentLabel.frame)) {
        view.frame = CGRectMake(margin, frameY, viewW, 88 + 20 );
        
    }else{
        view.frame = CGRectMake(margin, frameY, viewW, CGRectGetHeight(IMTitleLabel.frame)+CGRectGetHeight(IMContentLabel.frame)   +margin*4  );
    
    }
    
    
    
    
    
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"fuck , 内存警告");
    // Dispose of any resources that can be recreated.
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
