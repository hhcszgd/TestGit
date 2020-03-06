//
//  HStoreStoryCell.m
//  b2c
//
//  Created by 0 on 16/4/1.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "HStoreStoryCell.h"
#import "HStoreStoryModel.h"
@interface HStoreStoryCell()
/**故事标题*/
@property (nonatomic, strong) UILabel *titleLabel;
/**故事浏览量*/
@property (nonatomic, strong) UILabel *scanLabel;
/**发布时间*/
@property (nonatomic, strong) UILabel *timeLabel;
/**浏览图片*/
@property (nonatomic, strong) UIImageView *scanImage;

@property (nonatomic, strong) HStoreStoryModel *saveModel;
@end
@implementation HStoreStoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel configmentfont:[UIFont systemFontOfSize:12 * zkqScale] textColor:[UIColor colorWithHexString:@"999999"] backColor:[UIColor colorWithHexString:@"ffffff"] textAligement:0 cornerRadius:0 text:@""];
        [_timeLabel sizeToFit];
    }
    return _timeLabel;
}
- (UILabel *)scanLabel{
    if (_scanLabel == nil) {
        _scanLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_scanLabel];
        [_timeLabel configmentfont:[UIFont systemFontOfSize:12 * zkqScale] textColor:[UIColor colorWithHexString:@"999999"] backColor:[UIColor colorWithHexString:@"ffffff"] textAligement:1 cornerRadius:0 text:@""];
        [_scanLabel sizeToFit];
    }
    return _scanLabel;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel  =[[UILabel alloc] init];
        [self.contentView addSubview:_titleLabel];
        [_timeLabel configmentfont:[UIFont systemFontOfSize:15 * zkqScale] textColor:[UIColor colorWithHexString:@"666666"] backColor:[UIColor colorWithHexString:@"ffffff"] textAligement:0 cornerRadius:0 text:@""];
    }
    return _titleLabel;
}
- (UIImageView *)scanImage{
    if (_scanImage == nil) {
        _scanImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_scanImage];
        _scanImage.image = [UIImage imageNamed:@"icon_eye"];

    }
    return _scanImage;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.width.equalTo(@(200 * SCALE));
        }];
        [self.scanImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
            make.width.equalTo(@(18.5));
            make.height.equalTo(@(12));
        }];
        
        [self.scanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.scanImage.mas_right).offset(10);
            make.width.equalTo(@(40));
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            
        }];
        
    }
    return self;
}
- (void)setStoreModel:(HStoreStoryModel *)storeModel{
    NSRange startRange = [storeModel.create_at rangeOfString:@" "];
    NSString * startTime = [storeModel.create_at substringToIndex:startRange.location];
    LOG(@"%@,%d,%@",[self class], __LINE__,NSStringFromRange(startRange))
    self.saveModel = storeModel;
    self.timeLabel.text = startTime;
    self.scanLabel.text = storeModel.hot;
    self.titleLabel.text = storeModel.title;
}

@end
