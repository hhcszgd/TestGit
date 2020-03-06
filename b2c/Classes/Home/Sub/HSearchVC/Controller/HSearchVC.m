//
//  HSearchVC.m
//  b2c
//
//  Created by wangyuanfei on 3/27/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "HSearchVC.h"
#import "SearchFlowLayout.h"
#import "SearchCell.h"
#import "SeachHeaderView.h"
#import "SearchCollectionView.h"
#import "SearchPageModel.h"

//#import "UserInfo.h"

@interface HSearchVC ()<UITextFieldDelegate,UICollectionViewDelegate , UICollectionViewDataSource , SeachHeaderViewDelegate>
@property(nonatomic,weak) UIButton*cancleButton ;
@property(nonatomic,weak ) UITextField * searchInputField ;
@property(nonatomic,strong)NSMutableArray * hotSearchWords ;
@property(nonatomic,strong)NSMutableArray * historySearchWords ;

@property(nonatomic,weak)SearchCollectionView * collect ;
@property(nonatomic,strong)NSMutableArray * totalDatas ;
@property(nonatomic,copy)NSString * defauleKeyword ;
@end

@implementation HSearchVC
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.naviTitle=@"search";
    [self gotSearchDataWithAactionType:0 success:^(ResponseObject *responseObject) {
           [self setupCollectionview];
        self.searchInputField.placeholder = self.defauleKeyword;
//        if (self.searchInputField.placeholder.length>0 && !self.searchInputField.text.length>0) {
//            [self.cancleButton setTitle:@"搜索" forState:UIControlStateNormal];
//        }else{
//            [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
//
//        }
        [self.collect reloadData];
    } failure:^(NSError *error) {
        
    }];
    
    [self setupNavigationbarView];
 
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.collect.bounces=YES;
}
-(void)setupCollectionview
{
//    SearchFlowLayout * layout = [[SearchFlowLayout alloc]initWithDatas:@[self.hotSearchWords,self.historySearchWords]];
        SearchFlowLayout * layout = [[SearchFlowLayout alloc]initWithDatas:self.totalDatas];
    SearchCollectionView * collect = [[SearchCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collect.frame = CGRectMake(0 , self.startY  ,self.view.bounds.size.width ,self.view.bounds.size.height - self.startY);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    collect.userInteractionEnabled = YES ;
    collect.showsVerticalScrollIndicator=YES;
    collect.showsHorizontalScrollIndicator=NO;
//    collect.bounces=YES;
    collect.alwaysBounceVertical = YES;
    collect.scrollEnabled=YES;
    collect.dataSource=self;
    collect.delegate=self;
    [self.view addSubview:collect];
    self.collect=collect;
//    collect.backgroundColor = [UIColor whiteColor];
    collect.backgroundColor =  [UIColor colorWithRed:240/256.0 green:240/256.0 blue:244/256.0 alpha:1];
    collect.allowsMultipleSelection=YES;
    
    [self.collect registerClass:[SearchCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collect registerClass:[SeachHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];

}

-(void)setupNavigationbarView
{
    UIButton*cancleButton  = [[UIButton alloc]init];
    self.cancleButton = cancleButton ;
    [cancleButton setTitle:@"搜索" forState:UIControlStateNormal];
    [cancleButton setTitleColor: MainTextColor forState:UIControlStateNormal];
    [cancleButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancleButton.titleLabel setFont:[UIFont systemFontOfSize:15*SCALE]];
    self.navigationBarRightActionViews = @[cancleButton];
    CGFloat bottomMargin = 7 ;
    CGFloat H = 44 - bottomMargin * 2 ;
    CGFloat Y = 20 + bottomMargin ;
//    UIView * searchBarContainer = [[UIView alloc]initWithFrame:CGRectMake(66, Y, self.view.bounds.size.width - 66*2, H) ];
        UIView * searchBarContainer = [[UIView alloc]initWithFrame:CGRectMake(44  , Y, self.view.bounds.size.width - 44*2, H) ];
    self.navigationCustomView = searchBarContainer ;
    
    //    UIView * searchBarContainer = [[UIView alloc]init ];
    //
    //    self.searchView = searchBarContainer ;
    UIImageView * searchImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
    searchImg.alpha = 0.5 ;
    searchImg.backgroundColor = [UIColor clearColor];
    UITextField * searchInputField = [[UITextField alloc]init];
    searchInputField.font = [UIFont systemFontOfSize:14*SCALE];
    self.searchInputField = searchInputField;
    [self.searchInputField becomeFirstResponder];
    searchInputField.delegate = self;
    searchInputField.backgroundColor = [UIColor clearColor];
    [searchBarContainer addSubview:searchInputField];
    [searchBarContainer addSubview:searchImg];
    searchBarContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    searchBarContainer.layer.cornerRadius = 6 ;
    searchBarContainer.layer.borderWidth = 0.5;
    
    searchImg.frame = CGRectMake(0, 0, searchBarContainer.bounds.size.height, searchBarContainer.bounds.size.height);
    searchInputField.frame = CGRectMake(searchImg.bounds.size.width, 0,  searchBarContainer.bounds.size.width-searchImg.bounds.size.width,searchImg.bounds.size.height);
    //extView.keyboardAppearance=UIKeyboardAppea
    
    searchInputField.placeholder = @"搜索你想要的商品";
    searchInputField.returnKeyType = UIReturnKeySearch;
    searchInputField.keyboardType = UIKeyboardTypeDefault;
    searchInputField.enablesReturnKeyAutomatically=YES;
    [searchInputField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];

}

 
 - (void)textFieldEditChanged:(UITextField *)textField
 {
     if (textField.text.length>0) {
         [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
     }else{
         [self.cancleButton setTitle:@"搜索" forState:UIControlStateNormal];
         
     }
 NSLog(@"textField text : %@", [textField text]);
 }




/** UIcollection代理 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.totalDatas.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    
    NSArray * litArr = self.totalDatas[section];
    
    return litArr.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSArray * litArr = self.totalDatas[ indexPath.section];
    cell.title = litArr[indexPath.item];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if (kind == UICollectionElementKindSectionHeader) {
        SeachHeaderView *headerView = (SeachHeaderView *)[collectionView  dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        NSString * headerTitle = nil;
        headerView.headerDelegate=self;
        if (indexPath.section ==0) {
                headerTitle = @"热搜排行";
            headerView.showActionView=NO;
            headerView.showNoHistoryView=NO;


        }else{
                headerTitle = @"搜索历史";
            headerView.showActionView=YES;
            
            if (self.historySearchWords.count>0) {
                headerView.showNoHistoryView=NO;
            }else{
                headerView.showNoHistoryView=YES;
            }

        }
        
        
        headerView.headerTitle=headerTitle;
        return headerView;
    }
    return nil;
    
}
-(void)actionViewClick:(ActionBaseView *)sender inView:(SeachHeaderView *)headerView{
    
    LOG(@"_%@_%d_代理执行成功:%@",[self class] , __LINE__,headerView.headerTitle);
    
    [self.historySearchWords removeAllObjects];
    
    [self.collect reloadData];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,indexPath);
    SearchCell * cell =(SearchCell *) [collectionView cellForItemAtIndexPath:indexPath];
    BaseModel * model = [[BaseModel alloc]init];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,cell.title);
    
    model.actionKey=@"HSearchgoodsListVC";
    
    if (self.channel_id) {
        model.keyParamete = @{
                              @"paramete":cell.title,
                              @"channel_id":self.channel_id
                              };
    }else{
    
        model.keyParamete = @{
                              @"paramete":cell.title
                              };
    }
    [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];

}

- (void)textFieldDidChange:(UITextField *)textField{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,textField.text);
    if (textField.markedTextRange == nil) {
        NSLog(@"text:%@", textField.text);
    }
}
-(void)cancleClick:(UIButton*)sender
{
    if (self.searchInputField.placeholder.length>0 && !(self.searchInputField.text.length>0)) {//显示搜索
        BaseModel * model = [[BaseModel alloc]init];
        model.actionKey=@"HSearchgoodsListVC";
        if (self.channel_id) {
            model.keyParamete = @{
                                  @"paramete":self.searchInputField.placeholder,
                                  @"channel_id":self.channel_id
                                  };
        }else{
            
            model.keyParamete = @{
                                  @"paramete":self.searchInputField.placeholder
                                  };
        }
//        model.keyParamete = @{
//                              @"paramete":self.searchInputField.placeholder
//                              };
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
        
    }else{//显示取消
        [self.navigationController popViewControllerAnimated:YES];
        [self.view endEditing:YES];
    }
    
    
    LOG(@"_%d_%@",__LINE__,@"点击取消按钮");
}
/** 点击搜索的监听方法 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    BaseModel * model = [[BaseModel alloc]init];
    model.actionKey=@"HSearchgoodsListVC";
    if (self.channel_id) {
        model.keyParamete = @{
                              @"paramete":textField.text,
                              @"channel_id":self.channel_id
                              };
    }else{
        
        model.keyParamete = @{
                              @"paramete":textField.text
                              };
    }

    if (textField.text.length>64) {
        AlertInVC(@"请输入64位以内的关键字")
        return NO;
    }else{
//        [self.view endEditing:YES];
        [self.searchInputField resignFirstResponder];
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
        
        return YES;
    }
    
}
//这是当前控制器的方法
-(void)gotSearchDataWithAactionType:(LoadDataActionType)actionType success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

    
    
    [[UserInfo shareUserInfo] gotSearchPageDataSuccess:^(ResponseObject *responseObject) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject.data)
        if ([responseObject.data isKindOfClass:[NSArray class]]) {
            for (id sub in responseObject.data) {
                if ([sub isKindOfClass:[NSDictionary class]]) {
                    SearchPageModel * bigModel = [[SearchPageModel alloc]initWithDict:sub];
                    
                    
                    if ([bigModel.key isEqualToString:@"hotkeywords"]) {
                        if ([[bigModel.items lastObject][@"keyword"] isKindOfClass:[NSString class]]) {
                            
                            self.defauleKeyword = [bigModel.items lastObject][@"keyword"];
                        }else{
                            self.defauleKeyword = @"" ;
                        }
                        
                        
                        
                    }else if ([bigModel.key isEqualToString:@"hotSearch"]){
                        
                        [self.hotSearchWords removeAllObjects];
                        
                        for (id subsub in  bigModel.items) {
                            if ([subsub isKindOfClass:[NSDictionary class]]) {
                                if ([subsub[@"keyword"] isKindOfClass:[NSString class]] && [subsub[@"keyword"] length]>0) {
                                    [self.hotSearchWords addObject:subsub[@"keyword"]];
                                }
                            }
                        }

                        
                        
                    }else if ([bigModel.key isEqualToString:@"historySearch"]){
                        
                        [self.historySearchWords removeAllObjects];
                        
                        
                        for (id subsub in  bigModel.items) {
                            if ([subsub isKindOfClass:[NSDictionary class]]) {
                                if ([subsub[@"keyword"] isKindOfClass:[NSString class]] && [subsub[@"keyword"] length]>0) {
                                    [self.historySearchWords addObject:subsub[@"keyword"]];
                                }
                            }
                        }
                        
                        
                        
                        
                    }
                }
                
            }
        }
            success(responseObject);
    } failure:^(NSError *error) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
        failure(error);
    } ];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self gotSearchDataWithAactionType:Refresh success:^(ResponseObject *responseObject) {
        [self.collect reloadData];
    } failure:^(NSError *error) {
        
    }];
}
//这是下一个控制器的数据请求方法 ,
//-(void)performSearchWithKeyWord:(NSString*)keyWord order:(NSUInteger)order pageNum:(NSUInteger)pageNum success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure
//{
//    
//    [[UserInfo shareUserInfo] searchGoodsInGlobleWithKeyWord:keyWord  order:0 pageNum:0 success:^(ResponseObject *responseObject) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject.data)
//
//        success(responseObject);
//    } failure:^(NSError *error) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
//        failure(error);
//    } ];
//    LOG(@"_%@_%d_搜索关键词:%@",[self class] , __LINE__,keyWord)
//
//
//
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"fuck , 内存警告");
    // Dispose of any resources that can be recreated.

}

-(NSMutableArray * )hotSearchWords{
    if(_hotSearchWords==nil){
        _hotSearchWords = [[NSMutableArray alloc]init];
//        for (int i = 0 ; i < 19 ;i++) {
//
//            [_hotSearchWords addObject:[NSString stringWithFormat:@"新鲜" ]];
//        }
    }
    return _hotSearchWords;
}
-(NSMutableArray * )historySearchWords{
    if(_historySearchWords==nil){
        _historySearchWords = [[NSMutableArray alloc]init];
//        for (int i = 0 ; i < 119 ;i++) {
//            
//            [_historySearchWords addObject:[NSString stringWithFormat:@"女" ]];
//        }
    }
    return _historySearchWords;
}

-(NSMutableArray * )totalDatas{
    if(_totalDatas==nil){
        _totalDatas = [[NSMutableArray alloc]init];
    }
    
    [_totalDatas removeAllObjects];
    if (self.hotSearchWords.count>0) {
        
        [_totalDatas addObject:self.hotSearchWords];
    }
    if (self.historySearchWords.count>0) {
        [_totalDatas  addObject:self.historySearchWords];
    }
    return _totalDatas;
}



@end
