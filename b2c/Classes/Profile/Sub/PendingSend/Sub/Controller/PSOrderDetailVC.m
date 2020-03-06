//
//  PSOrderDetailVC.m
//  b2c
//
//  Created by 0 on 16/4/14.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "PSOrderDetailVC.h"
#import "PSOrderDetailGoodsCell.h"
#import "PSOrderDetailStateCell.h"
#import "PSORefundVC.h"
#import "TotalOrderRefreshHeader.h"
#import "TotalOrderRefreshAutoFooter.h"
@interface PSOrderDetailVC ()<refundDelegate>
/**数据源数组*/
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation PSOrderDetailVC
- (NSMutableArray *)dataArr{
    if (_dataArr== nil) {
        _dataArr = [[NSMutableArray alloc] init];
        
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = @[@{@"orderState":@(orderStatusRemindSellerShip),@"backGroundImageStr":@"gwxq_product_header",@"reasonStr":@""},
                     @{@"receiptName":@"张凯强",@"receiptPhone":@"18614079684",@"receiptAddress":@"北京 北京市 丰台区，航丰路1号时代财富天地2015室"},
                     @{@"storeLogoImage":@"icon_coupon",@"storeName":@"御泥坊 官方旗舰店",@"goodsDetail":@[@{@"orderState":@(orderStatusRemindSellerShip),@"goodImage":@"zhekouqu",@"goodTitle":@"加减法了；按付款就爱上了咖啡就卡机的房间萨克；的积分卡机的咖啡机阿卡卡的减肥",@"priceLabel":@"99.00",@"countLabel":@"X1"},@{@"orderState":@(orderStatusRemindSellerShip),@"goodImage":@"zhekouqu",@"goodTitle":@"加减法了；按付款就爱上了咖啡就卡机的房间萨克；的积分卡机的咖啡机阿卡卡的减肥",@"priceLabel":@"99.00",@"countLabel":@"X1"}],@"freightLabel":@"0.00",@"realPaymentLabel":@"$99.00"},
                     @{@"sellerUrl":@"卖家的通讯地址"}];
    for (NSDictionary *dic in arr) {
        OrderDetailModel *orderModel = [OrderDetailModel mj_objectWithKeyValues:dic];
        [self.dataArr addObject:orderModel];
    }
    
    
    [self configmentTable];
    
    [self configmentRemindView];
    
    
    
    // Do any additional setup after loading the view.
}

#pragma mark -- 布局提醒发货按钮
- (void)configmentRemindView{
    UIView *remindView = [[UIView alloc] init];
    [self.view addSubview:remindView];
    [remindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.table.mas_bottom).offset(0);
        make.left.bottom.right.equalTo(self.view);
    }];
    remindView.backgroundColor = BackgroundGray;
    
    UILabel *remindLabel= [[UILabel alloc] init];
    [remindView addSubview:remindLabel];
    [remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(remindView);
        make.right.equalTo(remindView).offset(-20);
         make.width.equalTo(@(60));
        make.height.equalTo(@(30));
    }];
    [remindLabel configmentfont:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor] backColor:[UIColor whiteColor] textAligement:1 cornerRadius:6 text:@"提醒发货"];
    remindLabel.layer.borderColor = [[UIColor redColor] CGColor];
    remindLabel.layer.borderWidth = 1;
    UITapGestureRecognizer *remindTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remindTap:)];
    [remindLabel addGestureRecognizer:remindTap];
    remindLabel.userInteractionEnabled = YES;
}
#pragma mark -- 提醒发货方法
- (void)remindTap:(UITapGestureRecognizer *)remindTap{
    LOG(@"%@,%d,%@",[self class], __LINE__,@"提醒发货")
}

- (void)configmentTable{
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.backgroundColor = [UIColor whiteColor];
    self.table.rowHeight = UITableViewAutomaticDimension;
    self.table.estimatedRowHeight = 80;
    self.table.showsVerticalScrollIndicator = NO;
    [self.table registerClass:[OrderDeatilReceiptAddresCell class] forCellReuseIdentifier:@"OrderDeatilReceiptAddresCell"];
    [self.table registerClass:[PSOrderDetailStateCell class] forCellReuseIdentifier:@"PSOrderDetailStateCell"];
    [self.table registerClass:[PSOrderDetailGoodsCell class] forCellReuseIdentifier:@"PSOrderDetailGoodsCell"];
    [self.table registerClass:[OrderDetailContactSeller class] forCellReuseIdentifier:@"OrderDetailContactSeller"];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.frame = CGRectMake(0, self.startY, screenW, screenH - self.startY - 50);
    
    
    TotalOrderRefreshHeader *refreashHeader = [TotalOrderRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeader)];
    self.table.mj_header = refreashHeader;
    
    TotalOrderRefreshAutoFooter *refreashFooter = [TotalOrderRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
    self.table.mj_footer = refreashFooter;
}


/**下拉刷新*/
- (void)refreshHeader{
    [self.table.mj_header endRefreshing];
    
    
}
/**上拉刷新*/
- (void)refreshFooter{
    
    [self.table.mj_footer endRefreshing];
    
    
   
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        OrderDetailModel *model = self.dataArr[section];
        return model.goodsDetail.count;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
   
    OrderDetailModel *orderDetailModel = self.dataArr[indexPath.section];
    switch (indexPath.section) {
        case 0:
        {
            PSOrderDetailStateCell *stateCell = [tableView dequeueReusableCellWithIdentifier:@"PSOrderDetailStateCell" forIndexPath:indexPath];
            
            stateCell.orderTailModel = orderDetailModel;
            cell = stateCell;
        }
            break;
        case 1:
        {
            OrderDeatilReceiptAddresCell *addressCell = [tableView dequeueReusableCellWithIdentifier:@"OrderDeatilReceiptAddresCell" forIndexPath:indexPath];
            addressCell.orderTailModel = orderDetailModel;
            cell = addressCell;
        }
            break;
        case 2:
        {
            PSOrderDetailGoodsCell *goodCell = [tableView dequeueReusableCellWithIdentifier:@"PSOrderDetailGoodsCell" forIndexPath:indexPath];
            NSArray *arr = orderDetailModel.goodsDetail;
            goodCell.orderTailModel = arr[indexPath.row];
            if ((orderDetailModel.goodsDetail.count - 1) != indexPath.row) {
                goodCell.lineView.backgroundColor = [UIColor whiteColor];
            }else{
                goodCell.lineView.backgroundColor = BackgroundGray;
            }
            goodCell.delegate = self;
            cell = goodCell;
        }
            break;
        case 3:
        {
            OrderDetailContactSeller *contactCell = [tableView dequeueReusableCellWithIdentifier:@"OrderDetailContactSeller" forIndexPath:indexPath];
            cell = contactCell;
        }
            break;
            
            
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 40;
    }
    if (section == 4) {
        return 40;
    }
    return 0.00001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80;
    }
    return 0.00001;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        OrderDetailHeader *header = [[OrderDetailHeader alloc] initWithReuseIdentifier:@"OrderDetailHeader"];
        header.orderDetailModel = self.dataArr[section];
        header.delegate = self;
        return header;
    }
    
    
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        OrderDeatilFooter *footer = [[OrderDeatilFooter alloc] initWithReuseIdentifier:@"OrderDeatilFooter"];
        footer.orderDetailModel = self.dataArr[section];
        return footer;
    }
    return nil;
}

/**点击头部，跳转到商品详情页面*/
- (void)actionToSotreDetail{
    LOG(@"%@,%d,%@",[self class], __LINE__,@"跳转到商品店铺")
//    [[SkipManager shareSkipManager] skipByVC:self urlStr:nil title:nil action:@"HStoreDetailsVC"];
}
- (void)refundModel:(OrderDetailModel *)orderDetailModel{
    
    PSORefundVC *refundVC = [[PSORefundVC alloc] init];
    refundVC.orderDetailModel = orderDetailModel;
    [self.navigationController pushViewController:refundVC animated:YES];
}



@end
