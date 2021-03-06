//
//  HGoodshopCell.m
//  b2c
//
//  Created by wangyuanfei on 4/11/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "HGoodshopCell.h"
#import "HGoodshopCellCompose.h"

@interface HGoodshopCell()
@property(nonatomic,weak)UIImageView * topImageView ;
@property(nonatomic,weak)UIView * bottomContainer ;

@end

@implementation HGoodshopCell

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView * topImageView = [[UIImageView alloc]init];
        self.topImageView = topImageView;
        [self.contentView addSubview:self.topImageView];
        //        self.topImageView.backgroundColor = randomColor;
        
        
        
        UIView * container = [[UIView alloc]init];
        self.bottomContainer = container;
        [self.contentView addSubview:container];

    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat leftRightMargin = 1 ;
    
    
    CGFloat topImageViewH = 38*SCALE ;
    CGFloat totalTopMargin = 11*SCALE ;
    //        CGFloat collectionViewH = 146*SCALE;
    CGFloat shopNameH = [UIFont systemFontOfSize:16].lineHeight ;
    CGFloat collectionViewH = (screenW - 2*1)/3 * 0.5  + shopNameH;
    self.topImageView.frame = CGRectMake(0, totalTopMargin, self.bounds.size.width, topImageViewH);
    self.bottomContainer.frame = CGRectMake(0, totalTopMargin+topImageViewH+leftRightMargin, self.bounds.size.width, self.bounds.size.height - (totalTopMargin+topImageViewH+leftRightMargin) );
    
    //    CGFloat subW = (self.bounds.size.width - (self.bottomContainer.subviews.count-1)*leftRightMargin)/self.bottomContainer.subviews.count;
    CGFloat subW = (self.bounds.size.width - 2*leftRightMargin)/3;
    CGFloat subH = self.bottomContainer.bounds.size.height;
    
    for (int i = 0 ;  i< self.bottomContainer.subviews.count; i++) {
        HGoodshopCellCompose * sub = self.bottomContainer.subviews[i];
        CGFloat subX = (subW+leftRightMargin)*i;
        CGFloat subY = 0;
        sub.frame = CGRectMake(subX, subY, subW, subH);
    }
    
}
-(void)setCellModel:(HCellModel *)cellModel{
    [super setCellModel:cellModel];
    
    //    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    if ([cellModel.imgStr hasPrefix:@"http"]){
        [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    }else{
        [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    }
    //    [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr) placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    if (self.bottomContainer.subviews.count==0) {
        for (int i = 0 ; i< cellModel.items.count; i++) {
#pragma mark 为了限制显示个数 , 临时加的限制
            if (i>2) {
                break;
            }
            HGoodshopCellCompose * sub = [[HGoodshopCellCompose alloc]init];
            sub.backgroundColor=[UIColor whiteColor];
            [sub addTarget:self action:@selector(composeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomContainer addSubview:sub];
        }
    }
    
    for (int k = 0 ; k<cellModel.items.count; k++) {
        if (k>2) {
            break;
        }
        HGoodshopCellCompose * sub = self.bottomContainer.subviews[k];
        HCellComposeModel * model =cellModel.items[k];
        if (!model.ID) return;
        model.keyParamete=@{@"paramete":model.ID};
        //        model.theamColor=[UIColor colorWithRed:165/256.0 green:67/256.0 blue:240/256.0 alpha:1];
        model.theamColor = [UIColor colorWithHexString:[cellModel.color stringByReplacingOccurrencesOfString:@"#" withString:@""]];
        //        model.theamtit=@"包邮";
        sub.composeModel = cellModel.items[k];
    }
    
    
    
    //    LOG(@"_%@_%d_%@",[self class] , __LINE__,cellModel.items)
}
@end






























































////
////  HGoodshopCell.m
////  b2c
////
////  Created by wangyuanfei on 4/11/16.
////  Copyright © 2016 www.16lao.com. All rights reserved.
////
//
//#import "HGoodshopCell.h"
//#import "HGoodshopCellCompose.h"
//
//@interface HGoodshopCell()
//@property(nonatomic,weak)UIImageView * topImageView ;
//@property(nonatomic,weak)UIView * bottomContainer ;
//
//@end
//
//@implementation HGoodshopCell
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
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
////        CGFloat collectionViewH = 146*SCALE;
//        CGFloat shopNameH = [UIFont systemFontOfSize:16].lineHeight ;
//        CGFloat collectionViewH = (screenW - 2*1)/3 * 0.5  + shopNameH;
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
//            make.height.equalTo(@(collectionViewH));
//        }];
//        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self);
//            make.bottom.equalTo(self.bottomContainer);
//        }];
//    }
//    return self;
//}
//
//
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    CGFloat leftRightMargin = 1 ;
////    CGFloat subW = (self.bounds.size.width - (self.bottomContainer.subviews.count-1)*leftRightMargin)/self.bottomContainer.subviews.count;
//    CGFloat subW = (self.bounds.size.width - 2*leftRightMargin)/3;
//    CGFloat subH = self.bottomContainer.bounds.size.height;
//    
//    for (int i = 0 ;  i< self.bottomContainer.subviews.count; i++) {
//        HGoodshopCellCompose * sub = self.bottomContainer.subviews[i];
//        CGFloat subX = (subW+leftRightMargin)*i;
//        CGFloat subY = 0;
//        sub.frame = CGRectMake(subX, subY, subW, subH);
//    }
//    
//}
//-(void)setCellModel:(HCellModel *)cellModel{
//    [super setCellModel:cellModel];
//    
////    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    if ([cellModel.imgStr hasPrefix:@"http"]){
//        [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    }else{
//        [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    }
////    [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr) placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    if (self.bottomContainer.subviews.count==0) {
//        for (int i = 0 ; i< cellModel.items.count; i++) {
//#pragma mark 为了限制显示个数 , 临时加的限制
//            if (i>2) {
//                break;
//            }
//            HGoodshopCellCompose * sub = [[HGoodshopCellCompose alloc]init];
//            sub.backgroundColor=[UIColor whiteColor];
//            [sub addTarget:self action:@selector(composeClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self.bottomContainer addSubview:sub];
//        }
//    }
//    
//    for (int k = 0 ; k<cellModel.items.count; k++) {
//        if (k>2) {
//            break;
//        }
//        HGoodshopCellCompose * sub = self.bottomContainer.subviews[k];
//        HCellComposeModel * model =cellModel.items[k];
//        if (!model.ID) return;
//        model.keyParamete=@{@"paramete":model.ID};
////        model.theamColor=[UIColor colorWithRed:165/256.0 green:67/256.0 blue:240/256.0 alpha:1];
//        model.theamColor = [UIColor colorWithHexString:[cellModel.color stringByReplacingOccurrencesOfString:@"#" withString:@""]];
////        model.theamtit=@"包邮";
//        sub.composeModel = cellModel.items[k];
//    }
//
//    
//    
////    LOG(@"_%@_%d_%@",[self class] , __LINE__,cellModel.items)
//}
//@end
