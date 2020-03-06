//
//  HAllbuyCell.m
//  b2c
//
//  Created by wangyuanfei on 4/12/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "HAllbuyCell.h"
#import "HAllBuyCollectionCell.h"

@interface HAllbuyCell()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,weak)UIImageView * topImageView ;
@property(nonatomic,weak)UIView * bottomContainer ;
@property(nonatomic,weak)UICollectionView * collectView ;
@end


@implementation HAllbuyCell

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView * topImageView =[[UIImageView alloc]init];
        self.topImageView = topImageView;
        [self.contentView addSubview:self.topImageView];
        //        self.topImageView.backgroundColor = randomColor;
        
        
        
        UIView * container = [[UIView alloc]init];
        self.bottomContainer = container;
        [self.contentView addSubview:container];
        self.bottomContainer.backgroundColor= [UIColor clearColor];
        
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 1;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing=0;
        UICollectionView * collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        //        collectView.backgroundColor = randomColor;
        collectView.dataSource = self;
        collectView.delegate = self;
        //        collectView.userInteractionEnabled=NO;
        //        collectView.scrollEnabled=NO;
        [collectView registerClass:[HAllBuyCollectionCell class] forCellWithReuseIdentifier:@"HAllBuyCollectionCell"];
        //        collectView.pagingEnabled =YES;
        collectView.showsHorizontalScrollIndicator=NO;
        collectView.showsVerticalScrollIndicator=NO;
        
        collectView.backgroundColor = [UIColor clearColor];
        self.collectView = collectView;
        [self.bottomContainer addSubview:collectView];
        
        
        CGFloat topImageViewH = 38*SCALE ;
        CGFloat totalTopMargin = 11*SCALE ;
        CGFloat collectionViewH = 155*SCALE;
        
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
        //
        //
        //        [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.left.bottom.right.top.equalTo(self.bottomContainer);
        //        }];
        
        
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat topImageViewH = 38*SCALE ;
    CGFloat totalTopMargin = 11*SCALE ;
    CGFloat itemMargin = 1 ;
    CGFloat collectionViewH = 155*SCALE;
    
    self.topImageView.frame = CGRectMake(0, totalTopMargin, self.bounds.size.width, topImageViewH) ;
    self.bottomContainer.frame = CGRectMake(0, topImageViewH + itemMargin + totalTopMargin, self.bounds.size.width, collectionViewH);
    self.collectView.frame  = self.bottomContainer.bounds;
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout * ) self.collectView.collectionViewLayout;
    layout.itemSize = CGSizeMake(100*SCALE,self.bottomContainer.bounds.size.height);
    
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{return 1;}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{return self.cellModel.items.count;}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HAllBuyCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HAllBuyCollectionCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        LOG(@"_%d_%@",__LINE__,@"未知错误");
    }
    HCellComposeModel * model =self.cellModel.items[indexPath.item];
    model.keyParamete = @{@"paramete":model.ID};
    //    model.theamColor=[UIColor colorWithRed:242/256.0 green:172/256.0 blue:5/256.0 alpha:1];
    model.theamColor = [UIColor colorWithHexString:[self.cellModel.color stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    model.theamtit = @"热卖";
    cell.composeModel = model;
    //    cell.backgroundColor = randomColor;
    return cell;
}

-(void)setCellModel:(HCellModel *)cellModel{
    [super setCellModel:cellModel];
    if (cellModel.isRefreshImageCached) {
        if ([cellModel.imgStr hasPrefix:@"http"]){
            [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageRefreshCached];
        }else{
            [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageRefreshCached];
        }
    } else {
        if ([cellModel.imgStr hasPrefix:@"http"]){
            [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageRetryFailed];
        }else{
            [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageRetryFailed];
        }
    }
   
    //    [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
    
    //    [self.collectView reloadData];
#pragma mark 初次进入allbuy cell的collection排版有误 , item都重叠到一起  加上下一句尝试解决问题, 有待验证
    [self setNeedsLayout];
    [self layoutIfNeeded];
    //    LOG(@"_%@_%d_%@",[self class] , __LINE__,cellModel.items)
}
@end



























































////
////  HAllbuyCell.m
////  b2c
////
////  Created by wangyuanfei on 4/12/16.
////  Copyright © 2016 www.16lao.com. All rights reserved.
////
//
//#import "HAllbuyCell.h"
//#import "HAllBuyCollectionCell.h"
//
//@interface HAllbuyCell()<UICollectionViewDataSource,UICollectionViewDelegate>
//
//@property(nonatomic,weak)UIImageView * topImageView ;
//@property(nonatomic,weak)UIView * bottomContainer ;
//@property(nonatomic,weak)UICollectionView * collectView ;
//@end
//
//
//@implementation HAllbuyCell
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        UIImageView * topImageView =[[UIImageView alloc]init];
//        self.topImageView = topImageView;
//        [self.contentView addSubview:self.topImageView];
////        self.topImageView.backgroundColor = randomColor;
//        
//        
//        
//        UIView * container = [[UIView alloc]init];
//        self.bottomContainer = container;
//        [self.contentView addSubview:container];
//        self.bottomContainer.backgroundColor= [UIColor clearColor];
//        
//        
//        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
//        layout.minimumLineSpacing = 1;
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        layout.minimumInteritemSpacing=0;
//        UICollectionView * collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
////        collectView.backgroundColor = randomColor;
//        collectView.dataSource = self;
//        collectView.delegate = self;
//        //        collectView.userInteractionEnabled=NO;
////        collectView.scrollEnabled=NO;
//        [collectView registerClass:[HAllBuyCollectionCell class] forCellWithReuseIdentifier:@"HAllBuyCollectionCell"];
////        collectView.pagingEnabled =YES;
//        collectView.showsHorizontalScrollIndicator=NO;
//        collectView.showsVerticalScrollIndicator=NO;
//        
//        collectView.backgroundColor = [UIColor clearColor];
//        self.collectView = collectView;
//        [self.bottomContainer addSubview:collectView];
//        
//        
//        CGFloat topImageViewH = 38*SCALE ;
//        CGFloat totalTopMargin = 11*SCALE ;
//        CGFloat collectionViewH = 155*SCALE;
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
//
//        
//        [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.bottom.right.top.equalTo(self.bottomContainer);
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
//    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout * ) self.collectView.collectionViewLayout;
//    layout.itemSize = CGSizeMake(100*SCALE,self.bottomContainer.bounds.size.height);
//    
//
//}
//
//
//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{return 1;}
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{return self.cellModel.items.count;}
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    HAllBuyCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HAllBuyCollectionCell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
//    if (cell == nil) {
//        LOG(@"_%d_%@",__LINE__,@"未知错误");
//    }
//    HCellComposeModel * model =self.cellModel.items[indexPath.item];
//    model.keyParamete = @{@"paramete":model.ID};
////    model.theamColor=[UIColor colorWithRed:242/256.0 green:172/256.0 blue:5/256.0 alpha:1];
//    model.theamColor = [UIColor colorWithHexString:[self.cellModel.color stringByReplacingOccurrencesOfString:@"#" withString:@""]];
//    model.theamtit = @"热卖";
//    cell.composeModel = model;
////    cell.backgroundColor = randomColor;
//    return cell;
//}
//
//-(void)setCellModel:(HCellModel *)cellModel{
//    [super setCellModel:cellModel];
//    if ([cellModel.imgStr hasPrefix:@"http"]){
//        [self.topImageView sd_setImageWithURL:[NSURL URLWithString:cellModel.imgStr] placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    }else{
//        [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    }
////    [self.topImageView sd_setImageWithURL:ImageUrlWithString(cellModel.imgStr)  placeholderImage:nil options:SDWebImageCacheMemoryOnly];
//    
////    [self.collectView reloadData];
//#pragma mark 初次进入allbuy cell的collection排版有误 , item都重叠到一起  加上下一句尝试解决问题, 有待验证
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
////    LOG(@"_%@_%d_%@",[self class] , __LINE__,cellModel.items)
//}
//@end
