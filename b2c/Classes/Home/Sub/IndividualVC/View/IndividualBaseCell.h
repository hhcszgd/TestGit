//
//  IndividualBaseCell.h
//  b2c
//
//  Created by wangyuanfei on 16/5/5.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "BaseCell.h"
#import "HCellComposeModel.h"
#import "HCellModel.h"
@class HCellBaseComposeView;
@interface IndividualBaseCell : BaseCell


@property(nonatomic,strong)HCellModel * cellModel ;
-(void)composeClick:(HCellBaseComposeView*)sender;


@end