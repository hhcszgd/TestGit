//
//  COrderGoodsPriceCell.m
//  b2c
//
//  Created by 0 on 16/5/24.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "COrderGoodsPriceCell.h"
@interface COrderGoodsPriceCell()
@property (nonatomic, strong) UILabel *normalTitle;
@property (nonatomic, strong) UILabel *normalValue;
@end
@implementation COrderGoodsPriceCell
- (UILabel *)normalTitle{
    if (_normalTitle == nil) {
        _normalTitle = [[UILabel alloc] init];
        [self.contentView addSubview:_normalTitle];
        [_normalTitle configmentfont:[UIFont systemFontOfSize:15 *zkqScale] textColor:[UIColor colorWithHexString:@"333333"] backColor:[UIColor whiteColor] textAligement:0 cornerRadius:0 text:@""];
        [_normalTitle sizeToFit];
    }
    return _normalTitle;
}
- (UILabel *)normalValue{
    if (_normalValue == nil) {
        _normalValue = [[UILabel alloc] init];
        [self.contentView addSubview:_normalValue];
        [_normalValue configmentfont:[UIFont systemFontOfSize:13 * zkqScale] textColor:THEMECOLOR backColor:[UIColor whiteColor] textAligement:0 cornerRadius:0 text:@""];
        [_normalValue sizeToFit];
    }
    return _normalValue;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.normalTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.top.equalTo(self.contentView.mas_top).offset(15);
        }];
        [self.normalValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.normalTitle);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
        }];
        UIView *lineView = [[UIView alloc] init];
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.normalTitle.mas_bottom).offset(1);
            make.width.equalTo(@(screenW));
            make.left.right.equalTo(self.contentView);
            make.height.equalTo(@(1));
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

- (void)setNorMalModel:(COrderNormalModel *)norMalModel{
    self.normalTitle.text = norMalModel.title;
    self.normalValue.text = [NSString stringWithFormat:@"￥%@",dealPrice(norMalModel.subtitle)];
}





@end