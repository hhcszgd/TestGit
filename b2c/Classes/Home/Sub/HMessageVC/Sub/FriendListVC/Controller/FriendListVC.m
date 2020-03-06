//
//  FriendListVC.m
//  b2c
//
//  Created by wangyuanfei on 7/2/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "FriendListVC.h"

#import "GDXmppStreamManager.h"

#import "XMPPvCardTemp.h"


#import "MessageCenterCell.h"

#import <CoreData/CoreData.h>

#import "b2c-Swift.h"

#import <Social/Social.h>
@interface FriendListVC ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (nonatomic , strong)NSArray *ContactArrs;

@property (nonatomic , strong)NSArray <NSDictionary *> * CustomContactArrs;

/** 物流和商城公告 */
@property(nonatomic,strong)NSMutableArray * topArrM ;
@property (nonatomic , strong)NSFetchedResultsController *fetchedresultsController;
/** 测试匹配昵称 */
@property(nonatomic,strong)   NSFetchedResultsController*resultController ;

@end

@implementation FriendListVC



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(theMessageChange) name:MESSAGECOUNTCHANGED object:nil];
//    self.naviTitle=@"消息中心";
//    [NSFetchedResultsController deleteCacheWithName:@"Recently"];
//    [self setupTableView ];
//    //执行查找数据
//    [self.fetchedresultsController performFetch:nil];
//    self.ContactArrs =  [self.topArrM arrayByAddingObjectsFromArray:self.fetchedresultsController.fetchedObjects];
//    [self.tableView reloadData];
//    [self editMyVCardInfo];
    
    
    
    self.naviTitle=@"消息中心";
//    [NSFetchedResultsController deleteCacheWithName:@"Recently"];
    [self setupTableView ];
    //执行查找数据
//    [self.fetchedresultsController performFetch:nil];
//    self.ContactArrs =  [self.topArrM arrayByAddingObjectsFromArray:self.fetchedresultsController.fetchedObjects];

    [[GDStorgeManager share] gotRecentContactListWithCallBack:^(NSInteger resultCode, NSArray<NSDictionary<NSString *,NSString *> *> * _Nonnull resultArr) {
        self.CustomContactArrs =  [self.topArrM arrayByAddingObjectsFromArray:resultArr];
        [self.tableView reloadData];
    }];
//    [[GDStorgeManager share] gotRecentContactWithCallBack:^(NSInteger resultCode, NSArray<NSDictionary<NSString *,NSString *> *> * _Nonnull resultArr) {
//        GDlog(@"%@",resultArr)
//        
//        
//        self.CustomContactArrs =  [self.topArrM arrayByAddingObjectsFromArray:resultArr];
//        [self.tableView reloadData];
////        [self editMyVCardInfo];
//        
//    }];
}

-(void )theMessageChange
{
    [[GDStorgeManager share] gotRecentContactListWithCallBack:^(NSInteger resultCode, NSArray<NSDictionary<NSString *,NSString *> *> * _Nonnull resultArr) {
        self.CustomContactArrs =  [self.topArrM arrayByAddingObjectsFromArray:resultArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    }];
}
-(void)editMyVCardInfo
{
//    [[GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
//    [[GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule fetchvCardTempForJID:[GDXmppStreamManager ShareXMPPManager].XmppStream.myJID];
//   XMPPvCardTemp * myCard = [[GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule vCardTempForJID:[GDXmppStreamManager ShareXMPPManager].XmppStream.myJID shouldFetch:YES];
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.jid.user);
        [[GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    XMPPvCardTemp * myCard = [GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule.myvCardTemp;
//    [GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule.myvCardTemp.nickname = @"fuck";
//    [GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule.myvCardTemp.jid = [GDXmppStreamManager ShareXMPPManager].XmppStream.myJID;
//    [GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule.myvCardTemp.desc = @"我就是我,不一样的烟火";
//    [[GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule updateMyvCardTemp:myCard];
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.nickname);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.bday);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.jid);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.name);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.photo);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.desc);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,myCard.agent);
    }
-(void)setupTableView
{
    //    CGRect frame  = CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height);
    CGRect frame =  CGRectMake(0, self.startY, self.view.bounds.size.width, self.view.bounds.size.height-self.startY);
    UITableView     * tableView =[[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableView =tableView;
    tableView.separatorStyle=0;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = BackgroundGray;
    tableView.sectionHeaderHeight=0.00001;
    tableView.sectionFooterHeight = 0.00001;
    tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 0.000001)];
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 0.000001)];
//    tableView.delegate=self;
//    tableView.dataSource = self;
    //    tableView.rowHeight = UITableViewAutomaticDimension;
    //    tableView.estimatedRowHeight=200;dide
    
    
}
//懒加载
-(NSArray *)ContactArrs
{
    if (_ContactArrs == nil) {
        _ContactArrs = [NSArray array];
    }
    return  _ContactArrs;
}

-(NSArray<NSDictionary *> *)CustomContactArrs{
    if (_CustomContactArrs == nil ) {
        _CustomContactArrs = [NSArray array];
    }
    return  _CustomContactArrs;
}


-(NSFetchedResultsController *)fetchedresultsController
{
    if (_fetchedresultsController == nil) {
        //查询请求
        NSFetchRequest *fetchrequest = [[NSFetchRequest alloc]init];
        //实体描述
        
        NSEntityDescription *entitys =  [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject" inManagedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        
        fetchrequest.entity = entitys;
        
#pragma mark 查询请求控制器需要一个排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:YES];
        fetchrequest.sortDescriptors = @[sort];
        
        //创建懒加载对象(查询请求控制器)
        _fetchedresultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchrequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:@"Recently"];
        
        _fetchedresultsController.delegate = self;
    }
    return _fetchedresultsController;
}

//-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    NSLog(@"*************************ContactArrs****************** = %lu",(unsigned long)self.ContactArrs.count);
////    LOG(@"_%@_%d_%@",[self class] , __LINE__,self.topArrM);
//    self.ContactArrs = [self.topArrM arrayByAddingObjectsFromArray:self.fetchedresultsController.fetchedObjects];
//    [self.tableView reloadData];
//}

#pragma mark tableview 代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
//    return self.ContactArrs.count;
     return self.CustomContactArrs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取出数据
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,self.ContactArrs);
//    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.ContactArrs[indexPath.row];
    NSDictionary * dict = self.CustomContactArrs[indexPath.row];
    
    
    
//    if ([NSStringFromClass([contact class]) isEqualToString:@"XMPPMessageArchiving_Contact_CoreDataObject"]) {
//            XMPPvCardTemp * vcard = [[GDXmppStreamManager ShareXMPPManager].xmppvcardtempModule vCardTempForJID:contact.bareJid shouldFetch:YES];
//            LOG(@"_%@_%d_\n\n\n\n这是昵称%@\n\n\n\n",[self class] , __LINE__,vcard.nickname);
////        [self gotNickNameWithContact:contact];//错误
//    }
    
    
    //创建cell
    MessageCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if (!cell) {
        cell = [[MessageCenterCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    
//    cell.contact = contact;
    cell.customCellModel = dict ;
    //给cell赋值
//    UILabel *name = [cell viewWithTag:1001];
//    name.text = contact.bareJidStr;
//    
//    UILabel *body = [cell viewWithTag:1002];
//    body.text = contact.mostRecentMessageBody;
//    LOG(@"_%@_%d_看看这个属性是不是记录消息变化的--->>>%d",[self class] , __LINE__,contact.hasPersistentChangedValues);
//    LOG(@"_%@_%d_看看这个属性是不是记录消息变化的--->>>%d",[self class] , __LINE__,contact.hasChanges);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,[contact class]);
    if (indexPath.row>3) {
//            LOG(@"_%@_%d_看看这个属性是不是记录消息变化的--->>>%d",[self class] , __LINE__,contact.hasPersistentChangedValues);
//            LOG(@"_%@_%d_看看这个属性是不是记录消息变化的--->>>%d",[self class] , __LINE__,contact.hasChanges);
    }


    //返回cell
    return cell;
}

-(void)gotNickNameWithContact:(XMPPMessageArchiving_Contact_CoreDataObject*)contact
{
    NSManagedObjectContext *context= [XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
    NSFetchRequest *request=[[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //对结果进行排序
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors=@[sort];
    //设置谓词过滤
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"jidStr==%@",contact.bareJidStr];
    
    request.predicate=pre;
    if (!self.resultController) {
        
        NSFetchedResultsController*resultController=[[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        self.resultController = resultController;
    }
    
    //设置代理
    self.resultController.delegate=self;
    NSError *error=nil;
    //执行
    [self.resultController performFetch:&error];
    if (error) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,error);
    }else{
        LOG(@"_%@_%d_%@",[self class] , __LINE__,self.resultController.fetchedObjects);
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54*SCALE;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        BaseModel * model = [[BaseModel alloc]init];
        model.actionKey = @"SuperMarketPlacardVC";
        
        model.keyParamete = @{@"paramete":[NSString stringWithFormat:@"%@/AppOrder/Notice.html",WAPDOMAIN]};
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    }else if (indexPath.row==1){
        BaseModel * model = [[BaseModel alloc]init];
        
        model.keyParamete = @{@"paramete":[NSString stringWithFormat:@"%@/AppOrder/logisticsList.html",WAPDOMAIN]};
        model.actionKey = @"LogisticsStatusVC";
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    }else if (indexPath.row==2){
        BaseModel * model = [[BaseModel alloc]init];
        model.keyParamete = @{@"paramete":[NSString stringWithFormat:@"%@/AppOrder/promotion.html",WAPDOMAIN]};
        model.actionKey = @"LogisticsStatusVC";
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    }else if (indexPath.row==3){
        BaseModel * model = [[BaseModel alloc]init];
        model.keyParamete = @{@"paramete":[NSString stringWithFormat:@"%@/AppOrder/activity.html",WAPDOMAIN]};
        model.actionKey = @"LogisticsStatusVC";
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    }else{
//          id model = self.ContactArrs[indexPath.row];
//        if ([NSStringFromClass([model class]) isEqualToString:@"XMPPMessageArchiving_Contact_CoreDataObject"]) {
//         XMPPMessageArchiving_Contact_CoreDataObject * contact =   (XMPPMessageArchiving_Contact_CoreDataObject *) model ;
//
//            
//            BaseModel * model = [[BaseModel alloc]init];
//            //MARK : 临时切换聊天控制器
////            model.actionKey = @"ChatVC";
//            model.actionKey = @"NewChatVC";
////            if (vcard.nickname.length>0 && ![vcard.nickname isEqualToString:@"null"]) {
////                model.keyParamete = @{@"paramete":contact.bareJid , @"nickname":vcard.nickname };
//                
////            }else{
//                model.keyParamete = @{@"paramete":contact.bareJid};
//
//            [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
//            }
        
        
        NSDictionary * dict  = self.CustomContactArrs[indexPath.row];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            
            
            BaseModel * model = [[BaseModel alloc]init];
            //MARK : 临时切换聊天控制器
            //            model.actionKey = @"ChatVC";
            model.actionKey = ChatVCName;
            //            if (vcard.nickname.length>0 && ![vcard.nickname isEqualToString:@"null"]) {
            //                model.keyParamete = @{@"paramete":contact.bareJid , @"nickname":vcard.nickname };
            
            //            }else{
            if (dict[@"other_account"]) {
                XMPPJID * jid = [XMPPJID jidWithUser:dict[@"other_account" ] domain:@"jabber.zjlao.com" resource:@"iOS"];
                model.keyParamete = @{@"paramete": jid};
                
                [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
            }else{
                AlertInVC(@"联系人不存在")
            }
        }
    }
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)cell
//{
//    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.ContactArrs[[self.tableView indexPathForCell:cell].row];
//    CZChatViewController *chatvc = segue.destinationViewController;
//    chatvc.UserJid = contact.bareJid;
//}
- (IBAction)AddRoom:(id)sender {
    
    
}
-(NSMutableArray * )topArrM{
    if(_topArrM==nil){
        _topArrM = [[NSMutableArray alloc]init];
        for (int i = 0; i<4; i++) {
            NSString * topModel =nil ;

            
            if (i==0) {
                topModel = @"商城公告";
//                topModel.mostRecentMessageBody = @"";
            }else if (i==1){
                topModel = @"物流信息";
            }else if (i==2){
                topModel = @"促销";
            }else if (i==3){
                topModel = @"活动";
            }
            [_topArrM  addObject:topModel];
        }
    }
    return _topArrM;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGECOUNTCHANGED object:nil];
    // 禁用 iOS8 返回手势
//    if ([UIDevice currentDevice].systemVersion.floatValue<9.0) {
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    
//    }
    NSTimeInterval  time = [[GDXmppStreamManager ShareXMPPManager].XmppStream xmppAutoTime_timeDifferenceForTargetJID:nil  ];
    NSDate * date = [[GDXmppStreamManager ShareXMPPManager].XmppStream xmppAutoTime_dateForTargetJID:nil   ];
    NSDate * localDate = [NSDate date];
    
    GDlog(@"服务器时间:%@ ~  本地时间: %@  ~ 时间差%f" , date , localDate , [GDXmppStreamManager ShareXMPPManager].timeMoudle.timeDifference )
    NSString * result = [[GDXmppStreamManager ShareXMPPManager].time sendQueryToServer];
     GDlog(@"请求服务器结果%@ " , result )
}

-(void )testSocial
{
    // 1.判断平台是否可用
    /** 
     SOCIAL_EXTERN NSString *const SLServiceTypeTwitter NS_AVAILABLE(10_8, 6_0);
     SOCIAL_EXTERN NSString *const SLServiceTypeFacebook NS_AVAILABLE(10_8, 6_0);
     SOCIAL_EXTERN NSString *const SLServiceTypeSinaWeibo NS_AVAILABLE(10_8, 6_0);
     SOCIAL_EXTERN NSString *const SLServiceTypeTencentWeibo NS_AVAILABLE(10_9, 7_0);
     SOCIAL_EXTERN NSString *const SLServiceTypeLinkedIn NS_AVAILABLE(10_9, NA);
     */
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        NSLog(@"查看您是否设置了新浪微博帐号,设置界面-->新浪微博-->配置帐号");
    }
    
    // 2.创建SLComposeViewController
    SLComposeViewController *composeVc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    
    // 2.1.添加分享文字
    [composeVc setInitialText:@"做人如果没有梦想,跟咸鱼有什么区别"];
    
    // 2.2.添加分享图片
    [composeVc addImage:[UIImage imageNamed:@"xingxing"]];
    
    // 3.弹出分享界面
    [self presentViewController:composeVc animated:YES completion:nil];
    
    
    // 4.设置block属性
    composeVc.completionHandler = ^ (SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultCancelled) {
            NSLog(@"用户点击了取消");
        } else {
            NSLog(@"用户点击了发送");
        }
    };
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row>3) {
        return YES;
    }else{
        return NO;
    }

}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.ContactArrs[indexPath.row];
//    [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext deleteObject:contact];
//    [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext save:nil];
//    [self.tableView reloadData];
    NSDictionary * dict = self.CustomContactArrs[indexPath.row];
    //删除contact表聊最近联系人
    [[GDStorgeManager share] deleteContactFromContactWithUserName:dict[@"other_account"] callBack:^(NSInteger resultCode, NSString * _Nonnull resultStr) {
        GDlog(@"删除联系人%@结果%@" ,dict[@"other_account"],resultStr)
    }];
    
    //删除message表聊天记录
    [[GDStorgeManager share] deleteFormContentWithUserName:dict[@"other_account"] callBack:^(NSInteger resultcode, NSString * _Nonnull resultStr) {
        GDlog(@"删除联系人%@结果%@" ,dict[@"other_account"],resultStr)
    }];
    //删除聊天记录相关文件
    [[GDStorgeManager share ]deleteUserFileWithPath:dict[@"other_account"] callBack:^(NSInteger resultcode, NSString * _Nonnull resultStr) {
        GDlog(@"删除联系人%@相关文件结果%@" ,dict[@"other_account"],resultStr)

        
    }];
//    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.ContactArrs[indexPath.row];
//    [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext deleteObject:contact];
//    [[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext save:nil];
//    [[GDStorgeManager share] gotRecentContactWithCallBack:^(NSInteger resultCode, NSArray<NSDictionary<NSString *,NSString *> *> * _Nonnull resultArr) {
        [[GDStorgeManager share] gotRecentContactListWithCallBack:^(NSInteger resultCode, NSArray<NSDictionary<NSString *,NSString *> *> * _Nonnull resultArr) {
        GDlog(@"%@",resultArr)
        
        
        self.CustomContactArrs =  [self.topArrM arrayByAddingObjectsFromArray:resultArr];
        [self.tableView reloadData];
        //        [self editMyVCardInfo];
        
    }];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"点击删除");
}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//
//    NSString * userName = @"zhangkaiqiang";
//    XMPPJID * userJid = [XMPPJID jidWithUser:userName domain:@"jabber.zjlao.com" resource:nil];
//    BaseModel * model = [[BaseModel alloc]init];
//    model.actionKey=@"ChatVC";
//    model.keyParamete = @{@"paramete":userJid};
//    [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
//
//
//}

#pragma mark fetchedResultsControllerDelegete
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath{
//    LOG_METHOD
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,anObject);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,indexPath);
//    LOG(@"_%@_%d_%d",[self class] , __LINE__,type);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,newIndexPath);
//}

/* Notifies the delegate of added or removed sections.  Enables NSFetchedResultsController change tracking.
 
	controller - controller instance that noticed the change on its sections
	sectionInfo - changed section
	index - index of changed section
	type - indicates if the change was an insert or delete
 
	Changes on section info are reported before changes on fetchedObjects.
 */


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    LOG_METHOD
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,sectionInfo);
//    LOG(@"_%@_%d_%d",[self class] , __LINE__,sectionIndex);

}

/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    LOG_METHOD
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */



//- (nullable NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0){
//    
//    return @"测试";
//}
@end
