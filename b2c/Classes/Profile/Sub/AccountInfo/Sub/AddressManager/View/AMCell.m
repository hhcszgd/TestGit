
//
//  AMCell.m
//  TTmall
//
//  Created by wangyuanfei on 3/3/16.
//  Copyright © 2016 Footway tech. All rights reserved.
//

#import "AMCell.h"
#import "AMCellModel.h"

@interface AMCell ()
/** 上部控件容器视图 */
@property(nonatomic,weak)UIView * topContainerView ;
/** 展示姓名的label */
@property(nonatomic,weak)UILabel * nameLabel ;
/** 显示手机号码的label */
@property(nonatomic,weak)UILabel * phoneNumberLabel ;
/** 是否是默认地址的标志 */
@property(nonatomic,weak)UILabel * defaultTag ;
/** 高度动态变化的详细地址 */
@property(nonatomic,weak)UILabel * areaLabel ;
/** 底部控件的容器视图 */
@property(nonatomic,weak)UIView * bottomContainerView ;
/** 中间分割线 */
@property(nonatomic,weak)UIView * midSeparate ;
/** 设置为默认地址的文字提示 */
@property(nonatomic,weak)UILabel * setDefaultLabel ;
/** 设置为默认地址的点击按钮 */
@property(nonatomic,weak)UIButton * setDefaultButton ;
/** 编辑按钮 */
@property(nonatomic,weak)UIButton * editButton ;
/** 删除按钮 */
@property(nonatomic,weak)UIButton * deleteButton ;
/** 底部分割线 */
@property(nonatomic,weak)UIView * bottomSeparate ;
/** 是否为默认地址 */
@property(nonatomic,assign)BOOL  isDefaultAddress ;

@end

@implementation AMCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor=[UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self setupSubviews];
        [self layoutMySubview];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

-(void)setupSubviews
{
    UIView * topContainerView = [[UIView alloc]init];
    self.topContainerView=topContainerView;
    //    self.topContainerView.backgroundColor=randomColor;
    [self.contentView addSubview:self.topContainerView];
    UILabel * nameLabel = [[UILabel alloc]init];
    self.nameLabel=nameLabel;
    self.nameLabel.font=[UIFont systemFontOfSize:16];
    [self.topContainerView addSubview:self.nameLabel];
    UILabel * phoneNumberLabel = [[UILabel alloc]init];
    self.phoneNumberLabel=phoneNumberLabel;
    self.phoneNumberLabel.font=[UIFont systemFontOfSize:16];
    [self.topContainerView addSubview:self.phoneNumberLabel];
    UILabel * defaultTag = [[UILabel alloc]init];
    self.defaultTag= defaultTag;
    [self.topContainerView addSubview:self.defaultTag];
    self.defaultTag.text=@"默认地址";
    self.defaultTag.font=[UIFont systemFontOfSize:12];
    self.defaultTag.textColor=[UIColor redColor];
    
    UILabel * areaLabel = [[UILabel alloc]init];
    self.areaLabel = areaLabel;
    self.areaLabel.font=[UIFont systemFontOfSize:15];
    //    self.areaLabel.backgroundColor=randomColor;
    self.areaLabel.textColor=[UIColor grayColor];
    [self.contentView addSubview:self.areaLabel];
    self.areaLabel.numberOfLines=3;
    
    UIView * bottomContainer = [[UIView alloc]init];
    self.bottomContainerView= bottomContainer;
    //    self.bottomContainerView.backgroundColor=randomColor;
    [self.contentView addSubview:self.bottomContainerView];
    UIView * midSeparare = [[UIView alloc]init ] ;
    self.midSeparate = midSeparare;
    self.midSeparate.backgroundColor=BackgroundGray;
    [self.bottomContainerView addSubview:self.midSeparate];
    UIButton * setDefaultButton = [[UIButton alloc]init];
    self.setDefaultButton= setDefaultButton;
    [self.setDefaultButton addTarget:self action:@selector(setDefaultButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.setDefaultButton setImage:[UIImage imageNamed:@"collect_item_not_selected"] forState:UIControlStateNormal];
    [self.setDefaultButton setImage:[UIImage imageNamed:@"collect_item_selected"] forState:UIControlStateSelected];
    //    self.setDefaultButton.backgroundColor=randomColor;
    [self.bottomContainerView addSubview:self.setDefaultButton];
    UILabel * setDefaultLabel = [[UILabel alloc]init];
    self.setDefaultLabel=setDefaultLabel;
    self.setDefaultLabel.text=@"默认地址";
    [self.setDefaultLabel setTextColor:[UIColor darkGrayColor]];
    self.setDefaultLabel.font=[UIFont systemFontOfSize:12];
    //    self.setDefaultLabel.backgroundColor=randomColor;
    [self.bottomContainerView addSubview:self.setDefaultLabel];
    UIButton * editButton = [[UIButton alloc]init ] ;
    self.editButton= editButton;
    self.editButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.editButton.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
    [self.editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.editButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //    self.editButton.backgroundColor=randomColor;
    [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //    self.editButton.layer.cornerRadius=3;
    //    self.editButton.layer.masksToBounds=YES;
    //    self.editButton.layer.borderWidth=1;
    //    self.editButton.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [self.editButton setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
    [self.bottomContainerView addSubview:self.editButton];
    UIButton * deleteButton= [[UIButton alloc]init] ;
    self.deleteButton=deleteButton;
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //    self.deleteButton.backgroundColor=randomColor;
    [self.deleteButton setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //    self.deleteButton.layer.cornerRadius=3;
    //    self.deleteButton.layer.masksToBounds=YES;
    //    self.deleteButton.layer.borderWidth=1;
    //    self.deleteButton.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.deleteButton.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    self.deleteButton.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
    [self.deleteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.bottomContainerView addSubview:self.deleteButton];
    UIView * bottomSeparate= [[UIView alloc]init];
    self.bottomSeparate= bottomSeparate;
    self.bottomSeparate.backgroundColor=BackgroundGray;
    [self.contentView addSubview:self.bottomSeparate];
    
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    UIFont * font = self.areaLabel.font ;
    NSInteger lineNum  = self.areaLabel.numberOfLines;
    NSDictionary *attr = @{NSFontAttributeName : font};
    CGRect rect =  [self.areaLabel.text boundingRectWithSize:CGSizeMake(screenW - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil];
    CGFloat maxHeight = font.lineHeight * lineNum;
    CGFloat strHeight = rect.size.height > maxHeight ? maxHeight : rect.size.height ;
    
    
    
    CGFloat topMargin = 1 ;
    CGFloat topHeight = 30 ;
    CGFloat areaHeight = strHeight;
    CGFloat bottomHeight = 44 ;
    CGFloat bottomMargin = 10 ;
    self.topContainerView.frame = CGRectMake(0, 0, self.bounds.size.width, topHeight);
    self.areaLabel.frame = CGRectMake(10, CGRectGetMaxY(self.topContainerView.frame) ,screenW - 20, areaHeight);
    self.bottomContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.areaLabel.frame), screenW, bottomHeight);
    self.bottomSeparate.frame = CGRectMake(0, self.bounds.size.height -bottomMargin , screenW, bottomMargin);
    
    
    /////zi kong jian
    CGFloat margin = 10 ;
    self.nameLabel.frame = CGRectMake(margin, 0, [self.nameLabel.text sizeWithFont:self.nameLabel.font MaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, self.topContainerView.bounds.size.height);
    self.phoneNumberLabel.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + margin, 0, [self.phoneNumberLabel.text sizeWithFont:self.phoneNumberLabel.font MaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].width, self.topContainerView.bounds.size.height);
    self.midSeparate.frame = CGRectMake(0, 7, screenW, 1);
    
    
    self.setDefaultButton.frame = CGRectMake(margin,CGRectGetMaxY(self.midSeparate.frame), 40, self.bottomContainerView.bounds.size.height - CGRectGetMaxY(self.midSeparate.frame));
    [self.setDefaultLabel sizeToFit];
    self.setDefaultLabel.center = CGPointMake(CGRectGetMaxX(self.setDefaultButton.frame) + margin + self.setDefaultLabel.bounds.size.width/2, self.setDefaultButton.center.y);
    
    self.deleteButton.bounds = CGRectMake(0, 0, 60, 25) ;
    self.deleteButton.center = CGPointMake(self.bottomContainerView.bounds.size.width -(self.deleteButton.bounds.size.width/2+margin), self.setDefaultButton.center.y);
    
    self.editButton.bounds =  CGRectMake(0, 0, 60, 25) ;
    self.editButton.center = CGPointMake(CGRectGetMinX(self.deleteButton.frame) - margin - self.editButton.bounds.size.width/2, self.setDefaultButton.center.y);
    
    
}

-(void)layoutMySubview
{
  
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setModel:(AMCellModel *)model{
    _model=model;
//    self.areaLabel.text=[NSString stringWithFormat:@"%@ %@",model.area,model.address];
    if ([model.area containsString:@"亚洲中国"] ) {//国内先隐藏洲和国
        self.areaLabel.text=[NSString stringWithFormat:@"%@ %@",[model.area stringByReplacingOccurrencesOfString:@"亚洲中国" withString:@""] ,model.address];
    }else if([model.area containsString:@"亚洲 中国"]){
        self.areaLabel.text =[NSString stringWithFormat:@"%@ %@",[model.area stringByReplacingOccurrencesOfString:@"亚洲 中国" withString:@""] ,model.address];
    } else{
        self.areaLabel.text=[NSString stringWithFormat:@"%@ %@",model.area,model.address];
    }
    
    if (model.username.length>6) {
        NSString  * targetStr = [model.username substringWithRange:NSMakeRange(0, 6)];
        targetStr =  [targetStr stringByAppendingString:@"..."];
        self.nameLabel.text = targetStr;
    }else{
        self.nameLabel.text=model.username;
    }
    if (model.mobile.length>0) {
        
        self.phoneNumberLabel.text=model.mobile;
    }else if (model.telephone.length>0){
        self.phoneNumberLabel.text=model.telephone;
    }
    self.isDefaultAddress=model.isDefaultAddress;
    [self setNeedsLayout];
    //    self.namel
}
-(void)setIsDefaultAddress:(BOOL)isDefaultAddress{
    LOG(@"_%@_%d_%d",[self class] , __LINE__,isDefaultAddress);
    _isDefaultAddress=isDefaultAddress;
    //    self.defaultTag.hidden = !_isDefaultAddress;//产品不要 , 隐藏吧
    self.defaultTag.hidden=YES;
    self.setDefaultButton.selected=isDefaultAddress;
}
-(void)deleteButtonClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteButtonClickAtCell:)]) {
        [self.delegate deleteButtonClickAtCell:self];
    }
    
}
-(void)editButtonClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(editButtonClickAtCell:)]) {
        [self.delegate editButtonClickAtCell:self];
    }
}
-(void)setDefaultButtonClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(setDefaultAddressAtCell:)]) {
        [self.delegate setDefaultAddressAtCell:self];
    }
    
}
@end
