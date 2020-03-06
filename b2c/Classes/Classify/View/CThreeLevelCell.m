//
//  CThreeLevelCell.m
//  b2c
//
//  Created by 0 on 16/4/22.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "CThreeLevelCell.h"
@interface CThreeLevelCell()
@property (nonatomic, strong) UIImageView *classImage;
@property (nonatomic, strong) UILabel *classTitle;
@end
@implementation CThreeLevelCell
- (UIImageView *)classImage{
    if (_classImage == nil) {
        _classImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_classImage];
    }
    return _classImage;
}
- (UILabel *)classTitle{
    if (_classTitle == nil) {
        _classTitle = [[UILabel alloc] init];
        [_classTitle configmentfont:[UIFont systemFontOfSize:12] textColor:[UIColor colorWithHexString:threeLevelTextColor] backColor:[UIColor clearColor] textAligement:1 cornerRadius:0 text:@""];
        [_classTitle sizeToFit];
        [self.contentView addSubview:_classTitle];
    }
    return _classTitle;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.classImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(3);
            make.left.equalTo(self.contentView.mas_left).offset(3);
            make.right.equalTo(self.contentView.mas_right).offset(-3);
            make.height.equalTo(self.classImage.mas_width);
        }];
        self.classImage.backgroundColor = [UIColor whiteColor];
        [self.classTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.classImage.mas_bottom).offset(0);
            make.left.equalTo(self.contentView.mas_left).offset(5);
            make.right.equalTo(self.contentView.mas_right).offset(-5);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        }];
        
        
    }
    return self;
}

- (void)setLevelModel:(ClassifyTwoThreelevelModel *)levelModel{
    

    NSURL *url = ImageUrlWithString(levelModel.img);
    [self.classImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"accountBiiMap"] options:SDWebImageCacheMemoryOnly | SDWebImageRetryFailed];
    self.classTitle.text = levelModel.classify_name;
}


@end