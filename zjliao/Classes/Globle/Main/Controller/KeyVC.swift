//
//  KeyVC.swift
//  mh824appWithSwift
//
//  Created by wangyuanfei on 16/8/24.
//  Copyright © 2016年 www.16lao.com. All rights reserved.
//

import UIKit
//MARK: swift3.0.1通知名字
let GDLanguageChanged = NSNotification.Name(rawValue:"languageChanged")
let GDHomeTabBarReclick = NSNotification.Name("GDOrderHomePageTabBarReclick")
let GDClassifyTabBarReclick = NSNotification.Name("GDRecentMessageTabBarReclick")
let GDLaoTabBarReclick = NSNotification.Name("GDLaoTabBarReclick")
let GDShopcarTabBarReclick = NSNotification.Name("GDShopcarTabBarReclick")
let GDProfileTabBarReclick = NSNotification.Name("GDProfileTabBarReclick")
let GDMessageCountChanged = NSNotification.Name("GDMessageCountChanged")
@objc  protocol AfterChangeLanguageKeyVCDidApear {
    func languageHadChanged() -> ()
}

class KeyVC: UINavigationController ,UITabBarControllerDelegate , LoginDelegate  {
    var priviousVC = UINavigationController() //记录上一次控制器
    var mainTabbarVC : MainTabbarVC? {
        
        
        if self.childViewControllers.count > 0 {
            if let vc = self.childViewControllers[0] as? MainTabbarVC{
                return vc
            }else{
                return nil
            }
        }else{
            return nil
        }
        
    }
    weak var keyVCDelegate : AfterChangeLanguageKeyVCDidApear?
    static let share: KeyVC = {
        let tempMainTabbarVC = MainTabbarVC()
        let tempKeyVC = KeyVC(rootViewController: tempMainTabbarVC)
        tempMainTabbarVC.delegate = tempKeyVC
        
        return tempKeyVC
    }()
    //    override init(rootViewController: UIViewController) {
    //
    //    }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    //    init(rootVC: UIViewController?) {
    //        super.init(rootViewController: mainTabbarVC)
    //        mainTabbarVC.delegate = self
    //    }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    //    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    //        super.init(nibName: nil, bundle: nil)
    //    }
    func restartAfterChangedLanguage()  {
        for vc in self.childViewControllers {
            if let targetVC = vc as? MainTabbarVC {
                targetVC.restartAfterChangeLanguage()
            }
        }
        
    }
    var currentTabbarIndex : Int {
        if self.childViewControllers.count > 0 {
            if let vc = self.childViewControllers[0] as? MainTabbarVC{
                return vc.selectedIndex
            }else{
                return 0
            }
        }else{
            return 0
        }
        
        //        if let tabbarvc  = mainTabbarVC {
        //            return tabbarvc.selectedIndex
        //        }else{
        //            return 0
        //        }
    }
    var currentSubVC : UIViewController?{
        
        if self.childViewControllers.count > 0 {
            if let vc = self.childViewControllers[0] as? MainTabbarVC{
                return vc.selectedViewController
            }else{
                return nil
            }
        }else{
            return nil
        }
        //        if let tabbarvc  = mainTabbarVC {
        //            return tabbarvc.selectedViewController
        //        }else{
        //            return nil
        //        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isHidden = true;
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: tabbarViewControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
        self.priviousVC = self.mainTabbarVC?.selectedViewController as! UINavigationController //记录上一次控制器
        guard  let _ =  viewController as? ShopCarNaviVC else {  return true}
        
        if Account.shareAccount.isLogin {
            return true
        }else{
            let loginVC = LoginVC()
            loginVC.loginDelegate = self
            let loginNaviVC = UINavigationController.init(rootViewController: loginVC)
            loginNaviVC.navigationBar.isHidden = true
            UIApplication.shared.keyWindow!.rootViewController!.present(loginNaviVC, animated: true, completion: nil)
            return false
        }
        
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        if let bool = self.mainTabbarVC?.selectedViewController?.isKind(of: HomeVaviVC.self) {
            if bool && self.priviousVC == viewController{
                
                mylog("发送订单首页重复点击通知")
                NotificationCenter.default.post(name: GDHomeTabBarReclick, object: nil, userInfo: nil)
            }
        }
        
        if let bool = self.mainTabbarVC?.selectedViewController?.isKind(of: ClassifyNaviVC.self) {
            if bool && self.priviousVC == viewController {
                NotificationCenter.default.post(name: GDClassifyTabBarReclick, object: nil, userInfo: nil)
                mylog("发送消息历史页面重复点击通知")
            }
        }
       /* if let bool = self.mainTabbarVC?.selectedViewController?.isKind(of: LaoNaviVC.self) {
            if bool && self.priviousVC == viewController {
                NotificationCenter.default.post(name: GDLaoTabBarReclick, object: nil, userInfo: nil)
                mylog("发送lao重复点击通知")
            }
        }
        if let bool = self.mainTabbarVC?.selectedViewController?.isKind(of: ShopCarNaviVC.self) {
            if bool && self.priviousVC == viewController {
                NotificationCenter.default.post(name: GDShopcarTabBarReclick, object: nil, userInfo: nil)
                mylog("发送购物车重复点击通知")
            }
        }
        if let bool = self.mainTabbarVC?.selectedViewController?.isKind(of: ProfileNaviVC.self) {
            if bool && self.priviousVC == viewController {
                NotificationCenter.default.post(name: GDProfileTabBarReclick, object: nil, userInfo: nil)
                mylog("发送我的重复点击通知")
            }
        }
        */
        mylog(self.mainTabbarVC?.selectedViewController)
    }
    
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        let ani : TabBarVCAnimat = TabBarVCAnimat()
        mylog(fromVC)
        mylog(toVC)
        return ani
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyVCDelegate?.languageHadChanged()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func selectChildViewControllerIndex(index : Int) -> () {
        
        var selectedIndex = index
        
        if selectedIndex < 0  {
            selectedIndex = 0
        }else if selectedIndex > 1{
            selectedIndex = 1
        }
       /* else if selectedIndex == 3 {
            if Account.shareAccount.isLogin {
                mainTabbarVC?.selectedIndex = selectedIndex
            }else{
                //                let loginVC = LoginVC(vcType: VCType.withBackButton)
                let loginVC = LoginVC()
                loginVC.loginDelegate = self
                let loginNaviVC = UINavigationController.init(rootViewController: loginVC)
                UIApplication.shared.keyWindow!.rootViewController!.present(loginNaviVC, animated: true, completion: nil)
                
            }
        }*/
        mainTabbarVC?.selectedIndex = selectedIndex
    }
    
    //登录结果代理
    func loginResult(result: Bool) {
        if result {
            mainTabbarVC?.selectedIndex = 3
        }
    }
    func  settabBarItem(number : String? , index : Int ){
        if index < 0 || index > 1 {return}
        if let numStr  = number {
            self.setnum(num: numStr, index: index)
        }else{
            self.setnum(num: nil , index: index)
        }
    }
      func setnum (num : String? , index : Int )  {
        if let items = mainTabbarVC?.tabBar.items {
            let tabBarItem : UITabBarItem = items[index]
            tabBarItem.badgeValue = num
        }
    }
    

    
}






////
////  KeyVC.swift
////  mh824appWithSwift
////
////  Created by wangyuanfei on 16/8/24.
////  Copyright © 2016年 www.16lao.com. All rights reserved.
////
//
//import UIKit
//
//@objc  protocol AfterChangeLanguageKeyVCDidApear {
//    func languageHadChanged() -> ()
//}
//
//class KeyVC: UINavigationController ,UITabBarControllerDelegate , LoginDelegate  {
//    var  mainTabbarVC : MainTabbarVC?
//    weak var keyVCDelegate : AfterChangeLanguageKeyVCDidApear?
////    override init(rootViewController: UIViewController) {
////        
////    }
////    
////    required init?(coder aDecoder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
//    
////    init(rootVC: UIViewController?) {
////        super.init(rootViewController: mainTabbarVC)
////        mainTabbarVC.delegate = self
////    }
////    
////    required init?(coder aDecoder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
////    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
////        super.init(nibName: nil, bundle: nil)
////    }
//    var currentTabbarIndex : Int {
//        if let tabbarvc  = mainTabbarVC {
//            return tabbarvc.selectedIndex
//        }else{
//            return 0
//        }
//    }
//    var currentSubVC : UIViewController?{
//        if let tabbarvc  = mainTabbarVC {
//            return tabbarvc.selectedViewController
//        }else{
//            return nil
//        }
//    
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationBar.isHidden = true;
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    //MARK: tabbarViewControllerDelegate
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
//        
//        guard  let _ =  viewController as? ShopCarNaviVC else {  return true}
//        
//        if Account.shareAccount.isLogin {
//            return true
//        }else{
//            let loginVC = LoginVC(vcType: VCType.withoutBackButton)
//            loginVC.loginDelegate = self
//            let loginNaviVC = UINavigationController.init(rootViewController: loginVC)
//            loginNaviVC.navigationBar.isHidden = true
//            UIApplication.shared.keyWindow!.rootViewController!.present(loginNaviVC, animated: true, completion: nil)
//            return false
//        }
//       
//    }
//    
//    
//    
//    //自定义转场动画
//     public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
//        let ani : TabBarVCAnimat = TabBarVCAnimat()
//        mylog(fromVC)
//        mylog(toVC)
//        if let classifynavi  = toVC as? ClassifyNaviVC {
//            classifynavi.tabBarItem.badgeValue = nil
//        }
//        return ani
//    }
//    
//    
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.keyVCDelegate?.languageHadChanged()
//
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//    func selectChildViewControllerIndex(index : Int) -> () {
//        
//        var selectedIndex = index
//        
//        if selectedIndex < 0  {
//            selectedIndex = 0
//        }else if selectedIndex > 4{
//            selectedIndex = 4
//        }else if selectedIndex == 3 {
//            if Account.shareAccount.isLogin {
//                mainTabbarVC?.selectedIndex = selectedIndex
//            }else{
//                let loginVC = LoginVC(vcType: VCType.withoutBackButton)
//                loginVC.loginDelegate = self
//                let loginNaviVC = UINavigationController.init(rootViewController: loginVC)
//                UIApplication.shared.keyWindow!.rootViewController!.present(loginNaviVC, animated: true, completion: nil)
//                
//            }
//        }
//        mainTabbarVC?.selectedIndex = selectedIndex
//    }
//    
//    //登录结果代理
//    func loginResult(result: Bool) {
//        if result {
//            mainTabbarVC?.selectedIndex = 3
//        }
//    }
//    
//
//}
