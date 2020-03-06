//
//  CONormalCompose.m
//  b2c
//
//  Created by wangyuanfei on 16/4/28.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

#import "CONormalCompose.h"

#import "ConfirmOrderNormalCellModel.h"
@interface CONormalCompose ()

/**
 @property(nonatomic,copy)NSString * leftTitle ;
 @property(nonatomic,copy)NSString * rightTitle ;
 @property(nonatomic,assign)BOOL showArrow ;
 @property(nonatomic,strong)UIColor * rightTitleColor ;
 */
@property(nonatomic,weak)UILabel * leftLabel  ;
@property(nonatomic,weak)UILabel * rightLabel ;
@property(nonatomic,weak)UIImageView * arrow ;
@property(nonatomic,weak)UIView * bottomLine ;
//@property(nonatomic,<#copy?assign?weak?strong#>)<#class#> <#*#> <#name#> ;
@end

@implementation CONormalCompose
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UILabel * leftLabel = [[UILabel alloc]init];
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = MainTextColor;
        self.leftLabel = leftLabel ;
        [self addSubview:leftLabel];
        
        
        UILabel *  rightLabel = [[UILabel alloc]init];
        self.rightLabel=rightLabel;
        rightLabel.textColor = MainTextColor;
        rightLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:rightLabel];
        rightLabel.textAlignment = NSTextAlignmentRight;
        
        UIImageView * arrow  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"jiantou"] ];
        [self addSubview:arrow];
        self.arrow = arrow;
        
        UIView * bottomLine = [[UIView alloc]init];
        self.bottomLine = bottomLine;
        [self addSubview:bottomLine];
        bottomLine.backgroundColor = BackgroundGray;
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat margin = 10 ;
    CGFloat arrowW = 8 ;
    CGFloat arrowH = 14 ;
    CGFloat arrowX = self.bounds.size.width - margin - arrowW  ;
    CGFloat arrowY = (self.bounds.size.height- arrowH )/2  ;
    self.arrow.frame = CGRectMake(arrowX, arrowY, arrowW, arrowH);
    
    CGFloat leftTitleW =  (self.bounds.size.width - 2 * margin) /2 ;
    CGFloat leftTitleH =  self.bounds.size.height ;
    CGFloat leftTitleX =  margin ;
    CGFloat leftTitleY =  0 ;
    self.leftLabel.frame = CGRectMake(leftTitleX, leftTitleY, leftTitleW, leftTitleH);
    
    CGFloat rightW =  leftTitleW - arrowW - margin;
    CGFloat rightH = self.bounds.size.height ;
    CGFloat rightX =  CGRectGetMaxX(self.leftLabel.frame);
    CGFloat rightY = 0 ;
    self.rightLabel.frame = CGRectMake(rightX, rightY, rightW, rightH);
    
    self.bottomLine.frame = CGRectMake(margin, self.bounds.size.height-1, self.bounds.size.width - margin*2, 1);

    self.arrow.hidden = !self.showArrow;
}
-(void)setLeftTitle:(NSString *)leftTitle{
    _leftTitle = leftTitle;
    _leftLabel.text = leftTitle;
}
-(void)setRightTitle:(NSString *)rightTitle{
    _rightTitle = rightTitle;
    _rightLabel.text = rightTitle;
}
-(void)setShowArrow:(BOOL)showArrow{
    _showArrow = showArrow;
    self.arrow.hidden = !showArrow;
}
-(void)setRightTitleColor:(UIColor *)rightTitleColor{
    _rightTitleColor = rightTitleColor;
    self.rightLabel.textColor = rightTitleColor;
}
-(void)setNormalCellModel:(ConfirmOrderNormalCellModel *)normalCellModel{
    _normalCellModel   =   normalCellModel;
    if (normalCellModel.title.length> 0 ) {
        self.leftTitle = normalCellModel.title;
    }
//    if (normalCellModel.subtitle.length>0) {
    if ([normalCellModel.channel isEqualToString:@"Lcoin"]) {
            if ([normalCellModel.subtitle integerValue]>0) {
                self.rightTitle = @"可用";
                normalCellModel.showArrow=YES;
            }else{
                self.rightTitle = @"不可用";
                   normalCellModel.showArrow=NO;
            }
            
    }else if ([normalCellModel.channel isEqualToString:@"coupon"]){
            if (normalCellModel.items.count>0) {
                self.rightTitle = @"可用";
                  normalCellModel.showArrow=YES;
            }else{
                self.rightTitle=@"不可用";
                  normalCellModel.showArrow=NO;
            }
    }else if ([normalCellModel.channel isEqualToString:@"money"]){
            self.rightTitle = [NSString stringWithFormat:@"¥%@",normalCellModel.subtitle ];
    }else if ([normalCellModel.channel isEqualToString:@"freight"]){
            self.rightTitle = [NSString stringWithFormat:@"¥%@",normalCellModel.subtitle ];
    }else if ([normalCellModel.channel isEqualToString:@"taxes"]){
        NSInteger taxesPrice = normalCellModel.subtitle.integerValue;
        if (taxesPrice > 0) {
            
            self.rightTitle = [NSString stringWithFormat:@"¥%@",normalCellModel.subtitle ];
        }else{
            self.rightTitle = @"免税费";
        }
    }else{
            self.rightTitle = normalCellModel.subtitle;
        
    }
    if ([normalCellModel.channel isEqualToString:@"invoice"]) {
        self.bottomLine.hidden = YES;
    }
    if (!normalCellModel.channel) {
        self.bottomLine.hidden = YES;
    }
//    }
    if (normalCellModel.rightTitleColor) {
        self.rightTitleColor = normalCellModel.rightTitleColor;
    }
    self.showArrow = normalCellModel.showArrow;

    
}
@end
