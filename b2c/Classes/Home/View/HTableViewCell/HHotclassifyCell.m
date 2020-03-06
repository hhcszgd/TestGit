//
//  HHotclassifyCell.m
//  b2c
//
//  Created by wangyuanfei on 4/11/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "HHotclassifyCell.h"
#import "HHotclassifyCellCompose.h"

@interface HHotclassifyCell()
@property(nonatomic,weak)UIImageView * topImageView ;
@property(nonatomic,weak)UIView * bottomContainer ;

@end

@implementation HHotclassifyCell

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(CGFloat  )composeH{
    
    //    return  137*SCALE;
    CGFloat leftRightMargin = 1 ;
    return (screenW - leftRightMargin*3)/4;
    
}
//static CGFloat composeH = 166*SCALE;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView * topImageView = [[UIImageView alloc]init];
        self.topImageView = topImageView;
        [self.contentView addSubview:self.topImageView];
        //        self.topImageView.backgroundColor = randomColor;
        
        
        
        UIView * container = [[UIView alloc]init];
        self.bottomContainer = container;
        [self.contentView addSubview:container];
        //        self.bottomContainer.backgroundColor= randomColor;
        
        
        
        
        //        CGFloat topImageViewH = 38*SCALE ;
        //        CGFloat totalTopMargin = 11*SCALE ;
        
        //        [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(self.contentView).offset(totalTopMargin);
        //            make.left.right.equalTo(self.contentView);
        //            make.height.equalTo(@(topImageViewH));
        //        }];
        //
        //
        //        [self.bottomContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.right.equalTo(self.topImageView);
        //            make.top.equalTo(self.topImageView.mas_bottom).offset(1);
        //            make.height.equalTo(@(self.composeH));
        //        }];
        //        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.right.equalTo(self);
        //            make.bottom.equalTo(self.bottomContainer);
        //        }];
        
        
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat leftRightMargin = 1 ;
    CGFloat topImageViewH = 38*SCALE ;
    CGFloat totalTopMargin = 11*SCALE ;
    NSInteger col = 4 ;//列数
    CGFloat subW = (self.bounds.size.width - (col-1)*leftRightMargin)/col;
    CGFloat subH = self.composeH;//固定
    self.topImageView.frame = CGRectMake(0, totalTopMargin, self.bounds.size.width, topImageViewH);
    self.bottomContainer.frame = CGRectMake(0, totalTopMargin+topImageViewH+leftRightMargin, self.bounds.size.width, self.bounds.size.height - (totalTopMargin+topImageViewH+leftRightMargin));
    
    for (int i = 0 ;  i< self.bottomContainer.subviews.count; i++) {
        HHotclassifyCellCompose * sub = self.bottomContainer.subviews[i];
        CGFloat subX = (subW+leftRightMargin)*(i%col);
        CGFloat subY = (leftRightMargin + subH) * (i/col);
        sub.frame = CGRectMake(subX, subY, subW, subH);
    }
    
}
-(void)setCellModel:(HCellModel *)cellModel{
    [super setCellModel:cellModel];
    //#pragma mark 临时切换
    //    NSString * tempStr = @"http://s0.zjlao.com/app_img/hotclassify.png";
    //    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:tempStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    //    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    
    if ([cellModel.imgStr hasPrefix:@"http"]){
        [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    }else{
        [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    }
    
    
    //    [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr) placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    
    if (self.bottomContainer.subviews.count==0) {
        for (int i = 0 ; i< cellModel.items.count; i++) {
            HHotclassifyCellCompose * sub = [[HHotclassifyCellCompose alloc]init];
            sub.backgroundColor=[UIColor whiteColor];
            [sub addTarget:self action:@selector(composeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomContainer addSubview:sub];
        }
    }
    
    for (int k = 0 ; k<cellModel.items.count; k++) {
        HHotclassifyCellCompose * sub = self.bottomContainer.subviews[k];
        //        HCellComposeModel * model =cellModel.items[k];
        //        model.theamColor=[UIColor colorWithRed:65/256.0 green:202/256.0 blue:123/256.0 alpha:1];
        //        model.theamtit=@"包邮";
        sub.composeModel = cellModel.items[k];
    }
    
    //    [self.bottomContainer mas_updateConstraints:^(MASConstraintMaker *make) {
    //        NSUInteger rows = 0 ;
    //        if (cellModel.items.count%4==0) {
    //            rows = cellModel.items.count/4;
    //        }else{
    //            rows = cellModel.items.count/4 +1 ;
    //        }
    //        make.height.equalTo(@(self.composeH*rows));
    //    }];
    
    //    LOG(@"_%@_%d_%@",[self class] , __LINE__,cellModel.items)
}



-(void)composeClick:(HCellBaseComposeView*)sender
{
    if (sender.composeModel) {
        if (sender.composeModel.classify_name) {
            
            sender.composeModel.keyParamete=@{
                                              @"paramete":sender.composeModel.classify_name
                                              };
        }
        
        NSDictionary * pragma = @{
                                  @"HCellComposeViewModel":sender.composeModel
                                  };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HCellComposeViewClick" object:nil userInfo:pragma];
    }
}
@end

























































////
////  HHotclassifyCell.m
////  b2c
////
////  Created by wangyuanfei on 4/11/16.
////  Copyright © 2016 www.16lao.com. All rights reserved.
////
//
//#import "HHotclassifyCell.h"
//#import "HHotclassifyCellCompose.h"
//
//@interface HHotclassifyCell()
//@property(nonatomic,weak)UIImageView * topImageView ;
//@property(nonatomic,weak)UIView * bottomContainer ;
//
//@end
//
//@implementation HHotclassifyCell
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//-(CGFloat  )composeH{
//    
////    return  137*SCALE;
//    CGFloat leftRightMargin = 1 ;
//    return (screenW - leftRightMargin*3)/4;
//
//}
////static CGFloat composeH = 166*SCALE;
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        
//        UIImageView * topImageView = [[UIImageView alloc]init];
//        self.topImageView = topImageView;
//        [self.contentView addSubview:self.topImageView];
//        //        self.topImageView.backgroundColor = randomColor;
//        
//        
//        
//        UIView * container = [[UIView alloc]init];
//        self.bottomContainer = container;
//        [self.contentView addSubview:container];
//        //        self.bottomContainer.backgroundColor= randomColor;
//        
//        
//        
//        
//        CGFloat topImageViewH = 38*SCALE ;
//        CGFloat totalTopMargin = 11*SCALE ;
//        
//        [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.contentView).offset(totalTopMargin);
//            make.left.right.equalTo(self.contentView);
//            make.height.equalTo(@(topImageViewH));
//        }];
//        
//        
//        [self.bottomContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self.topImageView);
//            make.top.equalTo(self.topImageView.mas_bottom).offset(1);
//            make.height.equalTo(@(self.composeH));
//        }];
//        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self);
//            make.bottom.equalTo(self.bottomContainer);
//        }];
//        
//        
//
//    }
//    return self;
//}
//
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    CGFloat leftRightMargin = 1 ;
//    NSInteger col = 4 ;//列数
//    CGFloat subW = (self.bounds.size.width - (col-1)*leftRightMargin)/col;
//    CGFloat subH = self.composeH;//固定
//    
//    for (int i = 0 ;  i< self.bottomContainer.subviews.count; i++) {
//        HHotclassifyCellCompose * sub = self.bottomContainer.subviews[i];
//        CGFloat subX = (subW+leftRightMargin)*(i%col);
//        CGFloat subY = (leftRightMargin + subH) * (i/col);
//        sub.frame = CGRectMake(subX, subY, subW, subH);
//    }
//    
//}
//-(void)setCellModel:(HCellModel *)cellModel{
//    [super setCellModel:cellModel];
////#pragma mark 临时切换
////    NSString * tempStr = @"http://s0.zjlao.com/app_img/hotclassify.png";
////    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:tempStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
////    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    
//    if ([cellModel.imgStr hasPrefix:@"http"]){
//        [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    }else{
//        [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    }
//    
//    
////    [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr) placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    
//    if (self.bottomContainer.subviews.count==0) {
//        for (int i = 0 ; i< cellModel.items.count; i++) {
//            HHotclassifyCellCompose * sub = [[HHotclassifyCellCompose alloc]init];
//            sub.backgroundColor=[UIColor whiteColor];
//            [sub addTarget:self action:@selector(composeClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self.bottomContainer addSubview:sub];
//        }
//    }
//    
//    for (int k = 0 ; k<cellModel.items.count; k++) {
//        HHotclassifyCellCompose * sub = self.bottomContainer.subviews[k];
////        HCellComposeModel * model =cellModel.items[k];
////        model.theamColor=[UIColor colorWithRed:65/256.0 green:202/256.0 blue:123/256.0 alpha:1];
////        model.theamtit=@"包邮";
//        sub.composeModel = cellModel.items[k];
//    }
//    
//    [self.bottomContainer mas_updateConstraints:^(MASConstraintMaker *make) {
//        NSUInteger rows = 0 ;
//        if (cellModel.items.count%4==0) {
//            rows = cellModel.items.count/4;
//        }else{
//            rows = cellModel.items.count/4 +1 ;
//        }
//        make.height.equalTo(@(self.composeH*rows));
//    }];
//
////    LOG(@"_%@_%d_%@",[self class] , __LINE__,cellModel.items)
//}
//
//
//
//-(void)composeClick:(HCellBaseComposeView*)sender
//{
//    if (sender.composeModel) {
//        if (sender.composeModel.classify_name) {
//            
//            sender.composeModel.keyParamete=@{
//                                              @"paramete":sender.composeModel.classify_name
//                                              };
//        }
//        
//        NSDictionary * pragma = @{
//                                  @"HCellComposeViewModel":sender.composeModel
//                                  };
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"HCellComposeViewClick" object:nil userInfo:pragma];
//    }
//}
//@end
