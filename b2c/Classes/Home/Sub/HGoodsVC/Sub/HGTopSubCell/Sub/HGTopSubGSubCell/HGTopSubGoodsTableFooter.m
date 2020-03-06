//
//  HGTopSubGoodsTableFooter.m
//  b2c
//
//  Created by 0 on 16/5/9.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "HGTopSubGoodsTableFooter.h"
@implementation HGTopSubGoodsTableFooter
- (UIView *)leftView{
    if (_leftView == nil) {
        _leftView = [[UIView alloc] init];
        [self addSubview:_leftView];
        [_leftView setBackgroundColor:[UIColor colorWithHexString:@"999999"]];
    }
    return _leftView;
}
- (UIView *)rightView{
    if (_rightView == nil) {
        _rightView = [[UIView alloc] init];
        [self addSubview:_rightView];
        _rightView.backgroundColor = [UIColor colorWithHexString:@"999999"];
    }
    return _rightView;
}
- (UILabel *)label{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        [self addSubview:_label];
        [_label sizeToFit];
        [_label configmentfont:[UIFont systemFontOfSize:12 *SCALE] textColor:[UIColor colorWithHexString:@"999999"] backColor:[UIColor clearColor] textAligement:1 cornerRadius:0 text:@"继续拖动，查看图文详情"];
    }
    return _label;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self);
            
        }];
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.label.mas_left).offset(-10);
            make.centerY.equalTo(self);
            make.width.equalTo(@(50 *SCALE));
            make.height.equalTo(@(0.5 * SCALE));
        }];
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.label.mas_right).offset(10);
            make.centerY.equalTo(self);
            make.width.equalTo(@(50 * SCALE));
            make.height.equalTo(@(0.5 * SCALE));
            
        }];
    }
    return self;
}


@end