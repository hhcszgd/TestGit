//
//  HCouponsVC.m
//  b2c
//
//  Created by wangyuanfei on 16/4/18.
//  Copyright © 2016年 www.16lao.com. All rights reserved.青蛙啊                                                                                                                                                          啊
//

#import "HCouponsVC.h"
//#import "BaseModel.h"
#import "HCConditionModel.h"
#import "HCCouponModel.h"
#import "HCCouponCell.h"
#import "HCCouponcellCompose.h"
#import "CouponsDetailVC.h"
#import "UIImage+Extension.h"
#import "UMSocialData.h"

#import "UMSocialSnsService.h"

#import "UMSocialSnsPlatformManager.h"

@interface HCouponsVC ()<HCCouponCellDelegate,UMSocialUIDelegate>
/** 调接口时传的 与条件对应的参数 ,根据totalConditionValues的count来定 */
@property(nonatomic,strong) NSMutableArray  * conditionKeis ;
/** 上部分价格 ,全部 等条件 */
@property(nonatomic,strong)NSMutableArray * priceConditionValues ;
/** 下部分 类别关键词 条件 */
@property(nonatomic,strong)NSMutableArray * classifyConditionValues ;
/** 盛放上下两个条件的集合数据 */
@property(nonatomic,strong)NSMutableArray * totalConditionValues ;
/** 条件点击视图的容器数组 */
@property(nonatomic,strong)NSMutableArray * totalSubviewContainer ;
/** 优惠券们 */
@property(nonatomic,strong)NSMutableArray * coupons ;
/** 顶部条的总容器 */
@property(nonatomic,weak)UIView * topBarContainer ;
/** 上部分价格等条件子视图的容器视图 */
@property(nonatomic,weak)UIView * priceViewContainer ;
/** 类别按钮 */
@property(nonatomic,weak)UIButton * classifyButton ;
/** 类别子视图的容器视图 */
@property(nonatomic,weak)UIView * classifyContainer ;
/** 遮盖 */
@property(nonatomic,weak)UIButton * cover  ;
/** 橘色滑块儿 */
@property(nonatomic,weak)UIView * slider ;
/** 当前被选中的价格的按钮 */
@property(nonatomic,weak)UIButton * currentPriceBtn ;

/** 当前被选中的类别的按钮 */
@property(nonatomic,weak)UIButton  *  currentClassifyBtn ;
@property(nonatomic,assign)NSUInteger currentClassifyBtnID ;
/** yema */
@property(nonatomic,assign)NSUInteger  pageNum ;

@end

@implementation HCouponsVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addsubviewsInCouponsVC];
//    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
    [self gotCouponsDataWithPageNum:1 price_id:0 classify_id:0 actionType:Init Success:^{
        
        [self.tableView reloadData];
        [self setSubPriceView];
        CGSize defaultSize = [self.currentPriceBtn.currentTitle sizeWithFont:self.currentPriceBtn.titleLabel.font MaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];

        //滑块儿宽度取决于文字的宽度 , so要保证有文字以后再设置滑块儿的frame
        CGFloat sliderW = defaultSize.width ;
        CGFloat sliderH = 5 ;
        CGFloat sliderCenterX = self.currentPriceBtn.bounds.size.width/2 ;
        CGFloat sliderCenterY = self.topBarContainer.bounds.size.height - sliderH/2 ;
        UIView * slider = [[UIView alloc]init];
        slider.bounds = CGRectMake(0, 0, sliderW, sliderH);
        slider.center = CGPointMake(sliderCenterX, sliderCenterY);
        [self.priceViewContainer addSubview:slider];
        slider.backgroundColor = THEMECOLOR;
        self.slider=slider;
        
        [self setupRefreshUI];
        
    } failure:^{
        [self showTheViewWhenDisconnectWithFrame:CGRectMake(0, self.startY, self.view.bounds.size.width, self.view.bounds.size.height - self.startY)];
    }];
}

-(void)setupRefreshUI
{
    
    HomeRefreshHeader * refreshHeader = [HomeRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.tableView.mj_header=refreshHeader;
    HomeRefreshFooter* refreshFooter = [HomeRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(LoadMore)];
    self.tableView.mj_footer = refreshFooter;
    
    [self.tableView reloadData];
    
}
/** 刷新回调方法 */
-(void)refreshData
{
    [super refreshData];

    self.tableView.mj_footer.state =  MJRefreshStateIdle;
    //执行请求操作
    NSUInteger priceID = 0 ;
    NSUInteger classifyID = 0 ;
    self.pageNum = 1 ;
    if (self.currentPriceBtn) {
        HCConditionModel * currentPriceModel = self.priceConditionValues[self.currentPriceBtn.tag-2015];
        priceID = [currentPriceModel.ID integerValue];
    }
    if (self.currentClassifyBtn) {
        HCConditionModel * currentClassifyModel = self.classifyConditionValues[self.currentClassifyBtn.tag-2015-self.priceConditionValues.count];
        classifyID = [currentClassifyModel.ID integerValue];
    }
    
    [self gotCouponsDataWithPageNum:1 price_id:priceID classify_id:self.currentClassifyBtnID actionType:Refresh  Success:^{
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } failure:^{
        [self.tableView.mj_header endRefreshing];
    }];
    
    

}

/** 加载更多的回调方法 */
-(void)LoadMore
{
    [super LoadMore];
    //执行请求操作
    NSUInteger priceID = 0 ;
    NSUInteger classifyID = 0 ;
    if (self.currentPriceBtn) {
        HCConditionModel * currentPriceModel = self.priceConditionValues[self.currentPriceBtn.tag-2015];
        priceID = [currentPriceModel.ID integerValue];
    }
    if (self.currentClassifyBtn) {
        HCConditionModel * currentClassifyModel = self.classifyConditionValues[self.currentClassifyBtn.tag-2015-self.priceConditionValues.count];
        classifyID = [currentClassifyModel.ID integerValue];
    }
    
    
    [self gotCouponsDataWithPageNum:++self.pageNum price_id:priceID classify_id:self.currentClassifyBtnID actionType:LoadMore  Success:^{
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    } failure:^{
        [self.tableView.mj_footer endRefreshing];
    }];
    
    
    
}
-(void)reconnectClick:(UIButton*)sender{//没网是的点击页面的点击方法
    [self gotCouponsDataWithPageNum:1 price_id:0 classify_id:7 actionType:Init Success:^{
        [self.tableView reloadData];
        [self removeTheViewWhenConnect];
    } failure:^{

    }];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"fuck , 内存警告");
    // Dispose of any resources that can be recreated.
}

-(void)addsubviewsInCouponsVC
{
    CGFloat barW = self.view.bounds.size.width  ;
    CGFloat barH = 50  ;
    CGFloat barX =0  ;
    CGFloat barY = self.startY  ;
    
    
    CGFloat tabviewW = self.view.bounds.size.width ;
    CGFloat tabviewH = self.view.bounds.size.height-barH - self.startY ;
    CGFloat tabviewX = 0 ;
    CGFloat tabviewY =  barH + self.startY;
    
    
    UITableView     * tableView =[[UITableView alloc]initWithFrame:CGRectMake(tabviewX, tabviewY, tabviewW, tabviewH) style:UITableViewStyleGrouped];
    self.tableView =tableView;
    tableView.showsVerticalScrollIndicator = NO ;
    //    tableView.bounces=NO ;
    tableView.separatorStyle=0;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = BackgroundGray;
    tableView.delegate=self;
    tableView.dataSource = self;
    
    //    tableView.rowHeight = UITableViewAutomaticDimension;
    //    tableView.estimatedRowHeight=200;
    tableView.rowHeight = 90*SCALE ;
    
    
    
    
    
    
    UIView * topBarContainer =[[UIView alloc]initWithFrame:CGRectMake(barX, barY, barW, barH) ];
    
    [self.view addSubview:topBarContainer];
    self.topBarContainer = topBarContainer;
    
    self.topBarContainer.backgroundColor = [UIColor whiteColor];
    CGFloat grayLineW = self.topBarContainer.bounds.size.width ;
    CGFloat grayLineH = 0.5 ;
    CGFloat grayLineX = 0 ;
    CGFloat grayLineY = self.topBarContainer.bounds.size.height-0.25 ;
    UIView * grayLine = [[UIView alloc]initWithFrame:CGRectMake(grayLineX, grayLineY, grayLineW, grayLineH)];
    grayLine.backgroundColor = SubTextColor;
    [self.topBarContainer addSubview:grayLine];
    
    
    
//    CGFloat btnW = 60 ;
//    CGFloat btnH = barH ;
//    CGFloat btnX = barW - btnW ;
//    CGFloat btnY = 0 ;
//
//    UIButton * classifyButton = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
//    [classifyButton.titleLabel setFont:[UIFont systemFontOfSize:14*SCALE]];
//    
//    [classifyButton setTitle:@"类别" forState:UIControlStateNormal];
//    [classifyButton addTarget:self action:@selector(classifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.classifyButton = classifyButton ;
//    [classifyButton setTitleColor:MainTextColor forState:UIControlStateNormal];
//    [classifyButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
//    //    classifyButton.backgroundColor = randomColor;
//    [self.topBarContainer addSubview:classifyButton];
    CGFloat grayColLineW = 0.5 ;
    CGFloat grayColLineH = self.classifyButton.bounds.size.height/2 ;
    CGFloat grayColLineX = 0 ;
    CGFloat grayColLineY = (self.classifyButton.bounds.size.height - grayColLineH)/2 ;
    UIView * grayColLine = [[UIView alloc]initWithFrame:CGRectMake(grayColLineX, grayColLineY, grayColLineW, grayColLineH)];
    grayColLine.backgroundColor = SubTextColor;
    [self.classifyButton addSubview:grayColLine];
    
    
    CGFloat priceViewW = barW ;
    CGFloat priceViewH = barH ;
    CGFloat priceViewX = 0 ;
    CGFloat priceViewY = 0 ;
    
    UIView * priceViewContainer = [[UIView alloc]initWithFrame:CGRectMake(priceViewX,priceViewY,priceViewW,priceViewH) ];
    //    priceViewContainer.backgroundColor = randomColor;
    self.priceViewContainer = priceViewContainer;
    [self.topBarContainer addSubview:priceViewContainer];
    [self setSubPriceView];
    
    
    
    
}
/**最早由类别的版本的布局*/
//-(void)addsubviewsInCouponsVC
//{
//    CGFloat barW = self.view.bounds.size.width  ;
//    CGFloat barH = 50  ;
//    CGFloat barX =0  ;
//    CGFloat barY = self.startY  ;
//    
//    
//    CGFloat tabviewW = self.view.bounds.size.width ;
//    CGFloat tabviewH = self.view.bounds.size.height-barH - self.startY ;
//    CGFloat tabviewX = 0 ;
//    CGFloat tabviewY =  barH + self.startY;
//    
//    
//    UITableView     * tableView =[[UITableView alloc]initWithFrame:CGRectMake(tabviewX, tabviewY, tabviewW, tabviewH) style:UITableViewStyleGrouped];
//    self.tableView =tableView;
//    tableView.showsVerticalScrollIndicator = NO ;
////    tableView.bounces=NO ;
//    tableView.separatorStyle=0;
//    tableView.showsVerticalScrollIndicator = NO;
//    tableView.backgroundColor = BackgroundGray;
//    tableView.delegate=self;
//    tableView.dataSource = self;
//    
//    //    tableView.rowHeight = UITableViewAutomaticDimension;
//    //    tableView.estimatedRowHeight=200;
//    tableView.rowHeight = 90*SCALE ;
//    
//    UIView * topBarContainer =[[UIView alloc]initWithFrame:CGRectMake(barX, barY, barW, barH) ];
//    
//    [self.view addSubview:topBarContainer];
//    self.topBarContainer = topBarContainer;
//    
//    self.topBarContainer.backgroundColor = [UIColor whiteColor];
//    CGFloat grayLineW = self.topBarContainer.bounds.size.width ;
//    CGFloat grayLineH = 0.5 ;
//    CGFloat grayLineX = 0 ;
//    CGFloat grayLineY = self.topBarContainer.bounds.size.height-0.25 ;
//    UIView * grayLine = [[UIView alloc]initWithFrame:CGRectMake(grayLineX, grayLineY, grayLineW, grayLineH)];
//    grayLine.backgroundColor = SubTextColor;
//    [self.topBarContainer addSubview:grayLine];
//    
//
//    
//    CGFloat btnW = 60 ;
//    CGFloat btnH = barH ;
//    CGFloat btnX = barW - btnW ;
//    CGFloat btnY = 0 ;
//    
//    UIButton * classifyButton = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
//    [classifyButton.titleLabel setFont:[UIFont systemFontOfSize:14*SCALE]];
//    
//    [classifyButton setTitle:@"类别" forState:UIControlStateNormal];
//    [classifyButton addTarget:self action:@selector(classifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.classifyButton = classifyButton ;
//    [classifyButton setTitleColor:MainTextColor forState:UIControlStateNormal];
//    [classifyButton setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
////    classifyButton.backgroundColor = randomColor;
//    [self.topBarContainer addSubview:classifyButton];
//    CGFloat grayColLineW = 0.5 ;
//    CGFloat grayColLineH = self.classifyButton.bounds.size.height/2 ;
//    CGFloat grayColLineX = 0 ;
//    CGFloat grayColLineY = (self.classifyButton.bounds.size.height - grayColLineH)/2 ;
//    UIView * grayColLine = [[UIView alloc]initWithFrame:CGRectMake(grayColLineX, grayColLineY, grayColLineW, grayColLineH)];
//    grayColLine.backgroundColor = SubTextColor;
//    [self.classifyButton addSubview:grayColLine];
//    
//    
//    CGFloat priceViewW = btnX ;
//    CGFloat priceViewH = barH ;
//    CGFloat priceViewX = 0 ;
//    CGFloat priceViewY = 0 ;
//    
//    UIView * priceViewContainer = [[UIView alloc]initWithFrame:CGRectMake(priceViewX,priceViewY,priceViewW,priceViewH) ];
////    priceViewContainer.backgroundColor = randomColor;
//    self.priceViewContainer = priceViewContainer;
//    [self.topBarContainer addSubview:priceViewContainer];
//    [self setSubPriceView];
//
//    
//
//    
//}

-(void)setSubPriceView
{
    for (UIView * sub  in self.priceViewContainer.subviews) {
        [sub removeFromSuperview];
    }
    CGFloat composeH =  self.priceViewContainer.bounds.size.height;
    CGFloat composeW =  self.priceViewContainer.bounds.size.width/(self.priceConditionValues.count);
    CGFloat composeX = 0 ;
    CGFloat composeY = 0 ;
    for (int i = 0 ;  i < self.priceConditionValues.count; i++) {
        HCConditionModel * conditionModel  =  self.priceConditionValues[i];
        composeX = i * composeW;
        
        UIButton * sub = [[UIButton alloc]initWithFrame:CGRectMake(composeX, composeY, composeW, composeH)];
        sub.tag = 2015 + i ;
        [sub addTarget:self action:@selector(chooseClick:) forControlEvents:UIControlEventTouchUpInside];
         sub.adjustsImageWhenHighlighted = NO;
        sub.showsTouchWhenHighlighted = NO;
        [sub.titleLabel setFont:[UIFont systemFontOfSize:14*SCALE]];
        [sub setTitleColor:MainTextColor forState:UIControlStateNormal];
        [sub setTitleColor:THEMECOLOR forState:UIControlStateSelected];
        [self.priceViewContainer addSubview:sub];
//        sub.backgroundColor = randomColor;
        [sub setTitle:conditionModel.title forState:UIControlStateNormal];
        if (i==0) {
            [self chooseClick:sub];
            self.currentPriceBtn = sub ;

            LOG(@"_%@_%d_%@",[self class] , __LINE__,self.currentPriceBtn)
        }
    }
}
-(void)classifyBtnClick:(UIButton*)sender
{
    

    
    sender.selected = ! sender.selected;
    CGFloat composeH = 40 ;
    CGFloat composeW = self.topBarContainer.bounds.size.width/4 ;
    CGFloat composeX = 0 ;
    CGFloat composeY = 0 ;
    
    NSUInteger count = self.classifyConditionValues.count;
    NSUInteger row = 0 ;
    if (count%4==0) {
        row = count/4;
    }else{
        row = count/4 +1 ;
    }
    
    CGFloat classifyContainerW = self.topBarContainer.bounds.size.width     ;
    CGFloat classifyContainerH = composeH * row ;
    CGFloat classifyContainerX = 0 ;
    CGFloat classifyContainerY = CGRectGetMaxY(self.topBarContainer.frame) - classifyContainerH ;
    
    
    if (sender.selected) {
        UIView * classifyContainer = [[UIView alloc]initWithFrame:CGRectMake(classifyContainerX, classifyContainerY, classifyContainerW, classifyContainerH)];
        classifyContainer.backgroundColor =[UIColor whiteColor];
        self.classifyContainer  = classifyContainer;
        [self.view insertSubview:classifyContainer belowSubview:self.topBarContainer];
        for (int i = 0 ; i< self.classifyConditionValues.count; i++) {
            HCConditionModel * conditionModel  =  self.classifyConditionValues[i];
            UIButton * btn = [UIButton buttonWithType:0];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setHighlighted:NO];
//            btn.backgroundColor = randomColor;
            btn.tag = 2015 + self.priceConditionValues.count + i;
            [btn addTarget:self action:@selector(chooseClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14*SCALE]];
            [btn setTitleColor:MainTextColor forState:UIControlStateNormal];
            [btn setTitleColor:THEMECOLOR forState:UIControlStateSelected];
            [btn setTitleColor:THEMECOLOR forState:UIControlStateHighlighted];
            
            composeX = i%4*(composeW);
            composeY = i/4*(composeH);
            btn.frame = CGRectMake(composeX, composeY, composeW, composeH);
            [classifyContainer addSubview:btn];
            [btn setTitle:conditionModel.title forState:UIControlStateNormal];
            if (self.currentClassifyBtnID == [conditionModel.ID integerValue]) {
                self.currentClassifyBtn = btn;
            }
        }
        
        CGFloat coverW = self.view.bounds.size.width ;
        CGFloat coverH = self.view.bounds.size.height-CGRectGetMaxY(self.topBarContainer.frame) ;
        CGFloat coverX = 0 ;
        CGFloat coverY = CGRectGetMaxY(self.topBarContainer.frame) ;
        UIButton * cover = [[UIButton alloc]initWithFrame:CGRectMake(coverX, coverY, coverW, coverH)];
        cover.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
        [cover addTarget:self action:@selector(clickCover:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:cover aboveSubview:self.tableView];
        self.cover = cover ;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.classifyContainer.frame = CGRectMake(classifyContainerX, classifyContainerY+classifyContainerH, classifyContainerW, classifyContainerH);
            cover.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        }];
        
    }else{
    
        [UIView animateWithDuration:0.3 animations:^{
            self.classifyContainer.frame = CGRectMake(classifyContainerX, classifyContainerY, classifyContainerW, classifyContainerH);
            self.cover.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0];
        }completion:^(BOOL finished) {
            [self.classifyContainer removeFromSuperview];
            self.classifyContainer = nil ;
            [self.cover removeFromSuperview];
            self.cover=nil;
        }];
    }
    LOG(@"_%@_%d_%@",[self class] , __LINE__,sender)
}

-(void)chooseClick:(UIButton*)sender
{
    self.tableView.mj_footer.state = MJRefreshStateIdle;
//    self.currentPriceBtn.selected = NO;
    
//    sender.selected = !sender.selected;
//    if (self.currentPriceBtn.tag == sender.tag) {
//        return;
//    }else{
//    
//        self.currentPriceBtn = sender;
//    }
//
    self.pageNum =  1  ;
    if (sender.tag<2015+self.priceConditionValues.count) {//点击价格
            if (self.currentPriceBtn.tag == sender.tag && self.currentPriceBtn) {
                return;
            }else{
                self.currentPriceBtn.selected = NO ;
                sender.selected = YES;
                self.currentPriceBtn = sender;
                CGRect oldFrame = sender.frame;
                CGSize currentSize = [self.currentPriceBtn.currentTitle sizeWithFont:self.currentPriceBtn.titleLabel.font MaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
                CGRect sliderOldFrame  = self.slider.frame ;
                self.slider.bounds = CGRectMake(0, 0, currentSize.width, sliderOldFrame.size.height);
                self.slider.center = CGPointMake(oldFrame.origin.x+oldFrame.size.width/2, self.topBarContainer.bounds.size.height - self.slider.bounds.size.height/2);
                //指向请求操作
                HCConditionModel * currentPriceModel = self.priceConditionValues[sender.tag-2015];
                [self gotCouponsDataWithPageNum:1 price_id:[currentPriceModel.ID integerValue] classify_id:0 actionType:Refresh  Success:^{
                    [self.tableView reloadData];
                } failure:^{
                    
                }];
            }
    }else{//点击类别
    
        sender.selected = !sender.selected;
        if (self.currentClassifyBtn.tag == sender.tag && !sender.selected) {
//            执行一个类别都不选中
            HCConditionModel * currentPriceModel = self.priceConditionValues[sender.tag-2015];
            self.currentClassifyBtnID = 0;
            [self gotCouponsDataWithPageNum:1 price_id:[currentPriceModel.ID integerValue] classify_id:0 actionType:Refresh  Success:^{
                [self.tableView reloadData];
            } failure:^{
                
            }];
            
        }else{
            self.currentClassifyBtn.selected = NO ;
            sender.selected = YES;
            self.currentClassifyBtn = sender;
            //执行请求操作
            HCConditionModel * currentPriceModel = self.priceConditionValues[self.currentPriceBtn.tag-2015];
            HCConditionModel * currentClassifyModel = self.classifyConditionValues[self.currentClassifyBtn.tag-2015-self.priceConditionValues.count];
            self.currentClassifyBtnID = [currentClassifyModel.ID integerValue];
            [self gotCouponsDataWithPageNum:1 price_id:[currentPriceModel.ID integerValue] classify_id:[currentClassifyModel.ID integerValue] actionType:Refresh  Success:^{
                [self.tableView reloadData];
            } failure:^{
                
            }];
            [self classifyBtnClick:self.classifyButton];
            
        }
        
    }
    
    LOG(@"_%@_%d_%@",[self class] , __LINE__,sender)
}
-(void)clickCover:(UIButton*)sender
{
    [self classifyBtnClick:self.classifyButton];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,self.coupons)
    return self.coupons.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HCCouponCell  * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HCCouponCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    //    cell.textLabel.text=self.stories[indexPath.row];
    //    LaoStoryCellModel * cellModel = [[LaoStoryCellModel alloc]init];
    BaseModel * cellModel = self.coupons[indexPath.row];
//    cell.textLabel.text = cellModel.title;
    cell.couponModel =(HCCouponModel * ) cellModel;
    cell.CouponCellDelegate=self;
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00000000001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000000000000001;
}




-(void  )clickActionInCell:(HCCouponCell*)cell withActionType:(TicketClickAction)actionType {
    //cell的代理方法
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    HCCouponModel * model  = self.coupons[indexPath.row];
    /**
     GotoShop=0,
     GotTicket,
     ShareTicket
     */
    if (actionType==TicketDetail) {
//        CouponsDetailVC
//        BaseModel * CouponsDetailVCModel = [[BaseModel alloc]init];
//        CouponsDetailVCModel.actionKey=@"CouponsDetailVC";
//        [[SkipManager shareSkipManager] skipForLocalByVC:self withActionModel:CouponsDetailVCModel];
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"查看优惠券详情");
        CouponsDetailVC * detailVC = [[CouponsDetailVC alloc ]initWithCouponsID:[NSString stringWithFormat:@"%@",model.ID]];
        [self.navigationController pushViewController:detailVC animated:YES];
        
    }else if (actionType==GotTicket){
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"执行领取优惠券操作");
        cell.couponModel.judge = YES;
        if ([UserInfo shareUserInfo].isLogin) {
            
            [[UserInfo shareUserInfo] gotCouponsWithCouponsID:model.ID success:^(ResponseObject *responseObject) {
                LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject.data)
                model.take = YES;
                cell.getClick.bottomTitleColor = [UIColor whiteColor];
                cell.getClick.topImage = [UIImage imageNamed:@"bg_icon_draw_nor"];
                cell.couponModel=model;
            } failure:^(NSError *error) {
                LOG(@"_%@_%d_%@",[self class] , __LINE__,@"领取失败")
            }];
        }else{
            [[SkipManager shareSkipManager] skipByVC:self withActionModel:cell.couponModel];
//            [[SkipManager shareSkipManager] skipForLocalByVC:self withActionModel:cell.couponModel];
        
        }
    }else if (actionType==ShareTicket){
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"分享优惠券操作");
//        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:@"http://www.baidu.com/img/bdlogo.gif"];
        LOG(@"_%@_%d_%@",[self class] , __LINE__,cell.couponModel.url);
        NSString *imageUrl = [NSString stringWithFormat:@"%@/%@", IMGDOMAIN,cell.couponModel.imgStr];
        [UMSocialData defaultData].extConfig.title = cell.couponModel.coupons_title;
        [UMSocialData defaultData].extConfig.qqData.url = cell.couponModel.url;
        [UMSocialData defaultData].extConfig.wechatSessionData.url=cell.couponModel.url;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url=cell.couponModel.url;
        [UMSocialData defaultData].extConfig.qzoneData.url=cell.couponModel.url;
        [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = [NSString stringWithFormat:@"我在直接捞发现了一个超值的优惠券快来看看吧 :%@",cell.couponModel.coupons_title];
        [UMSocialData defaultData].extConfig.sinaData.shareText = [NSString stringWithFormat:@"我在直接捞发现了一个超值的优惠券快来看看吧 %@ @直接捞 %@",cell.couponModel.coupons_title,cell.couponModel.url];
        [UMSocialData defaultData].extConfig.sinaData.shareText=cell.couponModel.url;
        UIImageView *sharImage = [[UIImageView alloc] init];

        
        [sharImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeImage options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            UIImage *img = [sharImage.image imageByScalingToSize:CGSizeMake(100, 100)];
            [UMSocialData defaultData].extConfig.sinaData.shareImage = img;
            [UMSocialData defaultData].extConfig.wechatTimelineData.shareImage = img;
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"574e769467e58efcc2000937"
                                              shareText:[NSString stringWithFormat:@"我在直接捞发现一个超值的优惠券，快来看看吧"]
                                             shareImage:img
                                        shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ]
                                               delegate:self];
        }];
        
        
    }
    LOG(@"_%@_%d_%ld",[self class] , __LINE__,actionType)
}

/** 友盟的回调方法 */
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        LOG(@"_%@_%d_分享到的平台名->%@",[self class] , __LINE__,[[response.data allKeys] objectAtIndex:0]);
//        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)gotCouponsDataWithPageNum:(NSUInteger)pageNum price_id:(NSUInteger)price_id classify_id:(NSUInteger)classify_id actionType:(LoadDataActionType)actionType Success:(void(^)())success failure:(void(^)())failure
{
    
    LOG(@"_%@_%d_price_id:%lu   classify_id:%lu  pageNumber : %lu",[self class] , __LINE__,price_id , classify_id,pageNum)
    
    [[UserInfo shareUserInfo] gotCouponsDataWithPageNum:pageNum price_id:price_id classify_id:classify_id success:^(ResponseObject *responseObject) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject.data)
        if (responseObject.status<0 && pageNum==1) {
            self.coupons=nil;
            AlertInVC(@"当前价格区间下无优惠券")
            LOG(@"_%@_%d_%@",[self class] , __LINE__,@"当前价格区间下无优惠券");
//            success(responseObject);
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return ;
        }else if (responseObject.status<0){
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return ;
        }
        if ([responseObject.data isKindOfClass:[NSArray class]]) {//保证是数组
            
            for (id sub in responseObject.data) {
                if ([sub isKindOfClass:[NSDictionary class]]) {//保证是字典
                    
                    ////////////// ////////////// ////////////// ////////////// ////////////// //////////////
                    
                    if (actionType==Init) {
                        if ([sub[@"key"] isEqualToString:@"price"]) {//保证是选择条件们所在的字典
                            
                            if (sub[@"items"]) {//保证条件们有值
                                id coupons = sub[@"items"];
                                [self.priceConditionValues removeAllObjects];
                                [self.classifyConditionValues removeAllObjects];
                                [self.totalConditionValues removeAllObjects];
                                for (int i = 0 ; i< [coupons count]; i ++) {
                                    NSDictionary * item = coupons[i];
                                    //                                    LOG(@"_%@_%d_%@",[self class] , __LINE__,item)
                                    
                                    HCConditionModel  * conditionModel = [[HCConditionModel alloc]initWithDict:item];
                                    LOG(@"_%@_%d_%@",[self class] , __LINE__,conditionModel.ID)
                                    
                                    if (i<5) {//价格条件
                                        [self.priceConditionValues addObject:conditionModel];
                                    }else{//类别条件
//                                        [self.classifyConditionValues addObject:conditionModel];//注掉类别
                                    }
                                }
                                
                                [self.totalConditionValues addObjectsFromArray:self.priceConditionValues];
                                [self.totalConditionValues addObjectsFromArray:self.classifyConditionValues];
                            }
                            
                        }
                        
                    }
                    
                    
                    ////////////// ////////////// ////////////// ////////////// ////////////// //////////////
                    if (actionType==Refresh) {
                        [self.coupons removeAllObjects];
                    }
                    if ([sub[@"key"] isEqualToString:@"list"]) {//保证是优惠券们所在的字典
                        
                        if (sub[@"items"]) {//保证优惠券们有值
                            id coupons = sub[@"items"];
                            for (int i = 0 ; i< [coupons count]; i ++) {
                                NSDictionary * item = coupons[i];
                                HCCouponModel * couponModel = [[HCCouponModel alloc]initWithDict:item];
                                [self.coupons addObject:couponModel];
                            }
                        }
                        
                    }
                    
                    
                    ////////////// ////////////// ////////////// ////////////// ////////////// ////////////// //////////////
                    
                    
                    
                }
            }
            
        }
        success();
    } failure:^(NSError *error) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
        
    }];
    
    
    
    
    
}
/** 最早的有类别的数据解析方式 */
//-(void)gotCouponsDataWithPageNum:(NSUInteger)pageNum price_id:(NSUInteger)price_id classify_id:(NSUInteger)classify_id actionType:(LoadDataActionType)actionType Success:(void(^)())success failure:(void(^)())failure
//{
//    
//    LOG(@"_%@_%d_price_id:%lu   classify_id:%lu  pageNumber : %lu",[self class] , __LINE__,price_id , classify_id,pageNum)
//    
//    [[UserInfo shareUserInfo] gotCouponsDataWithPageNum:pageNum price_id:price_id classify_id:classify_id success:^(ResponseObject *responseObject) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject.data)
//        
//        if ([responseObject.data isKindOfClass:[NSArray class]]) {//保证是数组
//            
//            for (id sub in responseObject.data) {
//                if ([sub isKindOfClass:[NSDictionary class]]) {//保证是字典
//                    
//                ////////////// ////////////// ////////////// ////////////// ////////////// //////////////
//                    
//                    if (actionType==Init) {
//                        if ([sub[@"key"] isEqualToString:@"price"]) {//保证是选择条件们所在的字典
//                            
//                            if (sub[@"items"]) {//保证条件们有值
//                                id coupons = sub[@"items"];
//                                [self.priceConditionValues removeAllObjects];
//                                [self.classifyConditionValues removeAllObjects];
//                                [self.totalConditionValues removeAllObjects];
//                                for (int i = 0 ; i< [coupons count]; i ++) {
//                                    NSDictionary * item = coupons[i];
////                                    LOG(@"_%@_%d_%@",[self class] , __LINE__,item)
//                                    
//                                    HCConditionModel  * conditionModel = [[HCConditionModel alloc]initWithDict:item];
//                                    LOG(@"_%@_%d_%@",[self class] , __LINE__,conditionModel.ID)
//
//                                    if (i<5) {//价格条件
//                                        [self.priceConditionValues addObject:conditionModel];
//                                    }else{//类别条件
//                                        [self.classifyConditionValues addObject:conditionModel];
//                                    }
//                                }
//                                
//                                [self.totalConditionValues addObjectsFromArray:self.priceConditionValues];
//                                [self.totalConditionValues addObjectsFromArray:self.classifyConditionValues];
//                            }
//                            
//                        }
//                        
//                    }
//                    
//                    
//                 ////////////// ////////////// ////////////// ////////////// ////////////// //////////////
//                    if (actionType==Refresh) {
//                        [self.coupons removeAllObjects];
//                    }
//                    if ([sub[@"key"] isEqualToString:@"list"]) {//保证是优惠券们所在的字典
//                        
//                        if (sub[@"items"]) {//保证优惠券们有值
//                            id coupons = sub[@"items"];
//                            for (int i = 0 ; i< [coupons count]; i ++) {
//                                NSDictionary * item = coupons[i];
//                                HCCouponModel * couponModel = [[HCCouponModel alloc]initWithDict:item];
//                                [self.coupons addObject:couponModel];
//                            }
//                        }
//                        
//                    }
//                    
//                    
//                 ////////////// ////////////// ////////////// ////////////// ////////////// ////////////// //////////////
//                    
//                    
//                    
//                }
//            }
//            
//        }
//        success();
//    } failure:^(NSError *error) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
//        
//    }];
//    
//    
//    
//    
//
//}

-(NSMutableArray * )priceConditionValues{
    if(_priceConditionValues==nil){
        _priceConditionValues = [NSMutableArray array];// @[@"全部",@"0~20",@"21~50",@"51~100",@"100+"];
    }
    return _priceConditionValues  ;
}
-(NSMutableArray * )classifyConditionValues{
    if(_classifyConditionValues==nil){
        _classifyConditionValues = [NSMutableArray array];//@[@"食品饮料",@"家用电器",@"手机数码",@"服装鞋帽",@"户外运动",@"珠宝箱包",@"家居家纺",@"母婴用品",@"其他"];
    }
    return _classifyConditionValues  ;
}


-(NSMutableArray * )totalConditionValues{
    if(_totalConditionValues==nil){
        NSMutableArray * arrM = [NSMutableArray array];
        [arrM arrayByAddingObjectsFromArray:self.priceConditionValues];
        [arrM arrayByAddingObjectsFromArray:self.classifyConditionValues];
        _totalConditionValues  = arrM;
    }
    return _totalConditionValues;
}

-(NSMutableArray * )conditionKeis{
    if(_conditionKeis==nil){
        NSMutableArray * arrM = [[NSMutableArray alloc]init];
//        for (int i = 0 ;  i< self.totalConditionValues.count; i++) {
//            [arrM addObject:@(i)];
//        }
//        
        _conditionKeis = arrM;
    }
    return _conditionKeis;
}

/** 优惠券们 */
//@property(nonatomic,strong)NSArray * coupons ;
-(NSMutableArray * )coupons{
    if(_coupons==nil){
        NSMutableArray * arrM = [NSMutableArray array];
//        for (int i = 0 ;  i < 16; i++) {
//            BaseModel * model = [[BaseModel alloc]init];
//            model.title = [NSString stringWithFormat:@"%d",i];
//            [arrM addObject:model];
//        }
        _coupons = arrM;
    }
    return _coupons;
}
@end
