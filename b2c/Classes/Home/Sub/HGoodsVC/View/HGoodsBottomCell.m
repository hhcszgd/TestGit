//
//  HGoodsBottomCell.m
//  b2c
//
//  Created by 0 on 16/4/25.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//
#import <WebKit/WebKit.h>
@interface MYWeb : WKWebView<UIGestureRecognizerDelegate>

@end

@implementation MYWeb

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end


#import "HGoodsBottomCell.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface HGoodsBottomCell()<WKUIDelegate,WKScriptMessageHandler,UIScrollViewDelegate , WKNavigationDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSString *goodID;

/**webView*/
@property (nonatomic, weak) MYWeb *webview;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *refreshLabel;


@end
@implementation HGoodsBottomCell


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.isFirst = YES;
        [self setupWebView];
        
    }
    return self;
}
-(void)setupWebView
{
    CGRect frame = self.bounds;
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc]init];
    [config.userContentController addScriptMessageHandler:self name:@"zjlao"];//传值的关键 , 释放的时候记得移除    
    MYWeb * webview = [[MYWeb alloc]initWithFrame:frame configuration:config];
    
    
    
    
    webview.UIDelegate = self;
    webview.scrollView.delegate = self;
    //设置浏览器内左右滑动，支持返回手势
    webview.allowsBackForwardNavigationGestures = YES;
    webview.navigationDelegate = self ;
    
    //    webview.allowsLinkPreview = YES;
    //    self.view.backgroundColor=randomColor;
    self.webview=webview;
    [self.contentView addSubview:webview];
    
    
    [self configHeaderView];
    
}

- (UILabel *)refreshLabel {
    if (_refreshLabel == nil) {
        _refreshLabel = [[UILabel alloc] init];
        [_refreshLabel configmentfont:[UIFont systemFontOfSize:11] textColor:[UIColor colorWithHexString:@"999999"] backColor:[UIColor clearColor] textAligement:NSTextAlignmentCenter cornerRadius:0 text:@""];
        [self.headerView addSubview:_refreshLabel];
    }
    return _refreshLabel;
}

- (void)configHeaderView{
    
    self.headerView.backgroundColor = [UIColor redColor];
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -80, screenW, 80)];
    [self.webview.scrollView addSubview:self.headerView];
    self.refreshLabel.frame = CGRectMake(0, 40, screenW, 30);
    self.refreshLabel.text = @"下拉， 返回商品简介";
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (scrollView.contentOffset.y < - 50) {
        self.refreshLabel.text = @"释放， 查看商品简介";
    }else {
        self.refreshLabel.text = @"下拉， 返回商品简介";
    }
}


//处理手势返回的和web的滑动
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    if ([self panBack:gestureRecognizer]) {
//        return YES;
//    }
//    return NO;
//}
//- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer{
//    CGFloat location_c = 100;
//    if (gestureRecognizer == self.webview.scrollView.panGestureRecognizer) {
//        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
//        CGPoint point = [pan translationInView:self.webview.scrollView];
//        UIGestureRecognizerState state = gestureRecognizer.state;
//        if ((state == UIGestureRecognizerStateBegan)|| (state == UIGestureRecognizerStatePossible)) {
//            CGPoint location = [gestureRecognizer locationInView:self.webview.scrollView];
//            if (point.x > 0 && location.x < location_c && self.webview.scrollView.contentOffset.x <= 0) {
//                return YES;
//            }
//        }
//    }
//    return NO;
//}

- (void)setData:(NSMutableArray *)data{

}

- (void)setGoods_id:(NSString *)goods_id{
    self.goodID = goods_id;
    if (self.isFirst) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/AppOrder/goodsdetails.html?token=%@&id=%@&phone=ios", WAPDOMAIN,[UserInfo shareUserInfo].token, goods_id];
        NSLog(@"%@, %d ,%@",[self class],__LINE__,urlStr);

        NSURL * url = [[NSURL alloc]initWithString:urlStr];
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:url];
        [self.webview loadRequest:request];
        self.isFirst = NO;
    }
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //    LOG_METHOD
#pragma    js传递数据到app
    LOG(@"_%@_%d_%@",[self class] , __LINE__,message.body);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,message.name);
    [self analysisTheDateFromJS:message];
    
    //    15142302652
}
-(void)analysisTheDateFromJS:(WKScriptMessage*)message{
    if ([message.name isEqualToString:@"zjlao"]) {
        if (message.body && [message.body isKindOfClass:[NSDictionary class]]) {
            NSString * action =message.body[@"action"];
            if (action) {
                if ([action isEqualToString:@"alert"]) {
                    [self performAlertWith:message.body];
                }else if ([action isEqualToString:@"confirm"]){
                    [self performConfirmWith:message.body];
                }else if ([action isEqualToString:@"jump"]){
                    [self performJumpWith:message.body];
                }else if ([action isEqualToString:@"pay"]){
                    [self performPayWith:message.body];
                }else if ([action isEqualToString:@"share"]){
                    [self performShareWith:message.body];
                }else if ([action isEqualToString:@"closewebview"]){
                }
            }
            //            LOG(@"_%@_%d_%@",[self class] , __LINE__,message.body[@"action"]);
        }
    }else{
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"js的方法名未在本地注册");
    }
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    webView.alpha = 0 ;
    [UIView animateWithDuration:0.3 animations:^{
        webView.alpha = 1 ;
    }];

}
-(void)performAlertWith:(id)data{
    if ([self.delegate respondsToSelector:@selector(presentAlertWith:)]) {
        [self.delegate performSelector:@selector(presentAlertWith:) withObject:data];
    }
}
-(void)performConfirmWith:(id)data{
    NSDictionary * paramete = (NSDictionary*)data ;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:paramete[@"title"] message:paramete[@"content"] preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertController * alert =[[UIAlertController alloc]init];
    UIAlertAction * actioin1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * js = @"WVcallBack(1);";
        [self.webview evaluateJavaScript:js completionHandler:^(id _Nullable parama, NSError * _Nullable error) {//给js传值1
            LOG(@"_%@_%d_%@",[self class] , __LINE__,parama);
            LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
        }];
    }];
    UIAlertAction * actioin2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSString * js = @"WVcallBack('0');";
        __weak typeof(self) weakSelf = self;
        
        [self.webview evaluateJavaScript:js completionHandler:^(id _Nullable parama, NSError * _Nullable error) {//给js传值0
            LOG(@"_%@_%d_%@",[weakSelf class] , __LINE__,parama);
            LOG(@"_%@_%d_%@",[weakSelf class] , __LINE__,error)
        }];
    }];
    
    [alert addAction:actioin2];
    [alert addAction:actioin1];
    if ([self.delegate respondsToSelector:@selector(presentConfirmWith:)]) {
        [self.delegate performSelector:@selector(presentConfirmWith:) withObject:alert];
    }
}
-(void)performJumpWith:(id)data{
    NSDictionary * paramete = (NSDictionary*)data ;
    NSString * type = paramete[@"type"];
    if (type) {
        if ([type isEqualToString:@"goods"]) {
            NSString * goodsID = paramete[@"id"];//要跳转到商品详情的商品id
            LOG(@"_%@_%d_即将跳转到商品详情页 , 商品id为 :%@",[self class] , __LINE__,goodsID);
            BaseModel * GoodsVCModel = [[BaseModel alloc]init];
            GoodsVCModel.actionKey = @"HGoodsVC";
            GoodsVCModel.keyParamete = @{@"paramete":goodsID};
            if ([self.delegate respondsToSelector:@selector(clickGoodsActionToTheGoodsDetailVCWith:)]) {
                [self.delegate performSelector:@selector(clickGoodsActionToTheGoodsDetailVCWith:) withObject:GoodsVCModel];
            }
        }else if([type isEqualToString:@"coupon"]){
            NSString * couponID = paramete[@"id"];//要跳转到优惠券的优惠券idCouponsDetailVC
            LOG(@"_%@_%d_即将跳转到优惠券详情页 , 优惠券id 为 : %@",[self class] , __LINE__,couponID);
            BaseModel * CouponsDetailVCModel = [[BaseModel alloc]init];
            CouponsDetailVCModel.actionKey = @"CouponsDetailVC";
            CouponsDetailVCModel.keyParamete = @{@"paramete":couponID};
            if ([self.delegate respondsToSelector:@selector(clickGoodsActionToTheGoodsDetailVCWith:)]) {
                [self.delegate performSelector:@selector(clickGoodsActionToTheGoodsDetailVCWith:) withObject:CouponsDetailVCModel];
                
                
            }
        }else if([type isEqualToString:@"couponList"]){
            //直接跳转到优惠券列表页面
            LOG(@"_%@_%d_%@",[self class] , __LINE__,@"即将跳转到优惠券列表页");
            BaseModel * couponseListModel = [[BaseModel alloc]init];
            couponseListModel.actionKey = @"HCouponsVC";
            [[SkipManager shareSkipManager] skipByVC:self withActionModel:couponseListModel];
        }else if([type isEqualToString:@"shop"]){
            NSString * shopID = paramete[@"id"];//要跳转到店铺的店铺id
            LOG(@"_%@_%d_即将跳转到店铺首页 , 店铺id 为 :%@",[self class] , __LINE__,shopID);
            BaseModel * ShopVCModel = [[BaseModel alloc]init];
            ShopVCModel.actionKey = @"HShopVC";
            ShopVCModel.keyParamete = @{@"paramete":shopID};
            [[SkipManager shareSkipManager] skipByVC:self withActionModel:ShopVCModel];
        }else if([type isEqualToString:@"similarityGoods"]){//相似商品  , 记得取出id
            NSString * goodsID = paramete[@"id"];//相似商品的id
            LOG(@"_%@_%d_即将跳转到当前商品的相似商品的列表页 , 当前商品的id为 : %@",[self class] , __LINE__,goodsID);
        }else if ( [type isEqualToString:@"url"]){
            NSString * url = paramete[@"url"];
            BaseModel * CouponsDetailVCModel = [[BaseModel alloc]init];
            CouponsDetailVCModel.actionKey = @"BaseWebVC";
            CouponsDetailVCModel.keyParamete = @{@"paramete":url};
            [[SkipManager shareSkipManager] skipByVC:self withActionModel:CouponsDetailVCModel];
        }
    }
    
}

-(void)performPayWith:(id)data
{    NSDictionary * paramete = (NSDictionary*)data ;
    NSString * type = paramete[@"type"];
    if ([type isEqualToString:@"order"]) {
//        NSString * orderID = paramete[@"id"];
//        LOG(@"_%@_%d_即将执行支付  , 订单id 为 : %@",[self class] , __LINE__,orderID);
//        BaseModel *baseModel = [[BaseModel alloc] init];
//        baseModel.actionKey = @"ChoosePaymentVC";
//        NSDictionary * targetParamete = @{@"orderID":orderID};
//        baseModel.keyParamete = @{@"paramete":targetParamete};
//        [[SkipManager shareSkipManager] skipByVC:self withActionModel:baseModel];
//    }else if ([type isEqualToString:@"check"]){//wap页确认收货时验证支付密码
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"wap页确认收货时验证支付密码");
//        self.confirmInceptOrderID=paramete[@"orderid"];
//        self.confirmInceptShopID = paramete[@"shopid"];
//        [self performpay:nil];
#pragma   app传递数据到js
        //        NSString * js = @"paypassword(283,37,1);";
        //        __weak typeof(self) weakSelf = self;
        //        [self.webview evaluateJavaScript:js completionHandler:^(id _Nullable parama, NSError * _Nullable error) {
        //            LOG(@"_%@_%d_%@",[weakSelf class] , __LINE__,parama);
        //            LOG(@"_%@_%d_%@",[weakSelf class] , __LINE__,error)
        //        }];
        
    }
    
}

/** 确认支付密码相关   ------开始---------- */

-(void)performpay:(UIButton*)sender
{
    ////////////////////////
    //    if (!self.orderID) {
    //        AlertInVC(@"订单id为空")
    //        return;
    //    }
#pragma mark 要先判断用户有没有设置支付密码 ,
//    [self checkPayPasswordSuccess:^(BOOL payPasswordLawful) {
//        if (payPasswordLawful) {//正常结算(弹出输入支付密码)
//            UIButton * corverView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH)];
//            self.corverView = corverView;
//            
//            [self.corverView addTarget:self action:@selector(removeCorver) forControlEvents:UIControlEventTouchUpInside];
//            corverView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.33];
//            [self.view.window addSubview:corverView];
//            [_acceptPassword becomeFirstResponder];
//            
//            //            [self enterPayPasswordAndPayWithBanlance];
//            
//#pragma mark 如果没设置,调到设置支付密码
//        }//走到了确认收货这一步说明一定有了支付密码(不一定啊)
//        else{//
//            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请设置支付密码" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                //                BaseModel * model = [[BaseModel alloc]init];
//                //                model.actionKey = @"";
//                ChangePasswordVC * setPayPsdVC  = [[ChangePasswordVC alloc]initWithType:SetPayPassword];
//                [self.navigationController pushViewController:setPayPsdVC animated:YES];
//                
//            }];
//            UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                
//            }];
//            
//            [alertVC addAction:confirmAction];
//            [alertVC addAction:cancleAction];
//            [self presentViewController:alertVC animated:YES completion:^{
//                
//            }];
//            
//            
//        }
//        
//    } failure:^{
//        //        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"");
//        AlertInVC(@"网络错误")
//    }];
//    
//    
//    
//    
    
    
    
    
}
/** 确认收货结束 */
-(void)performShareWith:(id)data{
//    NSDictionary * paramete = (NSDictionary*)data ;
//    NSString * type = paramete[@"type"];
//    NSDictionary * paramete = (NSDictionary*)data ;
//    NSString * type = paramete[@"type"];

//    if (type) {
//        if ([type isEqualToString:@"goods"]) {//分享商品 , 记得取出id
//            NSString * goodsID = paramete[@"id"];
//            LOG(@"_%@_%d_即将分享当前商品 ,商品 ID为 : %@",[self class] , __LINE__,goodsID);
//        }else if([type isEqualToString:@"coupon"]){//分享优惠券 , 记得取出id
//            NSString * couponID = paramete[@"id"];
//            LOG(@"_%@_%d_即将分享当前优惠券 , 优惠券id为:%@",[self class] , __LINE__,couponID);
//            
//            //            [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeWeb url:@"http://www.zjlao.com"];
//            [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:@"http://http:i0.zjlao.com/terrace_logo.jpg"];
//            
//            [UMSocialData defaultData].extConfig.title = @"一个最具潜力的电商平台";
//            [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"http://m.zjlao.com/Index/couponsdetail/id/%@.html",couponID];
//            [UMSocialData defaultData].extConfig.wechatSessionData.url=[NSString stringWithFormat:@"http://m.zjlao.com/Index/couponsdetail/id/%@.html",couponID];
//            [UMSocialData defaultData].extConfig.wechatTimelineData.url=[NSString stringWithFormat:@"http://m.zjlao.com/Index/couponsdetail/id/%@.html",couponID];
//            [UMSocialData defaultData].extConfig.qzoneData.url=[NSString stringWithFormat:@"http://m.zjlao.com/Index/couponsdetail/id/%@.html",couponID];
//            [UMSocialSnsService presentSnsIconSheetView:self
//                                                 appKey:@"574e769467e58efcc2000937"
//                                              shareText:@"商品从工厂到你家 ,值得信赖"
//                                             shareImage:[UIImage imageNamed:@"icon"]
//                                        shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone]
//                                               delegate:self];
//            
//        }else if([type isEqualToString:@"shop"]){//分享店铺 , 记得取出id
//            NSString * shopID = paramete[@"id"];
//            LOG(@"_%@_%d_即将分享当前店铺 , 店铺id为 : %@",[self class] , __LINE__,shopID);
//        }
//    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.webview.scrollView.contentOffset.y < -50) {
        self.refreshLabel.text = @"下拉，返回商品简介";
         [[NSNotificationCenter defaultCenter] postNotificationName:@"showTopCell" object:nil userInfo:nil];
    }
}

- (void)dealloc{
    LOG(@"%@,%d,%@",[self class], __LINE__,@"销毁")
}



@end









